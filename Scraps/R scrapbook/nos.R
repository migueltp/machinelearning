library(data.table)

df = fread(input='~/data_store/ds/DESAFIO_ML_1.txt')
# df_test = df[df$base == 'Teste']
# df_train = df[df$base == 'Treino']
df = df[! df$base %in% c('Teste', 'Treino')]

### PRE PROCESSING
# TODO: CHECK NULLS
df[df$dt_hr_tentativa == '']
df[df$data_do_lote == '']
df = df[df$dt_hr_tentativa != '']
df = df[df$data_do_lote != '']

# Date diff since lead created and lead contacted
df[, days_diff := as.numeric(as.Date(df$dt_hr_tentativa, format = "%d%b%Y") - 
                             as.Date(df$data_do_lote, format = "%Y-%m-%d"))]

# Nr of contacts so far
# Create timestamp (int) for fast sorting
df[, dt_hr_int := as.numeric(as.POSIXct(df$dt_hr_tentativa, format = "%d%b%Y:%H:%M:%S"))]
df[, nr_contacts := frank(dt_hr_int, ties.method = 'first'), by=id_Cliente_A]
df[nr_contacts > 50, nr_contacts_bin := '[50+]']
df[nr_contacts %between% c(21, 50), nr_contacts_bin := '[21 - 50]']
df[nr_contacts %between% c(10, 20), nr_contacts_bin := '[10 - 20]']
df[nr_contacts < 10, nr_contacts_bin := as.character(nr_contacts)]



# Phone type (mobile vs land line)
df[, phone_type := 'other']
df[substr(df$indic_tlf_dest_A, start = 1, stop = 1) == 2, phone_type := 'land_phone']
df[substr(df$indic_tlf_dest_A, start = 1, stop = 1) == 9, phone_type := 'land_phone']

# Has multiple phone Nrs ?
df[, nr_unique_phones:= uniqueN(tlf_destino_A), by = id_Cliente_A]

# Contact center Phone is same of customer ?
# Contact center Phone is unknown ?
df[ , is_unknown := 0]
df[ , same_network := 0]
df[indic_tlf_ori_A == 'unknown', is_unknown := 1]
df[indic_tlf_dest_A == indic_tlf_ori_A, same_network := 1]

# Day of the week
df[, day_of_week := weekdays(as.POSIXct(df$dt_hr_tentativa, format = "%d%b%Y:%H:%M:%S"))]

# Time of day (morning, lunch break, afternoon, evening)
# TODO: rounding should take into account minutes
df[, hour_of_contact := hour(as.POSIXct(df$dt_hr_tentativa, format = "%d%b%Y:%H:%M:%S"))]
df = df[hour_of_contact != 4]
df[hour_of_contact < 12 , moment_in_day := 'morning']
df[hour_of_contact %between% c(12, 14) , moment_in_day := 'lunch']
df[hour_of_contact %between% c(15, 18) , moment_in_day := 'afternoon']
df[hour_of_contact > 18 , moment_in_day := 'evening']

# Hours between contact attempts
setkey(df, id_Cliente_A, dt_hr_int)
df[, lag_contact := shift(dt_hr_tentativa, n = 1, fill = -1, type = 'lag'), by = id_Cliente_A]
df[lag_contact == -1, diff_between_contacts := -1]
df[is.na(diff_between_contacts), diff_between_contacts := round(as.numeric(difftime(
                                                                  as.POSIXct(dt_hr_tentativa, format = "%d%b%Y:%H:%M:%S"), 
                                                                  as.POSIXct(lag_contact, format = "%d%b%Y:%H:%M:%S"),
                                                                units = 'hours')), 2)]
df[, lag_contact:= NULL]

# Is First attempt
df[, first_contact := 0]
df[diff_between_contacts == -1, first_contact := 1]

### END OF PRE PROCESSING

# View(df[1:10000, .SD, order(id_Cliente_A, dt_hr_int)])


# Target variable
# TODO: Handled has multiple reasons that might not belong to handled (ex: ~ 17% Sem contacto)
df[, target := 0]
df[outcome == 'handled', target := 1]

# Balance of target variable
df[target == 1, .N] / df[, .N]



















### PRE PROCESSING

preProcess = function(data_obj, preProcess_scope){

  print('Pre processing - Start')

  # TODO: CHECK NULLS
  # data_obj[data_obj$dt_hr_tentativa == '']
  # data_obj[data_obj$data_do_lote == '']
  print('Removing NA')
  data_obj = data_obj[data_obj$dt_hr_tentativa != '']
  data_obj = data_obj[data_obj$data_do_lote != '']


  print('Creating New Variables')
  # Date diff since lead created and lead contacted
  data_obj[, days_diff := as.numeric(as.Date(data_obj$dt_hr_tentativa, format = "%d%b%Y") -
                                       as.Date(data_obj$data_do_lote, format = "%Y-%m-%d"))]

  # Nr of contacts so far
  # Create timestamp (int) for fast sorting
  data_obj[, dt_hr_int := as.numeric(as.POSIXct(data_obj$dt_hr_tentativa, format = "%d%b%Y:%H:%M:%S"))]
  data_obj[, nr_contacts := frank(dt_hr_int, ties.method = 'first'), by=id_Cliente_A]
  data_obj[nr_contacts > 50, nr_contacts_bin := '[50+]']
  data_obj[nr_contacts %between% c(21, 50), nr_contacts_bin := '[21 - 50]']
  data_obj[nr_contacts %between% c(10, 20), nr_contacts_bin := '[10 - 20]']
  data_obj[nr_contacts < 10, nr_contacts_bin := as.character(nr_contacts)]



  # Phone type (mobile vs land line)
  data_obj[, phone_type := 'other']
  data_obj[substr(data_obj$indic_tlf_dest_A, start = 1, stop = 1) == 2, phone_type := 'land_phone']
  data_obj[substr(data_obj$indic_tlf_dest_A, start = 1, stop = 1) == 9, phone_type := 'land_phone']

  # Has multiple phone Nrs ?
  data_obj[, nr_unique_phones:= uniqueN(tlf_destino_A), by = id_Cliente_A]

  # Contact center Phone is same of customer ?
  # Contact center Phone is unknown ?
  data_obj[ , is_unknown := 0]
  data_obj[ , same_network := 0]
  data_obj[indic_tlf_ori_A == 'unknown', is_unknown := 1]
  data_obj[indic_tlf_dest_A == indic_tlf_ori_A, same_network := 1]

  # Day of the week
  data_obj[, day_of_week := weekdays(as.POSIXct(data_obj$dt_hr_tentativa, format = "%d%b%Y:%H:%M:%S"))]

  # Day of month
  data_obj[, day_of_month := as.integer(substr(data_obj$dt_hr_tentativa, start = 1, stop = 2))]

  # Month
  data_obj[, month := substr(data_obj$dt_hr_tentativa, start = 3, stop = 5)]

  # Time of day (morning, lunch break, afternoon, evening)
  # TODO: rounding should take into account minutes
  data_obj[, hour_of_contact := hour(as.POSIXct(data_obj$dt_hr_tentativa, format = "%d%b%Y:%H:%M:%S"))]
  data_obj = data_obj[hour_of_contact != 4]
  data_obj[hour_of_contact < 12 , moment_in_day := 'morning']
  data_obj[hour_of_contact %between% c(12, 14) , moment_in_day := 'lunch']
  data_obj[hour_of_contact %between% c(15, 18) , moment_in_day := 'afternoon']
  data_obj[hour_of_contact > 18 , moment_in_day := 'evening']

  # Hours between contact attempts
  setkey(data_obj, id_Cliente_A, dt_hr_int)
  data_obj[, lag_contact := shift(dt_hr_tentativa, n = 1, fill = -1, type = 'lag'), by = id_Cliente_A]
  data_obj[lag_contact == -1, diff_between_contacts := -1]
  data_obj[is.na(diff_between_contacts), diff_between_contacts := round(as.numeric(difftime(
    as.POSIXct(dt_hr_tentativa, format = "%d%b%Y:%H:%M:%S"),
    as.POSIXct(lag_contact, format = "%d%b%Y:%H:%M:%S"),
    units = 'hours')), 2)]

  # Is First attempt
  data_obj[, first_contact := 0]
  data_obj[diff_between_contacts == -1, first_contact := 1]

  # Binning of Hours between contact attempts
  # TODO: time between contacts does not consider contact center working hours and it should.
  data_obj[diff_between_contacts >= 24, diff_contacts_bin := '[24 - +Inf[']
  data_obj[diff_between_contacts %between% c(12, 24), diff_contacts_bin := '[12 - 24[']
  data_obj[diff_between_contacts %between% c(6, 11.99), diff_contacts_bin := '[06 - 12[']
  data_obj[diff_between_contacts %between% c(2, 5.99), diff_contacts_bin := '[02 - 06[']
  data_obj[diff_between_contacts %between% c(0.5, 2), diff_contacts_bin := '[0.5 - 02[']
  data_obj[diff_between_contacts < 0.5, diff_contacts_bin := '[0 - 0.5[']
  data_obj[first_contact == 1, diff_contacts_bin := 'First Contact']
  data_obj[, lag_contact:= NULL]

  # Target variable
  # TODO: Handled has multiple reasons that might not belong to handled (ex: ~ 17% Sem contacto)
  data_obj[, target := 0]
  data_obj[outcome == 'handled', target := 1]

  # Data Transformations for model usage
  if (preProcess_scope == 'model') {
    data_obj$target = as.character(data_obj$target)
    char_cols = names(which(sapply(data_obj, class) == 'character'))
    num_cols = names(which(sapply(data_obj, class) != 'character'))
    data_obj = cbind(data_obj[, num_cols, with=FALSE],
                     data_obj[, lapply(.SD, factor), .SDcols = char_cols])
    # v. few cases matching this condition
    data_obj = data_obj[! indic_tlf_dest_A %in% c(0, 31, 82)]
  }
  
  print('Pre processing - Finish')
  return(data_obj)
}


removeDependentVars = function(data_obj) {

  print('Removing dependent variables - Start')
  data_obj[, base := NULL]
  data_obj[, tipificacao := NULL]
  data_obj[, duracao := NULL]
  data_obj[, outcome := NULL]
  data_obj[, id_Cliente_A := NULL]
  data_obj[, tlf_destino_A := NULL]
  data_obj[, dt_hr_int := NULL]
  data_obj[, dt_hr_tentativa := NULL]

  print('Removing dependent variables - Finish')
  return(data_obj)

}


splitTrainData = function(data_obj, sample_size, train, test, validation) {

  print('Splitting data to train, test and validation - Start')
  set.seed(1)

  if (sample_size > nrow(data_obj)) {
    print('Sample Size > Data Population. Input diff sample size')
    break
  }
  
  population = seq(1, nrow(data_obj), 1)
  train_sample = sample(population, size = floor(sample_size * train), replace = FALSE)

  population = population[-train_sample]
  test_sample = sample(population, size = floor(sample_size * test), replace = FALSE)

  population = population[-test_sample]
  validation_sample = sample(population, size = floor(sample_size * validation), replace = FALSE)

  indexes = list(train_sample, test_sample, validation_sample)
  names(indexes) = c('train', 'test', 'validation')

  print('Splitting data to train, test and validation - Finish')
  
  return(indexes)

}

balanceData = function(data_obj, pos_ratio, neg_ratio) {
  
  nr_positives = floor(pos_ratio * nrow(data_obj))

  if(nr_positives > data_obj[target == 1, .N]) {
    # Downsample negative class
    nr_positives = data_obj[target == 1, .N]
    nr_negatives = floor(neg_ratio / pos_ratio * nr_positives)
  } else {
    nr_negatives = (1 / (1 - neg_ratio)) * nr_positives
  }
  
  set.seed(1)
  pos_df = sample(which(data_obj$target == 1), size = nr_positives, replace = FALSE)
  neg_df = sample(which(data_obj$target == 0), size = nr_negatives, replace = FALSE)

  return(rbind(data_obj[pos_df], data_obj[neg_df]))

}

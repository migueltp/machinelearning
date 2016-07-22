### KAGGLE
### BIMBO
### by: Miguel Serrano 04-07-2016

library(data.table)
setwd("Projects/Kaggle/Bimbo-Logistics/")
train_data <- fread("Data/train.csv", showProgress = TRUE) #, nrow = 100000
test_data <- fread("Data/test.csv" ,showProgress = TRUE) #, nrow = 10000
product <- fread("Data/producto_tabla.csv", showProgress = TRUE)
town <- fread("Data/town_state.csv", showProgress = TRUE)
clients <- fread("Data/cliente_tabla.csv", showProgress = TRUE)

# Training Data
my_stat <- train_data[,.N, by = 'Semana']
plot(my_stat, type = 'h') #, ylim = c(10000000,12000000)

# count nr weeks
my_stat <- train_data[,.N, by = 'Semana'] #7wk


# count by supermarkets
my_stat <- train_data[,.N, by = 'Agencia_ID'] #552 supermarkets
min(my_stat) #31 records
max(my_stat) #806283 records

# count by towns
train_data <- merge(x = train_data, y = town, by = 'Agencia_ID')
my_stat <- train_data[,.N, by = 'Town'] #257 towns
my_stat[order(N)] #31 records

# count by state
my_stat <- train_data[,.N, by = 'State'] #33 states
my_stat[order(N)] #319693 records

town[Town == '2089 AG. AZCAPOTZALCO INSTITUCIONALES']
train_data[Town == '2089 AG. AZCAPOTZALCO INSTITUCIONALES']
train_data[, .N, by = 'Cliente_ID']





# SUBMISSION 1 - Champ approach
# Goal: average of products being sold - products being returned

# Granularity of submission
nrow(test_data)
test_data[, .N, by = c('Semana', 'Agencia_ID', 'Producto_ID', 'Cliente_ID')]
test_data[, .N, by = c('Semana', 'Agencia_ID', 'Producto_ID')]

train_data




# Sales & Returns by wk @ Train Data
x <- train_data[, .('sales'=sum(Venta_uni_hoy),
                    'returns' = sum(Dev_uni_proxima),
                    'perc_return' = sum(Dev_uni_proxima)/sum(Venta_uni_hoy)),
                    by = 'Semana']

# Sales & Returns by wk & Product
y <- train_data[, .('sales'=sum(Venta_uni_hoy),
                    'returns' = sum(Dev_uni_proxima),
                    'perc_return' = round(sum(Dev_uni_proxima)/sum(Venta_uni_hoy), 4)),
                by = c('Semana', 'Producto_ID')]

y
t <- c(10,20,30,40,50)
z <- c(1,2,3,4,5)
a <- lm(t ~ z)


# 
test_data[,.N, by = 'Semana']

# dev.off()
# par(mar=c(5,4,4,5)+.1)
# plot(x = x$Semana, y = x$V1, type = 'l', col ='red', xlab = "Sales")
# par(new = TRUE)
# plot(x = x$Semana, y = y$V1, type = 'l', col ='blue', yaxt="n", xlab = "", ylab = "")
# axis(4)
# mtext("Returns", side = 4, line = 3)
# legend("topleft", col=c("red", "blue"), lty=1, legend=c("Sales, Returns"))

View(test_data[Producto_ID == 35305 & Agencia_ID == 4037 & Semana == 11])
# 
test_data
submission <- merge(x = test_data[,'Producto_ID', with = FALSE], 
      y = train_data[,  ifelse(ceiling(sum(Venta_uni_hoy - Dev_uni_proxima)) < 0, 0, ceiling(sum(Venta_uni_hoy - Dev_uni_proxima))), by = 'Producto_ID'], 
      by = 'Producto_ID', 
      all.x = TRUE)

submission[is.na(V1)]
test_data[,.N, by = 'Producto_ID']
test_data[Producto_ID == 31203]

test_data

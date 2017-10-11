library(data.table)
library(rpart)
library(class)
setwd(paste(getwd(), '/Projects/machinelearning/Scraps/R scrapbook/', sep=''))
source(file = paste(getwd(), '/nos_preprocess.R', sep = ''))

df = fread(input='~/data_store/ds/DESAFIO_ML_1.txt')

df_train = df[df$base == 'Treino']
# df_test = df[df$base == 'Teste']
df = df[! df$base %in% c('Teste', 'Treino')]

# df = preProcess(data_obj = df)
# df_train = preProcess(data_obj = df_train)
df_hist = preProcess(data_obj = df)
#View(df_hist[1:10000, .SD, order(id_Cliente_A, dt_hr_int)])




# Balance of target variable




### MODELLING
# Remove variables dependent to target or unavailable in test DF
df_train = removeDependentVars(data_obj = df_train)
indx = splitTrainData(data_obj = df_train, train = 0.6, test = 0.3, validation = 0.1)
length(indx[['train']])
length(indx[['test']])
length(indx[['validation']])



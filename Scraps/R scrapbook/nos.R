library(data.table)
library(rpart)
library(class)
library(caret)
library(e1071)
require(randomForest)
library(xgboost)
library(ROCR)


setwd('~/Projects/machinelearning/Scraps/R scrapbook/') 
source(file = paste(getwd(), '/nos_preprocess.R', sep = ''))
source(file = paste(getwd(), '/nos_models.R', sep = ''))

df = fread(input='~/data_store/ds/DESAFIO_ML_1.txt')

# Get train data
df_train = df[df$base == 'Treino']


# Pre Process
df_train = preProcess(data_obj = df_train, preProcess_scope = 'model')


### MODELLING
# Remove variables dependent to target or unavailable in test DF
df_train = removeDependentVars(data_obj = df_train)

# Balance data
# df_train = balanceData(data_obj = df_train, pos_ratio = 0.4, neg_ratio = 0.6)

# Split Train, test, validation
train_ratio = 0.7
test_ratio = 0.3 # Test size will be always the same (30% of entire population)
val_ratio = 0


### NAIVE BAYES
for (size in c(2000, 10000, 50000, 100000)) {

  index_split = splitTrainData(data_obj = df_train,
                               sample_size = size,
                               train = train_ratio,
                               test = test_ratio,
                               validation = val_ratio)

  res = naiveBayesModel(trainData = df_train[index_split[['train']]],
                        testData = df_train[index_split[['test']]],
                        misclassCosts = 0.5,
                        kwd_args = list())['results']
  if (! exists("naive_res")) {
    naive_res = as.data.table(res)
    next
  }

  naive_res = rbind(naive_res, as.data.table(res))

}

### DEC TREE
for (size in c(2000, 10000, 50000, 100000)) {

  index_split = splitTrainData(data_obj = df_train,
                               sample_size = size,
                               train = train_ratio,
                               test = test_ratio,
                               validation = val_ratio)

  res = dtModel(trainData = df_train[index_split[['train']]],
                testData = df_train[index_split[['test']]],
                misclassCosts = 0.5,
                kwd_args = list('maxdepth' = 10,
                               'cp' = -1))['results']

  if (! exists("dt_res")) {
    dt_res = as.data.table(res)
    next
  }

  dt_res = rbind(dt_res, as.data.table(res))

}


### RAND FORESTS
for (size in c(2000, 10000, 50000, 100000)) {
  
  index_split = splitTrainData(data_obj = df_train, 
                               sample_size = size,
                               train = train_ratio, 
                               test = test_ratio, 
                               validation = val_ratio)
  
  res = randForestModel(trainData = as.data.frame(df_train[index_split[['train']]]), 
                        testData = as.data.frame(df_train[index_split[['test']]]), 
                        misclassCosts = 0.5,
                        kwd_args = list('ntrees' = 50))['results']
  
  if (! exists("randf_res")) {
    randf_res = as.data.table(res)
    next
  }
  
  randf_res = rbind(randf_res, as.data.table(res))
  
}

### ROC CURVES
index_split = splitTrainData(data_obj = df_train, 
                             sample_size = 100000,
                             train = train_ratio, 
                             test = test_ratio, 
                             validation = val_ratio)

train_data = df_train[index_split[['train']]]
test_data = df_train[index_split[['test']]]

dt_model = dtModel(trainData = train_data,
                   testData = test_data,
                   misclassCosts = 0.5,
                   kwd_args = list('maxdepth' = 10, 'cp' = -1))['model']
                                 
rf_model = randForestModel(trainData = train_data, 
                           testData = test_data, 
                           misclassCosts = 0.5,
                           kwd_args = list('ntrees' = 50))['model']

for (class_cost in (seq(1, 9, 1) / 10)) {
  
  print(class_cost)
  dt_res = getRocValues(test_data = test_data, model = dt_model, 
                        model_name = 'DecTree', missclass = class_cost)

  rf_res = getRocValues(test_data = test_data, model = rf_model, 
                        model_name = 'RandForest', missclass = class_cost)
  

  if (! exists("roc_res")) {
    roc_res = rbind(dt_res, rf_res)
    next
  }
  
  roc_res = rbind(roc_res, rbind(dt_res, rf_res))
  
}


### PREDICT TEST DF
df_test = df[df$base == 'Teste']
# Pre Process
df_test = preProcess(data_obj = df_test, preProcess_scope = 'model')
# Remove variables dependent to target or unavailable in test DF
df_test = removeDependentVars(data_obj = df_test)

test_pred = predict(rf_model, as.data.frame(df_test), type='prob')
dt_test_prob = data.table(NO = test_pred$model[,1], YES = test_pred$model[,2])
dt_test_prob[, Vote:= ifelse(NO > 0.25, 0, 1)]
df_test = cbind(df_test, dt_test_prob)
write.csv(df_test, file = 'predictions.csv', row.names = FALSE)




library(data.table)
library(rpart)
library(class)
library(caret)
library(adabag)
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
df_train = balanceData(data_obj = df_train, pos_ratio = 0.4, neg_ratio = 0.6)

# Split Train, test, validation
nr_cases = 10000
train_ratio = 0.6
test_ratio = 0.4
val_ratio = 0
set.seed(1)


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
                kwd_args = list('maxdepth' = 30,
                               'cp' = -1))['results']
  
  if (! exists("dt_res")) {
    dt_res = as.data.table(res)
  }
  
  dt_res = rbind(dt_res, as.data.table(res))
  
}

### ADABOOST
for (size in c(2000, 10000, 50000, 100000)) {
  
  index_split = splitTrainData(data_obj = df_train, 
                               sample_size = size,
                               train = train_ratio, 
                               test = test_ratio, 
                               validation = val_ratio)
  
  res = adaboostModel(trainData = as.data.frame(df_train[index_split[['train']]]), 
                        testData = as.data.frame(df_train[index_split[['test']]]), 
                        misclassCosts = 0.5,
                        kwd_args = list())['results']

  if (! exists("adab_res")) {
    adab_res = as.data.table(res)
  }
  
  adab_res = rbind(adab_res, as.data.table(res))
  
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
                        kwd_args = list())['results']
  
  if (! exists("randf_res")) {
    randf_res = as.data.table(res)
  }
  
  randf_res = rbind(randf_res, as.data.table(res))
  
}


### XGBoost
for (size in c(2000, 10000, 50000, 100000)) {
  
  index_split = splitTrainData(data_obj = df_train, 
                               sample_size = size,
                               train = train_ratio, 
                               test = test_ratio, 
                               validation = val_ratio)
  
  params = list(booster = 'gbtree',
                max_depth = 30,
                nthreads = 4,
                eta = 0.5,
                objective = 'binary:logistic', 
                eval.metric = 'auc',
                verbose = TRUE)
  
  res = xgboostModel(trainData = as.data.frame(df_train[index_split[['train']]]), 
                     testData = as.data.frame(df_train[index_split[['test']]]), 
                     misclassCosts = 0.5,
                     kwd_args = params)['results']
  
  if (! exists("xgb_res")) {
    xgb_res = as.data.table(res)
  }
  
  xgb_res = rbind(xgb_res, as.data.table(res))
  
}


# PLOT ROC CURVES

naive_res = naive_res[order(`results.True Positive Rate`)]
dt_res = dt_res[order(`results.True Positive Rate`)]

p <- ggplot(data = naive_res, 
            aes(x = naive_res$`results.False Positive Rate`,y = naive_res$`results.True Positive Rate`)) +
            xlim(0, 1) + ylim(0, 1) +
            geom_line(stat = 'identity', colour='green') +
            geom_abline(intercept = 0, slope = 1, show.legend = NA) + 
            geom_text(aes(x = 0.20, y = 0.45, label = "Naive B."), colour = 'green', show.legend=FALSE)

p = p +
            geom_line(aes(x = dt_res$`results.False Positive Rate`, 
                          y = dt_res$`results.True Positive Rate`, 
                          colour='red'), data = dt_res) +
            geom_text(aes(x = 0.38, y = 0.55, label = "Dec Tree"), colour = 'red', show.legend=FALSE)

p = p + 
  ggtitle('ROC curves for Balanced Data') + 
  theme(plot.title = element_text(hjust = 0.5)) +
  xlab('False Positive Rate') +
  ylab('True Positive Rate')
ggsave(filename = 'ROC curves Balanced.png', 
       width=20, height = 20, units = 'cm', 
       plot = p, 
       device = 'png',
       scale = 1)


### Adaboost, Rand Forest
adab_res = adab_res[order(`results.True Positive Rate`)]
randf_res = randf_res[order(`results.True Positive Rate`)]

p <- ggplot(data = adab_res, 
            aes(x = adab_res$`results.False Positive Rate`,y = adab_res$`results.True Positive Rate`)) +
  xlim(0, 1) + ylim(0, 1) +
  geom_line(stat = 'identity', colour='green') +
  geom_abline(intercept = 0, slope = 1, show.legend = NA) + 
  geom_text(aes(x = 0.20, y = 0.45, label = "Adaboost DT"), colour = 'green', show.legend=FALSE)

p = p +
  geom_line(aes(x = randf_res$`results.False Positive Rate`, 
                y = randf_res$`results.True Positive Rate`, 
                colour='red'), data = randf_res) +
  geom_text(aes(x = 0.38, y = 0.55, label = "Rand Forest"), colour = 'red', show.legend=FALSE)

p = p + 
  ggtitle('ROC curves for Boosting & Bagging') + 
  theme(plot.title = element_text(hjust = 0.5)) +
  xlab('False Positive Rate') +
  ylab('True Positive Rate')
ggsave(filename = 'ROC curves Boosting & Bagging', 
       width=20, height = 20, units = 'cm', 
       plot = p, 
       device = 'png',
       scale = 1)

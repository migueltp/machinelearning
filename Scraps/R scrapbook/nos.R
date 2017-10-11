library(data.table)
library(rpart)
library(class)
library(caret)
library(adabag)
require(randomForest)
setwd('~/Projects/machinelearning/Scraps/R scrapbook/') 
source(file = paste(getwd(), '/nos_preprocess.R', sep = ''))

df = fread(input='~/data_store/ds/DESAFIO_ML_1.txt')

df_train = df[df$base == 'Treino']
# df_test = df[df$base == 'Teste']
# df = df[! df$base %in% c('Teste', 'Treino')]

df_train = preProcess(data_obj = df_train)
# df_hist = preProcess(data_obj = df)



### MODELLING
# Remove variables dependent to target or unavailable in test DF
df_train = removeDependentVars(data_obj = df_train)
train_ratio = 0.6
test_ratio = 0.3
val_ratio = 0.1
index_split = splitTrainData(data_obj = df_train, train = train_ratio, test = test_ratio, validation = val_ratio)





set.seed(1)
df_train$target = as.character(df_train$target)
trainData = df_train[index_split[['train']]]
testData = df_train[index_split[['test']]]



trainData$data_do_lote = factor(trainData$data_do_lote)
trainData$diff_contacts_bin = factor(trainData$diff_contacts_bin)
trainData$nr_contacts_bin = factor(trainData$nr_contacts_bin)
trainData$phone_type = factor(trainData$phone_type)
trainData$target = factor(trainData$target)
sapply(trainData, class)


t = Sys.time()
# rpartModel <- rpart(target ~.,trainData, 
#                     maxdepth=20,
#                     parms = list(split = 'information'),
#                     cp=-1,
#                     xval=10,
#                     maxcompete=3,
#                     method = 'class',
#                     minsplit=50,
#                     minbucket=10)


adaboostModel <- boosting(target ~., as.data.frame(trainData[1:10000]),mfinal=10, control=rpart.control(maxdepth=30))
print(paste('Training Done. Elapsed ::', round(Sys.time() - t, 2), sep = ''))

### @ Training Set
# Apply Model
adTrainPred <- predict(adaboostModel, as.data.frame(trainData[1:1000]),type="prob")
adTrainProb <- data.table(NO = adTrainPred$prob[,1], YES = adTrainPred$prob[,2])
misclassCosts = 0.50
adTrainProb[, Vote:= ifelse(NO > misclassCosts,'NO','YES')]

# At least one YES Classification
if(adTrainProb[Vote == 'NO', .N] == nrow(adTrainProb)) {
  adTrainProb[1, Vote:= 'YES']
}
# Confusion Matrix

tbTrain <<- table(adTrainProb[,Vote], trainData$target[1:1000])
# Global Accuracy
errorTrain <- 1-(sum(diag(tbTrain))/sum(tbTrain))
# Recall at Positive class
recallTrain <- tbTrain[2,2]/sum(tbTrain[,2])
tbTrain


t = Sys.time()
# rpartModel <- rpart(target ~.,trainData, 
#                     maxdepth=20,
#                     parms = list(split = 'information'),
#                     cp=-1,
#                     xval=10,
#                     maxcompete=3,
#                     method = 'class',
#                     minsplit=50,
#                     minbucket=10)


adaboostModel <- boosting(target ~., as.data.frame(trainData[1:10000]),mfinal=10, control=rpart.control(maxdepth=30))
print(paste('Training Done. Elapsed ::', round(Sys.time() - t, 2), sep = ''))

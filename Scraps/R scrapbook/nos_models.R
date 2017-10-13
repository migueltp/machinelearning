### NAIVE BAYES
naiveBayesModel <- function(trainData, testData, misclassCosts, kwd_args) {

  ### Training Set
  t = Sys.time()
  print('naiveBayesModel - Training')
  train_labels = trainData$target
  model = naiveBayes(target ~ ., data = trainData, type = c("class", "raw"))
  print(paste('Training Done. Elapsed ::', difftime(Sys.time(), t, units = 'sec'), sep = ''))

  t = Sys.time()
  train_pred = predict(model, as.data.frame(trainData), type='raw')
  print(paste('Predicting Training Data Done. Elapsed ::', difftime(Sys.time(), t, units = 'sec'), sep = ''))

  dt_train_prob = data.table(NO = train_pred[,1], YES = train_pred[,2])
  dt_train_prob[, Vote:= ifelse(NO > misclassCosts, 'NO', 'YES')]

  # At least one YES Classification
  if(dt_train_prob[Vote == 'NO', .N] == nrow(dt_train_prob)) {
    dt_train_prob[1, Vote:= 'YES']
  }
  # Confusion Matrix

  tbTrain <<- table(dt_train_prob[,Vote], train_labels)
  # Global Accuracy
  errorTrain = 1-(sum(diag(tbTrain))/sum(tbTrain))
  # Recall at Positive class
  recallTrain = tbTrain[2,2]/sum(tbTrain[,2])


  ### Testing Set
  test_labels = testData$target
  t = Sys.time()
  test_pred = predict(model, as.data.frame(testData), type='raw')
  print(paste('Predicting Testing Data Done. Elapsed ::', difftime(Sys.time(), t, units = 'sec'), sep = ''))

  dt_test_prob = data.table(NO = test_pred[,1], YES = test_pred[,2])
  dt_test_prob[, Vote:= ifelse(NO > misclassCosts,'NO','YES')]

  # At least one YES Classification
  if(dt_test_prob[Vote == 'NO', .N] == nrow(dt_test_prob)) {
    dt_test_prob[1, Vote:= 'YES']
  }

  # First Argument @Rows, Second Argument @Cols
  tbTest <<- table(dt_test_prob[,Vote], test_labels)
  # Global Accuracy
  errorTest <- 1-(sum(diag(tbTest))/sum(tbTest))
  # Recall at Positive class
  recallPTest <- tbTest[2,2]/sum(tbTest[,2])
  # Recall at Negative class
  recallNTest <- tbTest[1,1]/sum(tbTest[,1])

  # True Positive Rate
  # Same as Test + Recall

  # False Positive Rate // # False Negative Rate
  FP <- tbTest[2,1]/sum(tbTest[,1])
  FN <- tbTest[1,2]/sum(tbTest[,2])

  modelResults <- data.table('Technique' = 'Naive Bayes', 'Nr_Train_Cases' = nrow(trainData),
                       'Nr_Test_Cases' = nrow(testData),
                       'Train Error' = errorTrain, 'Test Error' = errorTest,
                       'True Positive Rate' = recallPTest, 'False Positive Rate' = FP,
                       'True Negative Rate' = recallNTest, 'False Negative Rate' = FN)

  return(list('results' = modelResults, 'model' = model))

}


### DECISION TREE
dtModel <- function(trainData, testData, misclassCosts, kwd_args) {

  ### Training Set
  t = Sys.time()
  print('dtModel - Training')
  model <- rpart(target ~.,as.data.frame(trainData),
                 maxdepth=kwd_args['maxdepth'],
                 parms = list(split = 'information'),
                 cp=kwd_args['cp'],
                 xval=10,
                 method = 'class'
                 )

  print(paste('Training Done. Elapsed ::', difftime(Sys.time(), t, units = 'sec'), sep = ''))

  t = Sys.time()
  train_pred = predict(model, as.data.frame(trainData), type='prob')
  print(paste('Predicting Training Data Done. Elapsed ::', difftime(Sys.time(), t, units = 'sec'), sep = ''))

  dt_train_prob = data.table(NO = train_pred[,1], YES = train_pred[,2])
  dt_train_prob[, Vote:= ifelse(NO > misclassCosts, 'NO', 'YES')]

  # At least one YES Classification
  if(dt_train_prob[Vote == 'NO', .N] == nrow(dt_train_prob)) {
    dt_train_prob[1, Vote:= 'YES']
  }
  # Confusion Matrix
  tbTrain <<- table(dt_train_prob[,Vote], trainData$target)
  # Global Accuracy
  errorTrain = 1-(sum(diag(tbTrain))/sum(tbTrain))
  # Recall at Positive class
  recallTrain = tbTrain[2,2]/sum(tbTrain[,2])


  ### Testing Set
  t = Sys.time()
  test_pred = predict(model, as.data.frame(testData), type='prob')
  print(paste('Predicting Testing Data Done. Elapsed ::', difftime(Sys.time(), t, units = 'sec'), sep = ''))

  dt_test_prob = data.table(NO = test_pred[,1], YES = test_pred[,2])
  dt_test_prob[, Vote:= ifelse(NO > misclassCosts,'NO','YES')]

  # At least one YES Classification
  if(dt_test_prob[Vote == 'NO', .N] == nrow(dt_test_prob)) {
    dt_test_prob[1, Vote:= 'YES']
  }
  # Confusion Matrix
  tbTest <<- table(dt_test_prob[,Vote], testData$target)
  # Global Accuracy
  errorTest <- 1-(sum(diag(tbTest))/sum(tbTest))
  # Recall at Positive class
  recallPTest <- tbTest[2,2]/sum(tbTest[,2])
  # Recall at Negative class
  recallNTest <- tbTest[1,1]/sum(tbTest[,1])

  # True Positive Rate
  # Same as Test + Recall

  # False Positive Rate // # False Negative Rate
  FP <- tbTest[2,1]/sum(tbTest[,1])
  FN <- tbTest[1,2]/sum(tbTest[,2])

  modelResults <- data.table('Technique' = 'Dec Tree', 'Nr_Train_Cases' = nrow(trainData),
                       'Nr_Test_Cases' = nrow(testData),
                       'Train Error' = errorTrain, 'Test Error' = errorTest,
                       'True Positive Rate' = recallPTest, 'False Positive Rate' = FP,
                       'True Negative Rate' = recallNTest, 'False Negative Rate' = FN)

  return(list('results' = modelResults, 'model' = model))

}


### Adaboost
adaboostModel <- function(trainData, testData, misclassCosts, kwd_args) {

  ### Training Set
  t = Sys.time()
  print('Adaboost - Training')
  model = boosting(target ~., as.data.frame(trainData),
                   mfinal=200,
                   control=rpart.control(maxdepth=30))
  print(paste('Training Done. Elapsed ::', difftime(Sys.time(), t, units = 'sec'), sep = ''))

  t = Sys.time()
  train_pred = predict(model, as.data.frame(trainData), type='prob')
  print(paste('Predicting Training Data Done. Elapsed ::', difftime(Sys.time(), t, units = 'sec'), sep = ''))

  dt_train_prob = data.table(NO = train_pred$prob[,1], YES = train_pred$prob[,2])
  dt_train_prob[, Vote:= ifelse(NO > misclassCosts, 'NO', 'YES')]

  # At least one YES Classification
  if(dt_train_prob[Vote == 'NO', .N] == nrow(dt_train_prob)) {
    dt_train_prob[1, Vote:= 'YES']
  }
  # Confusion Matrix
  tbTrain <<- table(dt_train_prob[,Vote], trainData$target)
  # Global Accuracy
  errorTrain = 1-(sum(diag(tbTrain))/sum(tbTrain))
  # Recall at Positive class
  recallTrain = tbTrain[2,2]/sum(tbTrain[,2])


  ### Testing Set
  t = Sys.time()
  test_pred = predict(model, as.data.frame(testData), type='prob')
  print(paste('Predicting Testing Data Done. Elapsed ::', difftime(Sys.time(), t, units = 'sec'), sep = ''))

  dt_test_prob = data.table(NO = test_pred$prob[,1], YES = test_pred$prob[,2])
  dt_test_prob[, Vote:= ifelse(NO > misclassCosts,'NO','YES')]

  # At least one YES Classification
  if(dt_test_prob[Vote == 'NO', .N] == nrow(dt_test_prob)) {
    dt_test_prob[1, Vote:= 'YES']
  }
  # Confusion Matrix
  tbTest <<- table(dt_test_prob[,Vote], testData$target)
  # Global Accuracy
  errorTest <- 1-(sum(diag(tbTest))/sum(tbTest))
  # Recall at Positive class
  recallPTest <- tbTest[2,2]/sum(tbTest[,2])
  # Recall at Negative class
  recallNTest <- tbTest[1,1]/sum(tbTest[,1])

  # True Positive Rate
  # Same as Test + Recall

  # False Positive Rate // # False Negative Rate
  FP <- tbTest[2,1]/sum(tbTest[,1])
  FN <- tbTest[1,2]/sum(tbTest[,2])

  modelResults <- data.table('Technique' = 'Adaboost', 'Nr_Train_Cases' = nrow(trainData),
                       'Nr_Test_Cases' = nrow(testData),
                       'Train Error' = errorTrain, 'Test Error' = errorTest,
                       'True Positive Rate' = recallPTest, 'False Positive Rate' = FP,
                       'True Negative Rate' = recallNTest, 'False Negative Rate' = FN)

  return(list('results' = modelResults, 'model' = model))


}


### Random Forests
randForestModel <- function(trainData, testData, misclassCosts, kwd_args) {

  ### Training Set
  t = Sys.time()
  print('Rand Forest - Training')
  model = randomForest(target ~., as.data.frame(trainData), ntrees=100)
  print(paste('Training Done. Elapsed ::', difftime(Sys.time(), t, units = 'sec'), sep = ''))

  t = Sys.time()
  train_pred = predict(model, as.data.frame(trainData), type='prob')
  print(paste('Predicting Training Data Done. Elapsed ::', difftime(Sys.time(), t, units = 'sec'), sep = ''))

  dt_train_prob = data.table(NO = train_pred[,1], YES = train_pred[,2])
  dt_train_prob[, Vote:= ifelse(NO > misclassCosts, 'NO', 'YES')]

  # At least one YES Classification
  if(dt_train_prob[Vote == 'NO', .N] == nrow(dt_train_prob)) {
    dt_train_prob[1, Vote:= 'YES']
  }
  # Confusion Matrix
  tbTrain <<- table(dt_train_prob[,Vote], trainData$target)
  # Global Accuracy
  errorTrain = 1-(sum(diag(tbTrain))/sum(tbTrain))
  # Recall at Positive class
  recallTrain = tbTrain[2,2]/sum(tbTrain[,2])


  ### Testing Set
  t = Sys.time()
  test_pred = predict(model, as.data.frame(testData), type='prob')
  print(paste('Predicting Testing Data Done. Elapsed ::', difftime(Sys.time(), t, units = 'sec'), sep = ''))

  dt_test_prob = data.table(NO = test_pred[,1], YES = test_pred[,2])
  dt_test_prob[, Vote:= ifelse(NO > misclassCosts,'NO','YES')]

  # At least one YES Classification
  if(dt_test_prob[Vote == 'NO', .N] == nrow(dt_test_prob)) {
    dt_test_prob[1, Vote:= 'YES']
  }
  # Confusion Matrix
  tbTest <<- table(dt_test_prob[,Vote], testData$target)
  # Global Accuracy
  errorTest <- 1-(sum(diag(tbTest))/sum(tbTest))
  # Recall at Positive class
  recallPTest <- tbTest[2,2]/sum(tbTest[,2])
  # Recall at Negative class
  recallNTest <- tbTest[1,1]/sum(tbTest[,1])

  # True Positive Rate
  # Same as Test + Recall

  # False Positive Rate // # False Negative Rate
  FP <- tbTest[2,1]/sum(tbTest[,1])
  FN <- tbTest[1,2]/sum(tbTest[,2])

  modelResults <- data.table('Technique' = 'Rand Forest', 'Nr_Train_Cases' = nrow(trainData),
                       'Nr_Test_Cases' = nrow(testData),
                       'Train Error' = errorTrain, 'Test Error' = errorTest,
                       'True Positive Rate' = recallPTest, 'False Positive Rate' = FP,
                       'True Negative Rate' = recallNTest, 'False Negative Rate' = FN)

  return(list('results' = modelResults, 'model' = model))

}

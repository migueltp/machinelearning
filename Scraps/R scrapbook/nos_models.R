### MODELS
dtModel <- function(trainData, testData, it, misclassCosts) {
  
  # Train Recursive Part Tree -->> Outter Loop @ Adaboost
  trainData = df_train[indx[['train']]]
  rpartModel <- rpart(target ~.,trainData, maxdepth=20, method = 'class')
  
  
  ### @ Training Set
  
  # Apply Model
  adTrainPred <- predict(rpartModel,trainData,type="prob")
  adTrainProb <- data.table(NO = adTrainPred[,1], YES = adTrainPred[,2])
  misclassCosts = 0.50
  adTrainProb[, Vote:= ifelse(NO > misclassCosts,'NO','YES')]
  
  # At least one YES Classification
  if(adTrainProb[Vote == 'NO', .N] == nrow(adTrainProb)) {
    adTestProb[1, Vote:= 'YES']
  }
  
  # Confusion Matrix
  tbTrain <<- table(adTrainProb[,Vote], trainData$target)
  # Global Accuracy
  errorTrain <- 1-(sum(diag(tbTrain))/sum(tbTrain))
  # Recall at Positive class
  recallTrain <- tbTrain[2,2]/sum(tbTrain[,2])
  
  ### @ Testing Set
  
  # Apply Model
  testData = df_train[indx[['test']]]
  adTestPred <- predict(rpartModel,testData,type="prob")
  adTestProb <- data.table(NO = adTestPred[,1], YES = adTestPred[,2])
  adTestProb[, Vote:= ifelse(NO > misclassCosts,'NO','YES')]
  
  # At least one YES Classification
  if(adTestProb[Vote == 'NO', .N] == nrow(adTestProb)) {
    adTestProb[1, Vote:= 'YES']
  }
  
  # First Argument @Rows, Second Argument @Cols
  tbTest <<- table(adTestProb[,Vote], testData$CONVERSION)
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
  
  modelResults <- list('Technique' = 'Dec. Tree', 'Percentage' = it, 'Nr_Train_Cases' = nrow(trainData), 'Train Error' = errorTrain,
                       'Test Error' = errorTest, 'True Positive Rate' = recallPTest, 'False Positive Rate' = FP,
                       'True Negative Rate' = recallNTest, 'False Negative Rate' = FN)
  
  
  return(modelResults)
}

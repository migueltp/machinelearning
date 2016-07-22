### FUNCTIONS


getStratifiedSample <- function(data, sampleSize) {
  
  yesIndexes <- which(data$CONVERSION == 'YES')
  noIndexes <- which(data$CONVERSION == 'NO')
  ratio <- length(yesIndexes) / (length(yesIndexes) + length(noIndexes))
  
  totYes <- floor(sampleSize * ratio)
  totNo <- floor(sampleSize * (1-ratio))
  set.seed(1231)
  yes <- sample(x = yesIndexes, size = totYes, replace = FALSE)
  set.seed(1231)
  no <- sample(x = noIndexes, size = totNo, replace = FALSE)
  
  this <- data.table(rbind(cbind(yes, 1), cbind(no, 0)))
  setnames(this, old = names(this), new = c('ID_unit', 'CONVERSION'))
  this[, ID_unit := as.integer(ID_unit)]
  this[, CONVERSION := as.factor(CONVERSION)]
  return(this)
  
}

dtModel <- function(trainData, testData, it, misclassCosts) {
  
  # Train Recursive Part Tree -->> Outter Loop @ Adaboost
  rpartModel <- rpart(CONVERSION ~.,trainData, maxdepth=20)
  
  
  ### @ Training Set
  
  # Apply Model
  adTrainPred <- predict(rpartModel,trainData,type="prob")
  adTrainProb <- data.table(NO = adTrainPred[,1], YES = adTrainPred[,2])
  adTrainProb[, Vote:= ifelse(NO > misclassCosts,'NO','YES')]
  
  # At least one YES Classification
  if(adTrainProb[Vote == 'NO', .N] == nrow(adTrainProb)) {
    adTestProb[1, Vote:= 'YES']
  }
  
  # Confusion Matrix
  tbTrain <<- table(adTrainProb[,Vote], trainData$CONVERSION)
  # Global Accuracy
  errorTrain <- 1-(sum(diag(tbTrain))/sum(tbTrain))
  # Recall at Positive class
  recallTrain <- tbTrain[2,2]/sum(tbTrain[,2])
  
  ### @ Testing Set
  
  # Apply Model
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

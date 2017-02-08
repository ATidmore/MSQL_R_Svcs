mod <- unserialize(as.raw(LogitMod.loc))
mod.id <- modelid

#print(summary(mod))
InputDataSet <- LoanStats.tst
mod <- LogitMod.loc

test.data <- InputDataSet

print(str(test.data))


Scores<- predict.glm(mod, test.data, type = "response")

OutputDataSet <- data.frame(test.data$id,test.data$successfully_paid,Scores)

library(caret)
confusionMatrix(data = ifelse(OutputDataSet$Scores <= 0.4,0,1), ref = OutputDataSet$test.data.successfully_paid)

library(ROCR) 
pred <- ROCR::prediction(OutputDataSet$Scores, OutputDataSet$test.data.successfully_paid)
perf <- performance(pred,"tpr","fpr")
plot(perf)
abline(a=0,b=1)
dev.off()

# Print Area under the Curve
auc <- performance(pred, "auc")
print(paste0("Area under ROC Curve : ", as.numeric(auc@y.values)))


# RxPredict
rxPred <- rxPredict(modelObject = rxLogitMod, data = InputDataSet, outData = NULL,  predVarNames = "Score", type = "response", writeModelVars = FALSE, overwrite = TRUE)

rxPred.results <- cbind(InputDataSet, rxPred)

rxpred <- ROCR::prediction(rxPred.results$Score, rxPred.results$successfully_paid)
rxperf <- performance(pred,"tpr","fpr")
plot(rxperf)
abline(a=0,b=1)
dev.off()

# Print Area under the Curve
auc <- performance(pred, "auc")
print(paste0("Area under ROC Curve : ", as.numeric(auc@y.values)))


# Random Forest
library(randomForest)
InputDataSet$newpur <- factor(InputDataSet$purpose, levels = purp.lev )
#levels(InputDataSet$purpose) <- rfMod.loc$forest$xlevels["purpose"]
rfPred <- predict(rfMod.loc, newdata = InputDataSet, type = "prob")
rfPred.results <- cbind(InputDataSet, rfPred[ ,1])

rf.pred <- ROCR::prediction(rfPred.results["rfPred[, 1]"], rfPred.results$successfully_paid)
rfperf <- performance(rf.pred,"tpr","fpr")
plot(rfperf)
abline(a=0,b=1)

auc <- performance(rf.pred, "auc")
print(paste0("Area under ROC Curve : ", as.numeric(auc@y.values)))

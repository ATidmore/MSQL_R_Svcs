# R replication of TrainModel.sql #

library(ROSE, quietly = T)
library(ROCR, quietly = T)
library(caret, quiet = T)

InputDataSet <- LoanStats.loc


InputDataSet$purpose <- as.factor(InputDataSet$purpose)
InputDataSet$successfully_paid <- as.factor(InputDataSet$successfully_paid)

prop.table(table(InputDataSet$successfully_paid))

# ROSE
data.rose <- ROSE(successfully_paid ~ dti + annual_inc+ newpur + mort_acc + inq_last_6mths, data = InputDataSet, seed =3)$data

prop.table(table(data.rose$successfully_paid))

data.rose.samp <- data.rose[sample(nrow(data.rose),10000) ,]

LR.mod <- train(successfully_paid ~ ., data = data.rose.samp, family = "binomial")


# BLR
BLR.mod <- train(successfully_paid ~ dti + annual_inc + purpose + mort_acc + inq_last_6mths, data = InputDataSet,family = "LogitBoost" )

## Create model  - RevoScaleR
rxLogitMod <- rxLogit(successfully_paid ~ dti + annual_inc + mort_acc + inq_last_6mths, data = data.rose)  
summary(LogitMod)

rxRF <- rxDForest(as.factor(successfully_paid) ~ inq_last_6mths + mort_acc + dti + annual_inc + purpose, data = data.rose)
## Create model - base R
LogitMod.loc <- glm(successfully_paid ~ dti + annual_inc  + mort_acc + inq_last_6mths , data = data.rose, family = "binomial" )

summary(LogitMod.loc)

## Create Model - base R rand forest
library(randomForest)
rfTrainData <- data.rose
rfTrainData$purpose <- as.factor(rfTrainData$purpose)
#set Test levels to equal Train to avoid error
levels(InputDataSet$purpose) <- levels(rfTrainData$purpose)

rfMod.loc <- randomForest(as.factor(successfully_paid) ~ inq_last_6mths + mort_acc + dti + annual_inc + newpur, data = rfTrainData, importance = TRUE, ntree = 100 )



## Serialize model and put it in data frame  
trained_model <- data.frame(model=as.raw(serialize(LogitMod, NULL)), desc=paste("what up",""))

rxSetComputeContext("local")


#===================
## Load Libraries
#===================
rm(list = ls()) #clear environment

# libraries
packages <- c('ggplot2', 'corrplot','tidyverse',"caret","dummies","fastDummies",'grid'
              ,'FactoMineR','factoextra','readxl','scales','dplyr','mlbench','caTools',
              'gridExtra','doParallel')
# load packages
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}

#===================
## Load data
#===================
train <- read.csv("train.csv")
test <- read.csv("test.csv")
tokens <- read.csv("tokens.csv")


set.seed(2020)

#model training
cl <- makePSOCKcluster(4)
registerDoParallel(cl)

# cross fold validation
control <- trainControl(method="repeatedcv", number=10, repeats=5, classProbs = FALSE)

fit.glm <- train(affinity~., data=train, method="glm",metric = "RMSE", trControl = control)
#random forest
fit.rf <- train(affinity~., data=train, method="rf", 
                metric = "RMSE", trControl = control)
#boosting algorithm - Stochastic Gradient Boosting (Generalized Boosted Modeling)
fit.gbm <- train(affinity~., data=train, method="gbm", 
                 metric = "RMSE", trControl = control)
#svm
fit.svm <- train(affinity~., data=train, method="svmRadial", 
                 metric = "RMSE", trControl = control)
#nnet
fit.nnet <- train(affinity~., data=train, method="nnet", 
                  metric = "RMSE", trControl = control)
#naive
fit.naive <- train(affinity~., data=train, 
                   method="naive_bayes", metric = "RMSE", 
                   trControl = control)
#extreme gradient boosting
fit.xgb <- train(affinity~., data=train, 
                 method="xgbTree", metric = "RMSE", trControl = control)
#bagged cart
fit.bg <- train(affinity~., data=train, 
                method="treebag", metric = "RMSE", trControl = control)
#decision tree
fit.dtree <- train(affinity~., data=train, 
                   method="C5.0", metric = "RMSE", trControl = control)
#knn
fit.knn <- train(affinity~., data=train, 
                 method="kknn", metric = "RMSE", trControl = control)
#ensemble
fit.ensemble <- train(affinity~., data=train, 
                      method="nodeHarvest", metric = "RMSE", trControl = control)

stopCluster(cl)


#------------------
#compare models
#------------------
results <- resamples(list(randomforest = fit.rf, 
                          `gradient boost` = fit.gbm, 
                          `support vector machine` = fit.svm,
                          baggedCart = fit.bg, 
                          neuralnetwork = fit.nnet,
                          xgboost = fit.xgb, 
                          logisticregression = fit.glm, 
                          #`decision tree` = fit.dtree, 
                          #`naive bayes` = fit.naive,
                          #`ensemble` = fit.ensemble, 
                          `knn` = fit.knn))

summary(results)
# boxplot comparison
bwplot(results)
# Dot-plot comparison
dotplot(results)
# Make predictions
prediction <- fit.xgb %>% predict(test)

output

#variable importance
caret::varImp(fit.xgb)

#output
output <- cbind(test,prediction)
colnames(output) <- c('buyer','tokenid','affinity')
write.csv(output,"prediction.csv",row.names = FALSE)
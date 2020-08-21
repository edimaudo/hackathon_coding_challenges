#clear environment
rm(list=ls())

packages <- c('ggplot2','corrplot','tidyr',
    'tidyverse','dplyr','scales','catboost',
    'xgboost','caret','dummies','mlbench','Matrix','data.table')

#load packages
for (package in packages) {
  if (!require(package, character.only = T, quietly = T)) {
    install.packages(package)
    library(package, character.only = T)
  }
}

#load data
train <- read_csv("train.csv")
test <- read_csv("test.csv")
test_solutions <- read_csv("test_solutions.csv")
test <- cbind(test, test_solutions)

#check for missing data
missing_data_train <- apply(train, 2, function(x) any(is.na(x))) 
print(missing_data_train) #no missing data

missing_data_test <- apply(test, 2, function(x) any(is.na(x))) 
print(missing_data_test) #no missing data

#================
#EDA
#================
summary(train)
summary(test)

#correlation
corinfo <- train
corrplot(cor(corinfo), method="number")

#normalized data
normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}

#================
#Approach catboost using normalized data
#================
#generate targets
Target_train_pm <- train$pm
Target_train_stator_tooth <- train$stator_tooth
Target_train_stator_yoke <- train$stator_yoke
Target_train_stator_winding <- train$stator_winding

Target_test_pm <- test$pm
Target_test_stator_tooth <- test$stator_tooth
Target_test_stator_yoke <- test$stator_yoke
Target_test_stator_winding <- test$stator_winding

#train information normalizing
df_train<- train[,c(1:8)]
df_train_cts <- as.data.frame(lapply(df_train, normalize))

#test information normalized
df_test<- test[,c(1:8)]
df_test_cts <- as.data.frame(lapply(df_test, normalize))



params <- list(iterations=500,
               learning_rate=0.01,
               depth=10,
               loss_function='RMSE',
               eval_metric='RMSE',
               random_seed = 55,
               od_type='Iter',
               metric_period = 50,
               od_wait=20,
               use_best_model=TRUE)

#build pm model
train_pool <- catboost.load_pool(data = df_train, label = Target_train_pm)
test_pool <- catboost.load_pool(data = df_test, label = Target_test_pm)
model <- catboost.train(train_pool,test_pool ,params = params)
y_pred=catboost.predict(model,test_pool)
postResample(y_pred,test$pm)

#build stator tooth model
train_pool <- catboost.load_pool(data = df_train, label = Target_train_stator_tooth)
test_pool <- catboost.load_pool(data = df_test, label = Target_test_stator_tooth)
model <- catboost.train(train_pool,test_pool ,params = params)
y_pred=catboost.predict(model,test_pool)
postResample(y_pred,test$stator_tooth)

#build stator yoke model
train_pool <- catboost.load_pool(data = df_train, label = Target_train_stator_yoke)
test_pool <- catboost.load_pool(data = df_test, label = Target_test_stator_yoke)
model <- catboost.train(train_pool,test_pool ,params = params)
y_pred=catboost.predict(model,test_pool)
postResample(y_pred,test$stator_yoke)

#build startor winding model
train_pool <- catboost.load_pool(data = df_train, label = Target_train_stator_winding)
test_pool <- catboost.load_pool(data = df_test, label = Target_test_stator_winding)
model <- catboost.train(train_pool,test_pool ,params = params)
y_pred=catboost.predict(model,test_pool)
postResample(y_pred,test$stator_winding)


#parameter tuning



#================
#Approach 
#================
#generate targets
Target_pm <- train$pm
Target_stator_tooth <- train$stator_tooth
Target_stator_yoke <- train$stator_yoke
Target_stator_winding <- train$stator_winding

#train control
control <- trainControl( method = "repeatedcv",   number = 5,   repeats = 5)

#train information normalizing
df_train<- train[,c(1:8)]
df_train_cts <- as.data.frame(lapply(df_train, normalize))

#test information normalized
df_test<- test[,c(1:8)]
df_test_cts <- as.data.frame(lapply(df_test, normalize))


#build pm model
#linear regression
fit.lin <- train(Target_pm~., data=df_train_pm, method="lm", trControl=control)
# #random forest
fit.rf <- train(Target_pm~., data=df_train_pm, method="rf", trControl=control)
# #Stochastic Gradient Boosting (Generalized Boosted Modeling)
fit.gbm <- train(Target_pm~., data=df_train_pm, method="gbm", trControl=control)
# #svm
fit.svm <- train(Target_pm~., data=df_train_pm, method="svmRadial", trControl=control)
# #nnet
fit.nnet <- train(Target_pm~., data=df_train_pm, method="nnet", trControl=control)

#------------------
#compare models
#------------------
results <- resamples(list(linear = fit.lin,randomforest = fit.rf, 
                          gradboost = fit.gbm, 
                          svm = fit.svm, nnet = fit.nnet))
#result output 
summary(results)
#boxplot comparison
bwplot(results)
# Dot-plot comparison
dotplot(results)

#build stator tooth model

#build stator yoke model

#build stator winding model

#================
#Approach 
#================

#================
#Approach 
#================

#names(getModelInfo())


#fitControl <- trainControl(method = "repeatedcv",   number = 10,   repeats = 5)

#tune grid
#modelLookup(model='gbm')

#variable importance
#varImp(object=model_gbm)

# #remove highly correlated columns
# # # calculate correlation matrix
# correlationMatrix <- cor(df_new[,1:length(df_new)-1])
# # # summarize the correlation matrix
# # print(correlationMatrix)
# # # find attributes that are highly corrected (ideally >0.75)
# highlyCorrelated <- findCorrelation(correlationMatrix, cutoff=0.75)
# # # print indexes of highly correlated attributes
# print(highlyCorrelated)
# #cross fold validation
# control <- trainControl(method="repeatedcv", number=10, repeats=5)
# 


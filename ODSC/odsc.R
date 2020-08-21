#clear environment
rm(list=ls())

packages <- c('ggplot2','corrplot',
    'tidyverse','dplyr','scales','catboost',
    'xgboost','caret','dummies','mlbench','tidyr',
    'Matrix','data.table','vtreat', 'rsample')

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

#check for missing data
missing_data_train <- apply(train, 2, function(x) any(is.na(x))) 
print(missing_data_train) #no missing data

missing_data_test <- apply(test, 2, function(x) any(is.na(x))) 
print(missing_data_test) #no missing data

#------
#EDA
#------
summary(train)
summary(test)

#correlation
corinfo <- train
corrplot(cor(corinfo), method="number")

#Modeling

#normalized data
normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}

#Approach 1
#generate targets
Target_pm <- train$pm
Target_stator_tooth <- train$stator_tooth
Target_stator_yoke <- train$stator_yoke
Target_stator_winding <- train$stator_winding

#train information normalizing
df_train_cts <- train[,c(1:8)]
df_cts <- as.data.frame(lapply(df_train_cts, normalize))

#combine data frame
df_train_pm <- cbind(df_cts,Target_pm)
df_train_stator_tooth <- cbind(df_cts,Target_stator_tooth)
df_train_stator_yoke <- cbind(df_cts,Target_stator_yoke)
df_train_stator_winding <- cbind(df_cts,Target_stator_winding)

#train control
control <- trainControl( method = "repeatedcv",   number = 5,   repeats = 5)

#test information normalized
df_test_cts <- test[,c(1:8)]
df_test_cts <- as.data.frame(lapply(df_test_cts, normalize))

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


#Approach 2 - catboost using normalized data
#build pm model
train_pool <- catboost.load_pool(data = df_train_pm, label = Target_pm)

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

model <- catboost.train(learn_pool = train_pool,params = params)
# Fit model
model.fit(train_data, train_labels)
# Get predictions
preds = model.predict(df_test_cts)
#predict
test_pool <- catboost.load_pool(data = df_test_cts)

y_pred=catboost.predict(model,test_pool)
#calculate error metrics
postResample(y_pred,validation$medv)
#output

#Approach 3

#Approach 4

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


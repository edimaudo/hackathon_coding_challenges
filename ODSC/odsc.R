# --------------------------------------------------------
# Overview 
# --------------------------------------------------------
# Objective is to predictive output for pm, stator tooth, stator winding
# and stator yoke.  The key measure is RMSE
#  judging criteria
#  1. Code structure/quality
#  2. Data mining
#  3. Findings and explanations
#  4. Predictions and performance of the model 

# --------------------------------------------------------
# Packages
# --------------------------------------------------------
rm(list=ls()) #clear environment

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

# --------------------------------------------------------
# load data 
# --------------------------------------------------------
train <- read_csv("train.csv")
test <- read_csv("test.csv")
test_solutions <- read_csv("test_solutions.csv")
test <- cbind(test, test_solutions)

# --------------------------------------------------------
# Data exploration & findings 
# --------------------------------------------------------
#check for missing data
missing_data_train <- apply(train, 2, function(x) any(is.na(x))) 
print(missing_data_train)

missing_data_test <- apply(test, 2, function(x) any(is.na(x))) 
print(missing_data_test)

#train and test data have no missing data

#data overview
summary(train)
#blurb about the information

#correlation
corinfo <- train
corrplot(cor(corinfo), method="number")

#blurb about correlation

#data visualizations

#pm

#stator tooth

#stator yoke

#stator winding

# --------------------------------------------------------
# Prediction 
# --------------------------------------------------------

#Approach -  Going to use catboost library

#generate targets
Target_train_pm <- train$pm
Target_train_stator_tooth <- train$stator_tooth
Target_train_stator_yoke <- train$stator_yoke
Target_train_stator_winding <- train$stator_winding

Target_test_pm <- test$pm
Target_test_stator_tooth <- test$stator_tooth
Target_test_stator_yoke <- test$stator_yoke
Target_test_stator_winding <- test$stator_winding

#normalized data
normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}
#train information normalizing
df_train<- train[,c(1:8)]
df_train <- as.data.frame(lapply(df_train, normalize))

#test information normalized
df_test<- test[,c(1:8)]
df_test <- as.data.frame(lapply(df_test, normalize))

# --------------------------------------------------------
# initial models
# --------------------------------------------------------
#initial parameters
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
model_pm <- catboost.train(train_pool,test_pool ,params = params)
y_pred_pm=catboost.predict(model_pm,test_pool)
postResample(y_pred_pm,test$pm)

#RMSE  Rsquared       MAE 
#0.9103235 0.1514294 0.7445611 

cat("\nFeature importances", "\n")
catboost.get_feature_importance(model, train_pool)

#build stator tooth model
train_pool <- catboost.load_pool(data = df_train, label = Target_train_stator_tooth)
test_pool <- catboost.load_pool(data = df_test, label = Target_test_stator_tooth)
model_stator_tooth <- catboost.train(train_pool,test_pool ,params = params)
y_pred_model_stator_tooth=catboost.predict(model_stator_tooth,test_pool)
postResample(y_pred_model_stator_tooth,test$stator_tooth)
#RMSE  Rsquared       MAE 
#0.5536960 0.5877786 0.4480499 

cat("\nFeature importances", "\n")
catboost.get_feature_importance(model, train_pool)

#build stator yoke model
train_pool <- catboost.load_pool(data = df_train, label = Target_train_stator_yoke)
test_pool <- catboost.load_pool(data = df_test, label = Target_test_stator_yoke)
model_stator_yoke <- catboost.train(train_pool,test_pool ,params = params)
y_pred_stator_yoke=catboost.predict(model_stator_yoke,test_pool)
postResample(y_pred_stator_yoke,test$stator_yoke)
#RMSE  Rsquared       MAE 
#0.3921159 0.7623605 0.3150374 
cat("\nFeature importances", "\n")
catboost.get_feature_importance(model, train_pool)

#build startor winding model
train_pool <- catboost.load_pool(data = df_train, label = Target_train_stator_winding)
test_pool <- catboost.load_pool(data = df_test, label = Target_test_stator_winding)
model_stator_winding <- catboost.train(train_pool,test_pool ,params = params)
y_pred_stator_winding=catboost.predict(model_stator_winding,test_pool)
postResample(y_pred_stator_winding,test$stator_winding)
#RMSE  Rsquared       MAE 
#0.6032356 0.6117927 0.4836608 
#feature importance
cat("\nFeature importances", "\n")
catboost.get_feature_importance(model, train_pool)

# --------------------------------------------------------
# parameter tuning
# --------------------------------------------------------
#parameter tuning
#pm

#stator tooth


#stator yoke


#stator winding

# --------------------------------------------------------
# output
# --------------------------------------------------------
#pm

#stator tooth


#stator yoke


#stator winding


#combined


# fit_control <- trainControl(method = "cv",
#                             number = 5,
#                             classProbs = FALSE)
# 
# grid <- expand.grid(depth = c(10,12,14),
#                     learning_rate = 0.01,
#                     iterations = 1000,
#                     l2_leaf_reg = 1e-3,
#                     rsm = 0.95,
#                     border_count = 64)
# 
# report <- train(df_train, Target_train_pm,
#                 method = catboost.caret,
#                 logging_level = 'Verbose', preProc = NULL,
#                 tuneGrid = grid, trControl = fit_control)
# report
# 
# params <- list(iterations=1000,
#                learning_rate=0.01,
#                depth=14,
#                loss_function='RMSE',
#                eval_metric='RMSE',
#                random_seed = 55,
#                od_type='Iter',
#                metric_period = 50,
#                od_wait=20,
#                l2_leaf_reg = 0.001, 
#                rsm = 0.95,
#                border_count = 64,
#                use_best_model=TRUE)
# 
# train_pool <- catboost.load_pool(data = df_train, label = Target_train_pm)
# test_pool <- catboost.load_pool(data = df_test, label = Target_test_pm)
# model_pm <- catboost.train(train_pool,test_pool ,params = params)
# y_pred_pm=catboost.predict(model_pm,test_pool)
# postResample(y_pred_pm,test$pm)
# print(model_pm)
# 
# params <- list(iterations=500,
#                learning_rate=0.01,
#                depth=10,
#                loss_function='RMSE',
#                eval_metric='RMSE',
#                random_seed = 55,
#                od_type='Iter',
#                metric_period = 50,
#                od_wait=20,
#                use_best_model=TRUE)
# 
# #build pm model
# train_pool <- catboost.load_pool(data = df_train, label = Target_train_pm)
# test_pool <- catboost.load_pool(data = df_test, label = Target_test_pm)
# model_pm <- catboost.train(train_pool,test_pool ,params = params)
# y_pred_pm=catboost.predict(model_pm,test_pool)
# postResample(y_pred_pm,test$pm)
# #RMSE  Rsquared       MAE 
# #0.9103235 0.1514294 0.7445611 
# cat("\nFeature importances", "\n")
# catboost.get_feature_importance(model, train_pool)
# 
# #build stator tooth model
# train_pool <- catboost.load_pool(data = df_train, label = Target_train_stator_tooth)
# test_pool <- catboost.load_pool(data = df_test, label = Target_test_stator_tooth)
# model_stator_tooth <- catboost.train(train_pool,test_pool ,params = params)
# y_pred_model_stator_tooth=catboost.predict(model_stator_tooth,test_pool)
# postResample(y_pred_model_stator_tooth,test$stator_tooth)
# #RMSE  Rsquared       MAE 
# #0.5536960 0.5877786 0.4480499 
# cat("\nFeature importances", "\n")
# catboost.get_feature_importance(model, train_pool)
# 
# #build stator yoke model
# train_pool <- catboost.load_pool(data = df_train, label = Target_train_stator_yoke)
# test_pool <- catboost.load_pool(data = df_test, label = Target_test_stator_yoke)
# model_stator_yoke <- catboost.train(train_pool,test_pool ,params = params)
# y_pred_stator_yoke=catboost.predict(model_stator_yoke,test_pool)
# postResample(y_pred_stator_yoke,test$stator_yoke)
# #RMSE  Rsquared       MAE 
# #0.3921159 0.7623605 0.3150374 
# cat("\nFeature importances", "\n")
# catboost.get_feature_importance(model, train_pool)
# 
# #build startor winding model
# train_pool <- catboost.load_pool(data = df_train, label = Target_train_stator_winding)
# test_pool <- catboost.load_pool(data = df_test, label = Target_test_stator_winding)
# model_stator_winding <- catboost.train(train_pool,test_pool ,params = params)
# y_pred_stator_winding=catboost.predict(model_stator_winding,test_pool)
# postResample(y_pred_stator_winding,test$stator_winding)
# #RMSE  Rsquared       MAE 
# #0.6032356 0.6117927 0.4836608 
# #feature importance
# catboost.get_feature_importance(model)
# 
# 
# 
# 
# 
# 

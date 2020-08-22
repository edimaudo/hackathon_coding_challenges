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
# set working directory to file location
train <- read_csv("train.csv")
test <- read_csv("test.csv")
test_solutions <- read_csv("test_solutions.csv")
test <- cbind(test, test_solutions)


# --------------------------------------------------------
# Data exploration & findings 
# --------------------------------------------------------
# check for missing data
missing_data_train <- apply(train, 2, function(x) any(is.na(x))) 
print(missing_data_train)

missing_data_test <- apply(test, 2, function(x) any(is.na(x))) 
print(missing_data_test)
# notes
# train and test data have no missing data


# data overview
summary(train)
# ambient            coolant              u_d                u_q             motor_speed      
# Min.   :-8.57395   Min.   :-1.42935   Min.   :-1.65537   Min.   :-1.861463   Min.   :-1.23902  
# 1st Qu.:-0.34534   1st Qu.:-1.04014   1st Qu.:-0.78720   1st Qu.:-0.916409   1st Qu.:-0.95189  
# Median : 0.33962   Median :-0.13911   Median : 0.29274   Median :-0.085806   Median :-0.14025  
# Mean   : 0.08285   Mean   : 0.02715   Mean   : 0.05259   Mean   : 0.003834   Mean   :-0.01086  
# 3rd Qu.: 0.68825   3rd Qu.: 0.71704   3rd Qu.: 0.40460   3rd Qu.: 0.844942   3rd Qu.: 0.84481  
# Max.   : 2.96712   Max.   : 2.64903   Max.   : 2.27473   Max.   : 1.793498   Max.   : 2.02416  
# torque              i_d                i_q                pm              stator_yoke      
# Min.   :-3.34595   Min.   :-3.24587   Min.   :-3.3416   Min.   :-2.6286480   Min.   :-1.83469  
# 1st Qu.:-0.36510   1st Qu.:-0.75026   1st Qu.:-0.3621   1st Qu.:-0.6561854   1st Qu.:-0.73675  
# Median :-0.23741   Median : 0.25470   Median :-0.2457   Median : 0.0831559   Median :-0.05231  
# Mean   :-0.04155   Mean   : 0.02656   Mean   :-0.0409   Mean   :-0.0004415   Mean   : 0.01269  
# 3rd Qu.: 0.47295   3rd Qu.: 1.01398   3rd Qu.: 0.4869   3rd Qu.: 0.6841788   3rd Qu.: 0.72864  
# Max.   : 3.01697   Max.   : 1.06094   Max.   : 2.9142   Max.   : 2.9174562   Max.   : 2.44916  

# stator_tooth        stator_winding        profile_id   
# Min.   :-2.0661428   Min.   :-2.019973   Min.   : 4.00  
# 1st Qu.:-0.7619508   1st Qu.:-0.723910   1st Qu.:30.00  
# Median : 0.0123391   Median : 0.009469   Median :56.00  
# Mean   : 0.0007527   Mean   :-0.008259   Mean   :50.61  
# 3rd Qu.: 0.7780851   3rd Qu.: 0.707115   3rd Qu.:68.00  
# Max.   : 2.3021693   Max.   : 2.653781   Max.   :81.00  

# notes
# all variables are a mixed of positive and negative numbers 
# with the exception of profile id


# correlation
corinfo <- train
corrplot(cor(corinfo), method="number")
# notes
# strong correlations between u_d and torque, u_d and i_q,
# stator_yoke and stator_tooth, stator_yoke and stator_winding
# stator_tooth and stator_winding, coolant and stator_yoke


#data visualizations

#pm
ggplot(data = yearAwardedProgram,
       aes(
         x = as.factor(year_update),
         y = total_awarded,
         fill = program_area
       )) +
  geom_bar(stat = "identity", width = 0.4) + theme_classic() +
  labs(x = "Years",
       y = "Amount awarded (CAD)",
       fill  = "Program Areas") +
  scale_y_continuous(labels = comma) +
  scale_x_discrete() +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

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

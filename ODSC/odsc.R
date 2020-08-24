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

# =======================================================
# check for missing data
# =======================================================
missing_data_train <- apply(train, 2, function(x) any(is.na(x))) 
print(missing_data_train)

missing_data_test <- apply(test, 2, function(x) any(is.na(x))) 
print(missing_data_test)
# notes
# train and test data have no missing data

# =======================================================
# data overview
# =======================================================
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

# =======================================================
# correlation
# =======================================================
corinfo <- train
corrplot(cor(corinfo), method="number")
# notes
# strong correlations between u_d and torque, u_d and i_q,
# stator_yoke and stator_tooth, stator_yoke and stator_winding
# stator_tooth and stator_winding, coolant and stator_yoke
#remove highly correlated columns
# # calculate correlation matrix
correlationMatrix <- cor(df_train[,1:length(df_train)])
# # summarize the correlation matrix
# print(correlationMatrix)
# # find attributes that are highly corrected (ideally >0.75)
highlyCorrelated <- findCorrelation(correlationMatrix, cutoff=0.8)
# # print indexes of highly correlated attributes
print(highlyCorrelated)
# --------------------------------------------------------
# data visualizations
# --------------------------------------------------------

# =======================================================
# historgram visualization
# =======================================================
# ambient
ggplot(train, aes(x=ambient))+
  geom_histogram(color="darkblue", fill="lightblue") + theme_classic()
#highest clusters seem to be betwen 0 and 2

# coolant
ggplot(train, aes(x=coolant))+
  geom_histogram(color="darkblue", fill="lightblue") + theme_classic()
#centered around -1

# u_d
ggplot(train, aes(x=u_d))+
  geom_histogram(color="darkblue", fill="lightblue") + theme_classic()
#centered around 0 and 0.5

# u_q
ggplot(train, aes(x=u_q))+
  geom_histogram(color="darkblue", fill="lightblue") + theme_classic()
#centered around -1.5 and -1

# motor_speed
ggplot(train, aes(x=motor_speed))+
  geom_histogram(color="darkblue", fill="lightblue") + theme_classic()
#centered after -1.5 and 1

# torque
ggplot(train, aes(x=torque))+
  geom_histogram(color="darkblue", fill="lightblue") + theme_classic()
#centered around -0.5 and 0

# i_d
ggplot(train, aes(x=i_d))+
  geom_histogram(color="darkblue", fill="lightblue") + theme_classic()
#centered around 1

# i_q
ggplot(train, aes(x=i_q))+
  geom_histogram(color="darkblue", fill="lightblue") + theme_classic()
#centered around -0.2 and 0

# pm
ggplot(train, aes(x=pm))+
  geom_histogram(color="darkblue", fill="lightblue") + theme_classic()
#centered around 0 and 1.  Looks normally distrbuted

# stator tooth
ggplot(train, aes(x=stator_tooth))+
  geom_histogram(color="darkblue", fill="lightblue") + theme_classic()
#centered between -0.5 and 0.5.  Looks normally distributed

# stator yoke
ggplot(train, aes(x=stator_yoke))+
  geom_histogram(color="darkblue", fill="lightblue") + theme_classic()
#centered around -0.5

# stator winding
ggplot(train, aes(x=stator_winding))+
  geom_histogram(color="darkblue", fill="lightblue") + theme_classic()
#looks normally distributed.  centered around 0

# =======================================================
# pm visualization
# =======================================================

# ambient and pm
ggplot(data = train,aes(x = ambient,y = pm)) +
  geom_point() + theme_classic() +
  labs(x = "ambient",
       y = "pm") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))
# notes
# clustered between - 3 and 3

# coolant and pm
ggplot(data = train,aes(x = coolant,y = pm)) +
  geom_point() + theme_classic() +
  labs(x = "coolant",y = "pm") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))
# notes
# values seem random

# u_d and pm
ggplot(data = train,aes(x = u_d,y = pm)) +
  geom_point() + theme_classic() +
  labs(x = "u_d",y = "pm") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))
# notes
# values are clustered from o to 2 for u_d, some outliers between 2 and 3 for pm

# u_q and pm
ggplot(data = train,aes(x = u_q,y = pm)) +
  geom_point() + theme_classic() +
  labs(x = "u_q",y = "pm") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))
# notes
#

#motor_speed and pm
ggplot(data = train,aes(x = motor_speed,y = pm)) +
  geom_point() + theme_classic() +
  labs(x = "Motor speed",y = "pm") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))

# torque and pm
ggplot(data = train,aes(x = torque,y = pm)) +
  geom_point() + theme_classic() +
  labs(x = "torque",y = "pm") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))

# i_d and pm
ggplot(data = train,aes(x = i_d,y = pm)) +
  geom_point() + theme_classic() +
  labs(x = "u_d",y = "pm") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))

# i_q and pm
ggplot(data = train,aes(x = i_q,y = pm)) +
  geom_point() + theme_classic() +
  labs(x = "i_q",y = "pm") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))

# =======================================================
# stator tooth visualization
# =======================================================
# ambient and stator_tooth
ggplot(data = train,aes(x = ambient,y = stator_tooth)) +
  geom_point() + theme_classic() +
  labs(x = "ambient",
       y = "stator_tooth") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))


# coolant and stator_tooth
ggplot(data = train,aes(x = coolant,y = stator_tooth)) +
  geom_point() + theme_classic() +
  labs(x = "coolant",y = "stator_tooth") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))


# u_d and stator_tooth
ggplot(data = train,aes(x = u_d,y = stator_tooth)) +
  geom_point() + theme_classic() +
  labs(x = "u_d",y = "stator_tooth") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))


# u_q and stator_tooth
ggplot(data = train,aes(x = u_q,y = stator_tooth)) +
  geom_point() + theme_classic() +
  labs(x = "u_q",y = "stator_tooth") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))


#motor_speed and stator_tooth
ggplot(data = train,aes(x = motor_speed,y = stator_tooth)) +
  geom_point() + theme_classic() +
  labs(x = "Motor speed",y = "stator_tooth") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))

# torque and stator_tooth
ggplot(data = train,aes(x = torque,y = stator_tooth)) +
  geom_point() + theme_classic() +
  labs(x = "torque",y = "stator_tooth") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))

# i_d and stator_tooth
ggplot(data = train,aes(x = i_d,y = stator_tooth)) +
  geom_point() + theme_classic() +
  labs(x = "u_d",y = "stator_tooth") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))

# i_q and stator_tooth
ggplot(data = train,aes(x = i_q,y = stator_tooth)) +
  geom_point() + theme_classic() +
  labs(x = "i_q",y = "stator_tooth") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))

# =======================================================
# stator yoke visualization
# =======================================================
# ambient and stator_yoke
ggplot(data = train,aes(x = ambient,y = stator_yoke)) +
  geom_point() + theme_classic() +
  labs(x = "ambient",
       y = "stator_yoke") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))

# coolant and stator_yoke
ggplot(data = train,aes(x = coolant,y = stator_yoke)) +
  geom_point() + theme_classic() +
  labs(x = "coolant",y = "stator_yoke") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))

# u_d and stator_yoke
ggplot(data = train,aes(x = u_d,y = stator_yoke)) +
  geom_point() + theme_classic() +
  labs(x = "u_d",y = "stator_yoke") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))

# u_q and stator_yoke
ggplot(data = train,aes(x = u_q,y = stator_yoke)) +
  geom_point() + theme_classic() +
  labs(x = "u_q",y = "stator_yoke") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))


#motor_speed and stator_yoke
ggplot(data = train,aes(x = motor_speed,y = stator_yoke)) +
  geom_point() + theme_classic() +
  labs(x = "Motor speed",y = "stator_yoke") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))

# torque and stator_yoke
ggplot(data = train,aes(x = torque,y = stator_yoke)) +
  geom_point() + theme_classic() +
  labs(x = "torque",y = "stator_yoke") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))

# i_d and stator_yoke
ggplot(data = train,aes(x = i_d,y = stator_yoke)) +
  geom_point() + theme_classic() +
  labs(x = "u_d",y = "stator_yoke") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))

# i_q and stator_yoke
ggplot(data = train,aes(x = i_q,y = stator_yoke)) +
  geom_point() + theme_classic() +
  labs(x = "i_q",y = "stator_yoke") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))

# =======================================================
# stator winding visualization
# =======================================================
# ambient and stator_winding
ggplot(data = train,aes(x = ambient,y = stator_winding)) +
  geom_point() + theme_classic() +
  labs(x = "ambient",
       y = "stator_winding") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))


# coolant and stator_winding
ggplot(data = train,aes(x = coolant,y = stator_winding)) +
  geom_point() + theme_classic() +
  labs(x = "coolant",y = "stator_winding") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))


# u_d and stator_winding
ggplot(data = train,aes(x = u_d,y = stator_winding)) +
  geom_point() + theme_classic() +
  labs(x = "u_d",y = "stator_winding") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))


# u_q and stator_winding
ggplot(data = train,aes(x = u_q,y = stator_winding)) +
  geom_point() + theme_classic() +
  labs(x = "u_q",y = "stator_winding") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))


#motor_speed and stator_winding
ggplot(data = train,aes(x = motor_speed,y = stator_winding)) +
  geom_point() + theme_classic() +
  labs(x = "Motor speed",y = "stator_winding") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))

# torque and stator_winding
ggplot(data = train,aes(x = torque,y = stator_winding)) +
  geom_point() + theme_classic() +
  labs(x = "torque",y = "stator_winding") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))

# i_d and stator_winding
ggplot(data = train,aes(x = i_d,y = stator_winding)) +
  geom_point() + theme_classic() +
  labs(x = "u_d",y = "stator_winding") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))

# i_q and stator_winding
ggplot(data = train,aes(x = i_q,y = stator_winding)) +
  geom_point() + theme_classic() +
  labs(x = "i_q",y = "stator_winding") +
  scale_y_continuous(labels = comma) +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 10),
    axis.title = element_text(size = 15),
    axis.text = element_text(size = 10))

# most of the graphs don't generate any special insights.  
# correlation is definitely a better tool

# --------------------------------------------------------
# Prediction 
# --------------------------------------------------------
# Approach -  Going to use catboost library
# =======================================================
# generate targets
# =======================================================

# normalized data
normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}
# train information normalizing
train <- as.data.frame(lapply(train, normalize))
df_train<- train[,c(1:8)]

# test information normalized
test <- as.data.frame(lapply(test, normalize))
df_test<- test[,c(1:8)]

Target_train_pm <- train$pm
Target_train_stator_tooth <- train$stator_tooth
Target_train_stator_yoke <- train$stator_yoke
Target_train_stator_winding <- train$stator_winding

Target_test_pm <- test$pm
Target_test_stator_tooth <- test$stator_tooth
Target_test_stator_yoke <- test$stator_yoke
Target_test_stator_winding <- test$stator_winding

# --------------------------------------------------------
# initial models
# --------------------------------------------------------
# initial parameters
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

# build pm model
train_pool <- catboost.load_pool(data = df_train, label = Target_train_pm)
test_pool <- catboost.load_pool(data = df_test, label = Target_test_pm)
model_pm <- catboost.train(train_pool,test_pool ,params = params)
y_pred_pm=catboost.predict(model_pm,test_pool)
cat("\n Metrics ", "\n")
postResample(y_pred_pm,test$pm)
# RMSE  Rsquared       MAE 
# 0.2195003 0.1401214 0.1878723 
cat("\nFeature importances", "\n")
catboost.get_feature_importance(model_pm, train_pool)
# ambient     25.581220
# coolant     25.761846
# u_d         10.770079
# u_q         13.593460
# motor_speed  9.416166
# torque       5.707020
# i_d          4.763703
# i_q          4.406507

# build stator tooth model
train_pool <- catboost.load_pool(data = df_train, label = Target_train_stator_tooth)
test_pool <- catboost.load_pool(data = df_test, label = Target_test_stator_tooth)
model_stator_tooth <- catboost.train(train_pool,test_pool ,params = params)
y_pred_model_stator_tooth=catboost.predict(model_stator_tooth,test_pool)
cat("\n Metrics ", "\n")
postResample(y_pred_model_stator_tooth,test$stator_tooth)
# RMSE  Rsquared       MAE 
# 0.1564777 0.5747189 0.1273713 
cat("\nFeature importances", "\n")
catboost.get_feature_importance(model_stator_tooth, train_pool)
# ambient     11.607639
# coolant     45.835811
# u_d          7.349999
# u_q         10.562692
# motor_speed  3.507859
# torque       2.853806
# i_d         16.326350
# i_q          1.955844

# build stator yoke model
train_pool <- catboost.load_pool(data = df_train, label = Target_train_stator_yoke)
test_pool <- catboost.load_pool(data = df_test, label = Target_test_stator_yoke)
model_stator_yoke <- catboost.train(train_pool,test_pool ,params = params)
y_pred_stator_yoke=catboost.predict(model_stator_yoke,test_pool)
cat("\n Metrics ", "\n")
postResample(y_pred_stator_yoke,test$stator_yoke)
# RMSE   Rsquared        MAE 
# 0.11103872 0.75938597 0.09005218  
cat("\nFeature importances", "\n")
catboost.get_feature_importance(model_stator_yoke, train_pool)
# ambient      9.394013
# coolant     59.749107
# u_d          5.465676
# u_q          7.139743
# motor_speed  2.930231
# torque       1.804211
# i_d         11.801944
# i_q          1.715075

# build startor winding model
train_pool <- catboost.load_pool(data = df_train, label = Target_train_stator_winding)
test_pool <- catboost.load_pool(data = df_test, label = Target_test_stator_winding)
model_stator_winding <- catboost.train(train_pool,test_pool ,params = params)
y_pred_stator_winding=catboost.predict(model_stator_winding,test_pool)
cat("\n Metrics ", "\n")
postResample(y_pred_stator_winding,test$stator_winding)
# RMSE  Rsquared       MAE 
# 0.1597373 0.5974142 0.1291624  
#feature importance
cat("\nFeature importances", "\n")
catboost.get_feature_importance(model_stator_winding, train_pool)
# ambient     11.111690
# coolant     37.201628
# u_d          7.111262
# u_q         13.813695
# motor_speed  2.670178
# torque       3.309407
# i_d         22.073466
# i_q          2.708673

# =======================================================
# using selected features 
# =======================================================
# pm features data ambient ,coolant,u_d,u_q,motor_speed
df_train_pm<- train[,c(1:5)]
df_test_pm <- test[,c(1:5)]
# stator tooth data
df_train_stator_tooth<- train[,c(1,2,4,7)]
df_test_stator_tooth <- test[,c(1,2,4,7)]
# stator yoke data
df_train_stator_yoke<- train[,c(1,2,7)]
df_test_stator_yoke <- test[,c(1,2,7)]
# stator winding data
df_train_stator_winding <- train[,c(1,2,4,7)]
df_test_stator_winding <- test[,c(1,2,4,7)]

train_pool <- catboost.load_pool(data = df_train_pm, label = Target_train_pm)
test_pool <- catboost.load_pool(data = df_test_pm, label = Target_test_pm)
model_pm <- catboost.train(train_pool,test_pool ,params = params)
y_pred_pm=catboost.predict(model_pm,test_pool)
cat("\n Metrics ", "\n")
postResample(y_pred_pm,test$pm)
# RMSE  Rsquared       MAE 
# 0.2179503 0.1374880 0.1853962 
cat("\nFeature importances", "\n")
catboost.get_feature_importance(model_pm, train_pool)


# build stator tooth model
train_pool <- catboost.load_pool(data = df_train_stator_tooth, 
                                 label = Target_train_stator_tooth)
test_pool <- catboost.load_pool(data = df_test_stator_tooth, 
                                label = Target_test_stator_tooth)
model_stator_tooth <- catboost.train(train_pool,test_pool ,params = params)
y_pred_model_stator_tooth=catboost.predict(model_stator_tooth,test_pool)
cat("\n Metrics ", "\n")
postResample(y_pred_model_stator_tooth,test$stator_tooth)
# RMSE  Rsquared       MAE 
# 0.1610478 0.5429575 0.1309435 
cat("\nFeature importances", "\n")
catboost.get_feature_importance(model_stator_tooth, train_pool)


# build stator yoke model
train_pool <- catboost.load_pool(data = df_train_stator_yoke, 
                                 label = Target_train_stator_yoke)
test_pool <- catboost.load_pool(data = df_test_stator_yoke, 
                                label = Target_test_stator_yoke)
model_stator_yoke <- catboost.train(train_pool,test_pool ,params = params)
y_pred_stator_yoke=catboost.predict(model_stator_yoke,test_pool)
cat("\n Metrics ", "\n")
postResample(y_pred_stator_yoke,test$stator_yoke)
# RMSE   Rsquared        MAE 
# 0.11924872 0.71862510 0.09565694 
cat("\nFeature importances", "\n")
catboost.get_feature_importance(model_stator_yoke, train_pool)


# build startor winding model
train_pool <- catboost.load_pool(data = df_train_stator_winding, 
                                 label = Target_train_stator_winding)
test_pool <- catboost.load_pool(data = df_test_stator_winding, 
                                label = Target_test_stator_winding)
model_stator_winding <- catboost.train(train_pool,test_pool ,params = params)
y_pred_stator_winding=catboost.predict(model_stator_winding,test_pool)
cat("\n Metrics ", "\n")
postResample(y_pred_stator_winding,test$stator_winding)
# RMSE  Rsquared       MAE 
# 0.1655514 0.5518565 0.1349436  
#feature importance
cat("\nFeature importances", "\n")
catboost.get_feature_importance(model_stator_winding, train_pool)



# =======================================================
# parameter tuning
# =======================================================
# pm features data ambient ,coolant,u_d,u_q,motor_speed
df_train_pm<- train[,c(1:5)]
df_test_pm <- test[,c(1:5)]
# stator tooth data
df_train_stator_tooth<- train[,c(1,2,4,7)]
df_test_stator_tooth <- test[,c(1,2,4,7)]
# stator yoke data
df_train_stator_yoke<- train[,c(1,2,7)]
df_test_stator_yoke <- test[,c(1,2,7)]
# stator winding data
df_train_stator_winding <- train[,c(1,2,4,7)]
df_test_stator_winding <- test[,c(1,2,4,7)]

fit_control <- trainControl(method = "cv",
                            number = 5,
                            classProbs = FALSE)

grid <- expand.grid(depth = 14,
                    learning_rate = 0.01,
                    iterations = 500,
                    l2_leaf_reg = 1e-3,
                    rsm = 0.95,
                    border_count = 64)

# pm
report_pm <- train(df_train_pm, Target_train_pm,
                method = catboost.caret,
                logging_level = 'Verbose', preProc = NULL,
                tuneGrid = grid, trControl = fit_control)
cat("\nModel PM Output", "\n")
report_pm
# RMSE        Rsquared   MAE       
# 0.07587136  0.8260214  0.05670304

# stator tooth
report_stator_tooth <- train(df_train_stator_tooth, Target_train_stator_tooth,
                   method = catboost.caret,
                   logging_level = 'Verbose', preProc = NULL,
                   tuneGrid = grid, trControl = fit_control)
cat("\nModel stator tooth Output", "\n")
report_stator_tooth
# RMSE        Rsquared   MAE       
# 0.08846393  0.8543031  0.06401475

# stator yoke
report_stator_yoke <- train(df_train_stator_yoke, Target_train_stator_yoke,
                             method = catboost.caret,
                             logging_level = 'Verbose', preProc = NULL,
                             tuneGrid = grid, trControl = fit_control)
cat("\nModel stator yoke", "\n")
report_stator_yoke
# RMSE        Rsquared  MAE       
# 0.07343367  0.904449  0.05258386

# stator winding
report_stator_winding <- train(df_train_stator_winding, Target_train_stator_winding,
                            method = catboost.caret,
                            logging_level = 'Verbose', preProc = NULL,
                            tuneGrid = grid, trControl = fit_control)
cat("\nModel stator winding", "\n")
report_stator_winding
# RMSE        Rsquared  MAE      
# 0.09105025  0.820392  0.0659608

# =======================================================
# finalized models
# =======================================================
params <- list(iterations=500,
               learning_rate=0.01,
               depth=14,
               loss_function='RMSE',
               eval_metric='RMSE',
               random_seed = 55,
               od_type='Iter',
               metric_period = 50,
               od_wait=20,
               use_best_model=TRUE)

#load data
df_train_pm<- train[,c(1:5)]
df_test_pm <- test[,c(1:5)]
# stator tooth data
df_train_stator_tooth<- train[,c(1,2,4,7)]
df_test_stator_tooth <- test[,c(1,2,4,7)]
# stator yoke data
df_train_stator_yoke<- train[,c(1,2,7)]
df_test_stator_yoke <- test[,c(1,2,7)]
# stator winding data
df_train_stator_winding <- train[,c(1,2,4,7)]
df_test_stator_winding <- test[,c(1,2,4,7)]

# build pm model
train_pool <- catboost.load_pool(data = df_train_pm, label = Target_train_pm)
test_pool <- catboost.load_pool(data = df_test_pm, label = Target_test_pm)
model_pm <- catboost.train(train_pool,test_pool ,params = params)
y_pred_pm=catboost.predict(model_pm,test_pool)
cat("\n Metrics ", "\n")
postResample(y_pred_pm,Target_test_pm)

# build stator tooth model
train_pool <- catboost.load_pool(data = df_train_stator_tooth, label = Target_train_stator_tooth)
test_pool <- catboost.load_pool(data = df_test_stator_tooth, label = Target_test_stator_tooth)
model_stator_tooth <- catboost.train(train_pool,test_pool ,params = params)
y_pred_model_stator_tooth=catboost.predict(model_stator_tooth,test_pool)
cat("\n Metrics ", "\n")
postResample(y_pred_model_stator_tooth,Target_train_stator_tooth)

# build stator yoke model
train_pool <- catboost.load_pool(data = df_train_stator_yoke, label = Target_train_stator_yoke)
test_pool <- catboost.load_pool(data = df_test_stator_yoke, label = Target_test_stator_yoke)
model_stator_yoke <- catboost.train(train_pool,test_pool ,params = params)
y_pred_stator_yoke=catboost.predict(model_stator_yoke,test_pool)
cat("\n Metrics ", "\n")
postResample(y_pred_stator_yoke,Target_test_stator_yoke)

# build startor winding model
train_pool <- catboost.load_pool(data = df_train_stator_winding, label = Target_train_stator_winding)
test_pool <- catboost.load_pool(data = df_test_stator_winding, label = Target_test_stator_winding)
model_stator_winding <- catboost.train(train_pool,test_pool ,params = params)
y_pred_stator_winding=catboost.predict(model_stator_winding,test_pool)
cat("\n Metrics ", "\n")
postResample(y_pred_stator_winding,Target_train_stator_winding)

# =======================================================
# outputs
# =======================================================
output_cols <- ('pm','stator_tooth','stator_yoke','stator_winding')
rmse_col <- c("RMSE")

#combined


# =======================================================
# clear environment
# =======================================================
rm(list=ls())

# =======================================================
# load packages
# =======================================================
packages <- c('ggplot2', 'corrplot','tidyverse','dplyr','tidyr',
              'caret','mlbench','mice','scales','proxy','reshape2',
              'caTools','dummies','scales','catboost', 'Matrix','stringr','reshape2','purrr')

for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}

# =======================================================
# load data
# =======================================================
train_data1 <- read_csv("Dataset_1.csv")
train_data2 <- read_csv("Dataset_2.csv")

#evaluation
eval_harvest_quantity_output <- read_csv("harvest_quantity_output.csv")
eval_planting_date_output <- read_csv("planting_date_output.csv")

# =======================================================
# data overview
# =======================================================

#summary
summary(train_data1)
summary(train_data2)
summary(eval_harvest_quantity_output)
summary(eval_planting_date_output)

#check for missing
missing_data_train_data1 <- apply(train_data1, 2, function(x) any(is.na(x))) 
missing_data_train_data2 <- apply(train_data2, 2, function(x) any(is.na(x))) 
missing_data_eval_harvest_quantity_output <- apply(eval_harvest_quantity_output, 
                                                  2, function(x) any(is.na(x))) 
missing_data_eval_planting_date_output <- apply(eval_planting_date_output, 
                                                2, function(x) any(is.na(x))) 
print("missing train data 1")
print(missing_data_train_data1)
print("missing train data 1")
print(missing_data_train_data2)
print("missing harvest quantity output")
print(missing_data_eval_harvest_quantity_output)
print("planting date output")
print(missing_data_eval_planting_date_output)

# no missing data in all datasets

# =======================================================
# EDA and visualization
# =======================================================
# train data 1

#correlation
cor_train_data1 <- cor(train_data1[,c(2,6,7,8)])
corrplot(cor_train_data1, method="number") # special correlation

# site visualization

# site count
ggplot(data=train_data1, aes(x=factor(site))) +
  geom_bar() + theme_classic() + xlab("Site") 

# site and required gdus
ggplot(train_data1, aes(x=as.factor(site), y=required_gdus)) + 
  geom_boxplot() + theme_classic()

# site and scenario_1_harvest_quantity
ggplot(train_data1, aes(x=as.factor(site), y=scenario_1_harvest_quantity)) + 
  geom_boxplot() + theme_classic()

#site and scenario_2_harvest_quantity
ggplot(train_data1, aes(x=as.factor(site), y=scenario_2_harvest_quanitity)) + 
  geom_boxplot() + theme_classic()

#required GDUs
ggplot(train_data1, aes(x=required_gdus, fill=site)) +
  geom_area()





# train data 2

# combined train data 1 and 2

# =======================================================
# experimental modeling
# =======================================================
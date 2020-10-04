# =======================================================
# clear environment
# =======================================================
rm(list=ls())

# =======================================================
# load packages
# =======================================================
packages <- c('ggplot2', 'corrplot','tidyverse','dplyr','tidyr',
              'caret','mlbench','mice','scales','proxy','reshape2',
              'caTools','dummies','scales','catboost', 'Matrix',
              'stringr','reshape2','purrr','lubridate')

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
eval_harvest_quantity_output <- read_csv("harvest_quantity_output.csv")
eval_planting_date_output <- read_csv("planting_date_output.csv")

# =======================================================
# data overview
# =======================================================
train_data1$original_planting_date <- mdy(train_data1$original_planting_date)
train_data1$early_planting_date <- mdy(train_data1$early_planting_date)
train_data1$late_planting_date <- mdy(train_data1$late_planting_date)
train_data1$site <- as.factor(train_data1$site)


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
# data visualization
# =======================================================

# ------------------------------------
# correlation
# ------------------------------------
cor_train_data1 <- cor(train_data1[,c(2,6,7,8)])
corrplot(cor_train_data1, method="number") # special correlation

# ------------------------------------
# site, required gdu, scenario 1 and 2 visualization
# ------------------------------------

# site count
ggplot(data=train_data1, aes(x=factor(site))) +
  geom_bar() + theme_classic() + xlab("Site") 

# site and required gdus
ggplot(train_data1, aes(x=as.factor(site), y=required_gdus)) + 
  geom_boxplot() + theme_classic()

# site and scenario_1_harvest_quantity
ggplot(train_data1, aes(x=as.factor(site), y=scenario_1_harvest_quantity)) + 
  geom_boxplot() + theme_classic()

# site and scenario_2_harvest_quantity
ggplot(train_data1, aes(x=as.factor(site), y=scenario_2_harvest_quanitity)) + 
  geom_boxplot() + theme_classic()

# ------------------------------------
# required GDUs & scenario 1 and 2 visualization
# ------------------------------------

#scenario 1 harvest quantity
ggplot(train_data1, aes(x=required_gdus, y=scenario_1_harvest_quantity, 
                        shape=as.factor(site), color=as.factor(site))) +
  geom_point() + theme_classic()

# scenario 2 harvest quantity
ggplot(train_data1, aes(x=required_gdus, y=scenario_2_harvest_quanitity, 
                        shape=as.factor(site), color=as.factor(site))) +
  geom_point() + theme_classic()


# ------------------------------------
# original_planting_date visualization
# ------------------------------------
orig_date_df2 <- train_data1 %>%
  group_by(original_planting_date) %>%
  summarise(required_gdu_total = sum(required_gdus),
         scenario1_total = sum(scenario_1_harvest_quantity),
         scenario2_total = sum(scenario_2_harvest_quanitity)) %>%
  select(original_planting_date, required_gdu_total, scenario1_total, scenario2_total)

ggplot(orig_date_df2, aes(x=original_planting_date)) + 
  geom_line(aes(y = required_gdu_total), color = "darkred") + 
  geom_line(aes(y = scenario1_total), color="steelblue") + 
  geom_line(aes(y = scenario2_total), color="green")


# ------------------------------------
# late_planting_date visualization
# ------------------------------------
late_date_df <- train_data1 %>%
  group_by(late_planting_date) %>%
  summarise(required_gdu_total = sum(required_gdus),
            scenario1_total = sum(scenario_1_harvest_quantity),
            scenario2_total = sum(scenario_2_harvest_quanitity)) %>%
  select(late_planting_date, required_gdu_total, scenario1_total, scenario2_total)

ggplot(late_date_df, aes(x=late_planting_date)) + 
  geom_line(aes(y = required_gdu_total), color = "red") + 
  geom_line(aes(y = scenario1_total), color="blue") + 
  geom_line(aes(y = scenario2_total), color="green")



# ------------------------------------
# early_planting_date visualization
# ------------------------------------
early_date_df <- train_data1 %>%
  group_by(early_planting_date) %>%
  summarise(required_gdu_total = sum(required_gdus),
            scenario1_total = sum(scenario_1_harvest_quantity),
            scenario2_total = sum(scenario_2_harvest_quanitity)) %>%
  select(early_planting_date, required_gdu_total, scenario1_total, scenario2_total)

ggplot(early_date_df, aes(x=early_planting_date)) + theme_classic() + 
  geom_line(aes(y = required_gdu_total), color = "red") + 
  geom_line(aes(y = scenario1_total), color="blue") + 
  geom_line(aes(y = scenario2_total), color="darkgreen")

# =======================================================
# train data 2 visualization
# =======================================================
train_data2$date <- ymd(train_data2$date)


ggplot(train_data2, aes(x=date)) + theme_classic() + 
  geom_line(aes(y = site_0), color = "red") + 
  geom_line(aes(y = site_1), color="blue") 



# =======================================================
# experimental modeling
# =======================================================
 

# Objective: Minimize the difference between the weekly harvest quantity and the capacity for each harvesting week.
# For each harvesting week and location:
# Min: weeklyharvestTotal - locationCapacity
# Capacity Constraint: For scenario 1, Site 0 has a capacity of 7000 ears 
# and Site 1 has a capacity of 6000 ears.
# For scenario 2, there is not a predefined capacity. 
#The participant is asked to determine the lowest capacity required.
 
# The two scenarios roughly emulate normal distributions: N(250,100) and N(350,150), respectively.

# In summary, we desire an optimization model to schedule when planting should occur for a specific seed population 
# so that when the ears are harvested, we are not over holding capacity.

# -----------------------------------------
#scenario 1 - site 0, original planting date - Site 0 has a capacity of 7000 ears
# -----------------------------------------
#site, original planting date, required gdu, scenario 1 harvest

scenario_1 <- train_data1 %>%
  filter(site == 0) %>%
  select(population, original_planting_date,required_gdus, scenario_1_harvest_quantity)
  
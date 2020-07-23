#packages 
packages <- c('ggplot2', 'corrplot','tidyverse','ggfortify','shiny','readxl','DT',
              'caret','mlbench','mice','scales','recommenderlab','proxy','reshape2',
              'caTools','dummies','highcharter',"gridExtra")
#load packages
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}

#load data
orders <- read.csv("orders.csv")
vendors <- read.csv("vendors.csv")
test_customers <- read.csv("test_customers.csv")
test_locations <- read.csv("test_locations.csv")
train_customers <- read.csv("train_customers.csv")
train_locations <- read.csv("train_locations.csv")
sample_submission <- read.csv("SampleSubmission.csv")

#rename columns
col_locations <- c("customer_id","location_number",
                               "location_type","latitude","longitude")

col_customers<- c("customer_id","gender","dob","status",
                               "verified","language","created_at","updated_at")

colnames(train_locations) <- col_locations
colnames(train_customers) <- col_customers
colnames(test_locations) <- col_locations
colnames(test_customers) <- col_customers

#clean up train and test customers -#drop gender	dob	status	verified	language
train_customers <- train_customers %>%
  select(customer_id, status, created_at, updated_at)

test_customers <- test_customers %>%
  select(customer_id, status, created_at, updated_at)

#remove duplicate train and test customers
train_customers <- train_customers %>%
  distinct()

test_customers <- test_customers %>%
  distinct()

#merge train and test customers with train and test locations


#merge with vendor train and test combined data

# train_customers <- train_customers[,c()]
# train_customers <- train_customers %>%
#   distinct()

# #combine data
# train_info <- train_customers %>%
#   right_join(train_locations,by = "customer_id")
# 
# #combine data
# test_info <- test_customers %>%
#   right_join(test_locations,by = "customer_id")

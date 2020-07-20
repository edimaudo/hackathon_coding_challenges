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

#data summary
glimpse(orders)
summary(orders)

glimpse(vendors)
summary(vendors)

#rename columns
colnames(train_locations) <- c("customer_id","location_number",
                               "location_type","latitude","longitude")

colnames(train_customers) <- c("customer_id","gender","dob","status",
                               "verified","language","created_at","updated_at")

#combine data
train_info <- train_customers %>%
  inner_join(train_locations,)
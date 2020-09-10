# =======================================================
# Objective
# Challenge 1 Overview: City-Business Collaboration
# To identify opportunities for companies and cities to collaborate on sustainability solutions, 
# we need to first understand how the data they each report is aligned or divergent by 
# using data science and text analytics techniques.

#Task:
# Utilize data science and text analytics techniques to improve readability of CDP cities and 
  # corporate data.
# Visualize shared sentiment between cities and companies on specific 
  # topics (such as clean energy, sustainable buildings, clean transport, waste and circular economy).
# Create a KPI model that measures the propensity of cities to collaborate with companies. 
  # Provide the justification of your weights and indicators.

# =======================================================
# Judging crtieria
# =======================================================
# Use of CDP and external data
# Does your team utilize the CDP data provided in combination with external data sources?
# 
# Outcome
# Does your team have a clear understanding of the challenge? Do you address the challenge prompt?
# 
# Feasibility of idea
# Can your solution viably be implemented and sustained in the real world?
# 
# Innovation
# Are you thinking outside of the box? 
# Does the solution implement trends and best practice from other innovative areas?
# 
# Technical explanation
# Each challenge asks teams to explain their technical decisions 
# (i.e. Justify weights, explain assumptions, etc). 
# Are clear justifications or explanations provided?

# =======================================================
rm(list=ls()) #clear environment
# =======================================================
# load packages
# =======================================================
packages <- c('ggplot2', 'corrplot','tidyverse','dplyr','tidyr','tidytext',
              'caret','mlbench','mice','scales','proxy','reshape2',
              'caTools','dummies','scales','catboost', 'Matrix')

for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}

# =======================================================
# load data
# =======================================================
corporate_data <- read_csv("2018-2019_CorporateCC_mb2.csv")
city_data <- read_csv("Cities_Data_2017-2019_mb2.csv")
city_adaptation_2018 <- read_csv("2018_Cities_Adaptation_Actions.csv")
city_response_2018 <- read_csv("2018_A_list_Cities_with_Response_Links.csv")
city_2018_2019 <- read_csv("2018_-_2019_Full_Cities_Dataset.csv")
city_response_2019 <- read_csv("2019_A_list_Cities_with_Response_Links.csv")
city_adaptation_2019 <- read_csv("2019_Cities_Adaptation_Actions.csv") 
sustainability <- read_csv("ready-for-100.csv")

# =======================================================
# data exploration
# =======================================================
print("corproate data summary")
summary(corporate_data)

print("city data summary")
summary(city_data)

# check for missing data
missing_data_corporate <- apply(corporate_data, 2, function(x) any(is.na(x))) 
print("corporate data")
print(missing_data_corporate)

missing_data_city<- apply(city_data, 2, function(x) any(is.na(x))) 
print("city data")
print(missing_data_city)


# =======================================================
# city analysis
# =======================================================

# generate 2018 data
city_2018 <- city_data %>%
  filter(`Project Year` == 2018) %>%
  select(`Project Year`, `Account Name`, `Account Number`, 
         `Question Name`, `Column Name`, `Response Answer`)

# text mining

# sentiment analysis

# n-grams

# insights

# corproation analysis
# text mining
# sentiment analysis
# n-grams

#shared sentiments between city and corporations

#KPI models
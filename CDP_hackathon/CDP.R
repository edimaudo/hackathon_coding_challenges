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
# - create readme
# - select problem area
# - review dataset
# - setup code
# - select what you want to go over
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

# =======================================================
# data setup
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

# city analysis
# text mining
# sentiment analysis
# n-grams

# corproation analysis
# text mining
# sentiment analysis
# n-grams

#shared sentiments between city and corporations

#KPI models
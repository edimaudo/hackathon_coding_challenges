
packages <- c('ggplot2','corrplot',
    'tidyverse','dplyr','DT','scales','catboost',
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

#check distribution

#try normalized data



rm(list=ls())

#packages 
packages <- c('ggplot2', 'corrplot','tidyverse','caret','mlbench','mice', 
              'caTools','dummies','countrycode','readxl')

#load packages
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}

#load data
df <- read_excel("Short_study_Data.xlsx")

summary(df)
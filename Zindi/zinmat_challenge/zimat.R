#clear environment
rm(list = ls())

#packages 
packages <- c('ggplot2', 'corrplot','tidyverse','ggfortify','readxl','DT',
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
train <- read.csv("Train.csv")
test <- read.csv("Test.csv")
sample_submission <- read.csv("SampleSubmission.csv")

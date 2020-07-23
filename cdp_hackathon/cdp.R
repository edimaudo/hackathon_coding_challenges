#clear environment
rm(list = ls())

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
Cities_Data_mb2_2017_2019 <- read.csv("Cities_Data_2017-2019_mb2.csv")
CorporateCC_mb2_2018_2019 <- read.csv("2018-2019_CorporateCC_mb2.csv")
CorporateCC_mb2_2015_2017 <- read.csv("2015-2017_CorporateCC_mb2.csv")

#data summary
summary(Cities_Data_mb2_2017_2019)
summary(CorporateCC_mb2_2018_2019)



#load external data



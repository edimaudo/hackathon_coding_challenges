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

#data summary
summary(Cities_Data_mb2_2017_2019)
summary(CorporateCC_mb2_2018_2019)

#remove 2017 data for cities
Cities_Data_mb2_2018_2019 <- Cities_Data_mb2_2017_2019 %>%
  filter(Project.Year %in% c('2018','2019'))

#city data cleanup and tidying

#city sentimental analysis

#city topic modeling

#coporation data cleanup and tidying

#coporation sentiment aanlysis

#coporation topic modeling

#merge coporation and city information - #load external data - kaggle site
#https://www.kaggle.com/peopledatalabssf/free-7-million-company-dataset

#get KPIs
#https://datacatalog.worldbank.org/dataset/curb-climate-action-urban-sustainability
#https://datacatalog.worldbank.org/dataset/environment-social-and-governance-data

#build KPI model

#dashboard in shiny showing city information, coporation information
#kpi information


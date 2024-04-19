#=========================================
rm(list = ls())
#=============
# Packages 
#=============
packages <- c(
  'ggplot2', 'corrplot','tidyverse','shiny','shinydashboard','DT','readxl',
  'mlbench','caTools','gridExtra','doParallel','grid','forecast','reshape2',
  'caret','dummies','tidyr','Matrix','lubridate','plotly','RColorBrewer',
  'data.table','scales','rfm','forecast','TTR','xts'
)
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}

#=============
# Load Data
#=============
cadmium <- read_csv("Cadmium emissions to air by facility.csv")
lead <- read_csv("Lead emissions to air by facility.csv")
mecury <- read_csv("Mercury emissions to air by facility.csv")

# top 10 mecury emissions by facility
# top 10 mecury emissions by company
# top 10 mecury emissions by City
# top 10 mecury emissions by Province
# 
# top 10 cadmium emissions by facility
# top 10 cadmium emissions by company
# top 10 cadmium emissions by City
# top 10 cadmium emissions by Province
# 
# top 10 lead emissions by facility
# top 10 lead emissions by company
# top 10 lead emissions by City
# top 10 lead emissions by Province

# top 10 mecury emissions by facility map
# top 10 mecury emissions by company map
# top 10 mecury emissions by City map
# top 10 mecury emissions by Province map
# 
# top 10 cadmium emissions by facility map
# top 10 cadmium emissions by company map
# top 10 cadmium emissions by City map
# top 10 cadmium emissions by Province map
# 
# top 10 lead emissions by facility map
# top 10 lead emissions by company map
# top 10 lead emissions by City map
# top 10 lead emissions by Province map

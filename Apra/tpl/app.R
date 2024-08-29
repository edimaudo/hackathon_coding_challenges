#========================================
# Shiny web app which provides insights 
# into TPL
#=========================================
rm(list = ls())
#=============
# Libraries 
#=============
packages <- c(
  'ggplot2', 'corrplot','tidyverse','shiny','shinydashboard','DT','readxl',
  'forecast','reshape2','tidyr','Matrix','lubridate','plotly','RColorBrewer',
  'data.table','scales','dplyr'
)
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}
#=============
# Load data
#=============

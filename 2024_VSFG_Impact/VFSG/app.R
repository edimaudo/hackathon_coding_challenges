#================================================================================
# Shiny web app which provides insights visualization for social good projects
#================================================================================
rm(list = ls())
################
# Packages 
################
packages <- c(
  'ggplot2', 'corrplot','tidyverse','shiny','shinydashboard','DT','readxl',
  'mlbench','caTools','gridExtra','doParallel','grid','forecast','reshape2',
  'caret','dummies','tidyr','Matrix','lubridate','plotly',
  'data.table','scales','stopwords','tidytext','stringr', 
  'textmineR','topicmodels','textclean'
)
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}


################
# Load Data
################
charity <- read_excel("Charity - SDG.xlsx")

################
# Data Setup
################


################
# UI
################


################
# Server logic 
################
server <- function(input, output,session) {}

shinyApp(ui, server)


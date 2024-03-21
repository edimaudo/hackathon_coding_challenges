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
charity_sdg <- read_excel("Charity - SDG.xlsx",sheet="SDG Goals")
charity_impact <- read_excel("Charity - SDG.xlsx",sheet="Impact Data")
linkedin <- read_excel("Linkedin Stats.xlsx")
project_nepal <- read_excel("Build Up Nepal.xlsx")
project_india <- read_excel("India Water Portal submissions.xlsx")
project_sunny <- read_excel("Sunny Street Submissions.xlsx")
project_tap <- read_excel("Tap Elderly Women_s Wisdom for Youth (TEWWY) Submissions.xlsx")
#project_video <- read_excel("Video Volunteers Submissions.xlsx")
project_who <- read_excel("Who submissions.xlsx")


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


#================================================================================
# Shiny web app which provides insights visualization for social good projects
#================================================================================

rm(list = ls())
################
#packages 
################
packages <- c(
  'ggplot2', 'corrplot','tidyverse','shiny','shinydashboard','DT',
  'mlbench','caTools','gridExtra','doParallel','grid','forecast','reshape2',
  'caret','dummies','tidyr','Matrix','lubridate','TTR',
  'data.table','scales','stopwords','tidytext',
  'stringr', 'textmineR','topicmodels','textclean'
)
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}
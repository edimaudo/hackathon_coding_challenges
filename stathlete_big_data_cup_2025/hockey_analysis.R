################
# Packages
################
packages <- c('ggplot2','corrplot','tidyverse','readxl','DT',
              'RColorBrewer','shiny','shinydashboard','scales','dplyr',
              'forecast','lubridate','stopwords','tidytext','stringr',
              'reshape2', 'textmineR','topicmodels','textclean')
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}

################
# Load Data
################

################
# Modeling
################

################
# Report graphs
################


################
# Insights
################
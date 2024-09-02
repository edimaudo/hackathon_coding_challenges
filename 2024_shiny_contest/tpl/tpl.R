rm(list = ls())
################
# Libraries
################
packages <- c(
  'rjson','dplyr',
  'ggplot2', 'corrplot','tidyverse','shiny','shinydashboard','DT','readxl',
  'mlbench','caTools','gridExtra','doParallel','grid','forecast','reshape2',
  'caret','dummies','tidyr','Matrix','lubridate','plotly','RColorBrewer',
  'data.table','scales','stopwords','tidytext','stringr','wordcloud','wordcloud2',
  'SnowballC','textmineR','topicmodels','textclean','tm'
)
for (package in packages) {
  if (!require(package, character.only = T, quietly = T)) {
    install.packages(package)
    library(package, character.only = T)
  }
}
################
# Load data
################
tpl_clc <- read_csv("Computer_Learning_Centres.csv")
tpl_dih <- read_csv("Digital_Innovation_Hubs.csv")
tpl_kecl <- read_csv("KidsStop_Early_Literacy_Centres.csv")
tpl_nib <- read_csv("Neighbourhood_Improvement_Area_Branches.csv")
tpl <- read_csv("tpl-branch-general-information-2023.csv")
tpl_branch_card_registration <- read_csv("tpl-card-registrations-annual-by-branch-2012-2022.csv")
tpl_branch_circulation <- read_csv("tpl-circulation-annual-by-branch-2012-2022.csv")
tpl_branch_eventfeed <- read_csv("tpl-events-feed.csv")
tpl_branch_visit <- read_csv("tpl-visits-annual-by-branch-2012-2022.csv")
tpl_branch_workstation <- read_csv("tpl-workstation-usage-annual-by-branch-2012-2022.csv")
tpl_yag <- read_csv("Youth_Advisory_Groups_Locations.csv")
tpl_yh <- read_csv("Youth_Hubs_Locations.csv")
toronto_wellbeing <- read_csv("wellbeing-toronto-economics.csv")










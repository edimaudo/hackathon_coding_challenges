

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
tpl_clc <- read.csv("Computer_Learning_Centres.csv",sep = ",")  
tpl_dih <- read.csv("Digital_Innovation_Hubs.csv",sep = ",")
tpl_kecl <- read.csv("KidsStop_Early_Literacy_Centres.csv",sep = ",")
tpl_nib <- read.csv("Neighbourhood_Improvement_Area_Branches.csv",sep = ",")
tpl <- read.csv("tpl-branch-general-information-2023.csv",sep = ",")
tpl_branch_card_registration <- read.csv("tpl-card-registrations-annual-by-branch-2012-2022.csv",sep = ",")
tpl_branch_circulation <- read.csv("tpl-circulation-annual-by-branch-2012-2022.csv",sep = ",")
tpl_branch_eventfeed <- read.csv("tpl-events-feed.csv",sep = ",")
tpl_branch_visit <- read.csv("tpl-visits-annual-by-branch-2012-2022.csv",sep = ",")
tpl_branch_workstation <- read.csv("tpl-workstation-usage-annual-by-branch-2012-2022.csv",sep = ",")
tpl_yag <- read.csv("Youth_Advisory_Groups_Locations.csv",sep = ",")
tpl_yh <- read.csv("Youth_Hubs_Locations.csv",sep = ",")


tpl_library <- tpl %>%
  filter(PhysicalBranch == 1) %>%
  select(BranchName,Lat,Long,SquareFootage)

tpl_branch <- tpl %>%
  filter(PhysicalBranch == 1) %>%
  select(BranchName) %>%
  arrange()




tpl_trend <- tpl_branch_circulation %>%
  group_by(Year)%>%
  summarise(Total = sum(Circulation)) %>%
  select(Year, Circulation)


length(unique(tpl_yag$`Branch Name`))


length(tpl_yag$Branch.Name)

tpl_branch_code <- function(branchName){
  tpl_branch <- tpl %>%
    filter(BranchName == branchName) %>%
    select(BranchCode)
}
tpl_branch_code("Yorkville")[,1]

tpl_trend <- tpl_branch_card_registration %>%
  filter(BranchCode == 'YO') %>%
  group_by(Year)%>%
  summarise(Total = sum(Registrations)) %>%
  select(Year, Total)


library("lubridate")


tpl_branch_eventfeed$start_month <- unique(lubridate::month(tpl_branch_eventfeed$startdate,label=TRUE,abbr = FALSE))
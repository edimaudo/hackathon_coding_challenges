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
tpl_map <- fromJSON("Neighbourhoods.geojson")

tpl_library <- tpl %>%
  filter(PhysicalBranch == 1) %>%
  select(BranchName,Lat,Long,SquareFootage)

ggplot(tpl_library, aes(Long, Lat, group=group)) + 
  geom_point(size = .25, show.legend = FALSE) +
  coord_quickmap()

library(mapview)
library(sf)
p <- ggplot()
p <- p + geom_polygon( data=tpl_library, 
                       aes(x=Long, y=Lat, fill = SquareFootage), 
                       color="white", size = 0.2) 
p

install.packages("mapview")

mapview(tpl_library, xcol = "Long", ycol = "Lat", crs = 4269, grid = FALSE)
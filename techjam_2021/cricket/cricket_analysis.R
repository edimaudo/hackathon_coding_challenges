rm(list = ls()) #clear environment

#===================
# Packages
#===================
packages <- c('ggplot2', 'corrplot','tidyverse',"caret","dummies","fastDummies",'mlbench',
              'caTools','doParallel','scales','dplyr','readxl','FactoMineR','factoextra',
              'gridExtra','lubridate','data.table','forecast','TTR','xts')
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}

#===================
# Load Data
#===================
# ball_delivery_df <- read.delim("BallByBall_DeliveryDetails_BBL&WBBL.txt")
# ball_fixtures_df  <- read.delim("BallByBall_FixtureDetails_BBL&WBBL.txt")
# ball_players_df <- read.delim("BallByBall_PlayerDetails_BBL&WBBL.txt")
# ball_venue_df <- read.delim("BallByBall_VenueDetails_BBL&WBBL.txt")
# 
# matches_df <- read.delim("Matches.txt")
# match_players_df <- read.delim("MatchPlayers.txt")
# 
# ovals_facility_df <- read.delim("OvalsAndFacility.txt")
# ovals_facility_audit_df <- read.delim("OvalsAndFacilityAudit.txt")
# 
# players_df <- read.delim("Players.txt")
# 
# #large data
# deliveries_df <- fread("Deliveries.txt")
# ticket_sales_df <- fread("TicketSales_2016-17SeasonOnwards.txt")



#===================
# grounds
#===================
matches_df <- read.delim("Matches.txt")
ovals_facility_df <- read.delim("OvalsAndFacility.txt")
ovals_facility_audit_df <- read.delim("OvalsAndFacilityAudit.txt")

#fix column names
colnames(ovals_facility_df) <- c('PropertyID ','PropertyName ','PropertySuburb ',
                                 'PropertyRegion ','FederalElectorateDescription ',
                                 'StateElectorateDescription ','NumberOfOvals ',
                                 'PropertyState ','PropertyPostcode ',
                                 'PropertyLatitude ','PropertyLongitude ',
                                 'OvalID ','MyCricketOvalID ','OvalName ',
                                 'OvalLatitude ','OvalLongitude ',
                                 'OvalDimension ','PitchType ')
colnames(ovals_facility_audit_df) <- ()





# - **DRS**: Improve on field performance by leveraging umpire,
# grounds and match data to make decision-making easier for 
# cricket players and leaders. The idea behind this solution is to highlight areas where 
# umpires, and possibly even the team captains, are making the wrong decisions 






rm(list = ls()) #clear environment

#===================
# Packages
#===================
packages <- c('ggplot2', 'corrplot','tidyverse',"caret","dummies",'readxl',
              'scales','dplyr','mlbench','caTools','forecast','TTR','xts',
              'FactoMineR','factoextra',"fastDummies",'scales','dplyr','mlbench',
              'caTools','gridExtra','doParallel','lubridate','data.table')
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}

#===================
# Load Data
#===================
ball_delivery_df <- read.delim("BallByBall_DeliveryDetails_BBL&WBBL.txt")
ball_fixtures_df  <- read.delim("BallByBall_FixtureDetails_BBL&WBBL.txt")
ball_players_df <- read.delim("BallByBall_PlayerDetails_BBL&WBBL.txt")
ball_venue_df <- read.delim("BallByBall_VenueDetails_BBL&WBBL.txt")

matches_df <- read.delim("Matches.txt")
match_players_df <- read.delim("MatchPlayers.txt")

ovals_facility_df <- read.delim("OvalsAndFacility.txt")
ovals_facility_audit_df <- read.delim("OvalsAndFacilityAudit.txt")

players_df <- read.delim("Players.txt")

#large data
deliveries_df <- fread("Deliveries.txt")
ticket_sales_df <- fread("TicketSales_2016-17SeasonOnwards.txt")



#===================
# Check for missing information
#===================


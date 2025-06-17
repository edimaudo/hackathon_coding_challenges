#========================================
# Shiny web app which provides insights 
# for Apra data science challenge
#=========================================
rm(list = ls())
#=============
# Packages 
#=============
packages <- c(
  'ggplot2', 'corrplot','tidyverse','shiny','shinydashboard','DT','readxl',
  'mlbench','caTools','gridExtra','doParallel','grid','forecast','reshape2',
  'caret','tidyr','Matrix','lubridate','plotly','RColorBrewer',
  'data.table','scales','rfm','forecast','TTR','xts','dplyr', 'treemapify'
)
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}
#=============
# Load Data
#=============
crm <- read_csv("CRM_interacions_table.csv")
gift <- read_csv("gift_transactions_table.csv")
video <- read_csv("video_email_data_table.csv")
constituent <- read_csv("constituent_profiles_table.csv")

################
# UI
################
ui <- dashboardPage(
  dashboardHeader(title = "Apra Data Science Challenge",
                  tags$li(a(href = 'https://www.aprahome.org',
                            img(src = 'https://www.aprahome.org/Portals/_default/skins/siteskin/images/logo.png',
                                title = "Home", height = "30px"),
                            style = "padding-top:10px; padding-bottom:10px;"),
                          class = "dropdown")),
  dashboardSidebar(
    sidebarMenu(
      menuItem("About", tabName = "about", icon = icon("th")),
      menuItem("Overview", tabName = "overview", icon = icon("list")),
      menuSubItem("Weekly", tabName = "weekly"),
      menuSubItem("Monthly", tabName = "monthly"),
      menuSubItem("Yearly", tabName = "yearly"),
      menuItem("Customer Segmentation", tabName = "segment", icon = icon("list")),
      menuItem("Donor Prediction", tabName = "forecast_overview", icon = icon("list")),
      menuSubItem("Donation Forecasting ", tabName = "donation_forecast"),
      menuSubItem("Next Best Donation", tabName = "donation_prediction")
    )
  ),
  dashboardBody(
    tabItems(
      #======== 
      # About
      #======== 
      tabItem(tabName = "about",includeMarkdown("about.md"),hr()), 
    )
  )
)

 
      

################
# Server
################
server <- function(input, output,session) {}

shinyApp(ui, server)
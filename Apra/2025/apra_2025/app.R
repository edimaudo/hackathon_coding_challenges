#========================================
# Shiny web app which provides insights 
# for Apra data science challenge
#=========================================
rm(list = ls())
################
# Packages 
################
# library(ggplot2)
# library(corrplot)
# library(tidyverse)
# library(shiny)
# library(shinydashboard)
# library(mlbench)
# library(caTools)
# library(gridExtra)
# library(doParallel)
# library(grid)
# library(reshape2)
# library(caret)
# library(tidyr)
# library(Matrix)
# library(lubridate)
# library(plotly)
# library(RColorBrewer)
# library(data.table)
# library(scales)
# library(rfm)
# library(forecast)
# library(TTR)
# library(xts)
# library(dplyr)
# library(treemapify)

packages <- c(
  'ggplot2', 'corrplot','tidyverse','shiny','shinydashboard','DT',
  'mlbench','caTools','gridExtra','doParallel','grid','reshape2',
  'caret','tidyr','Matrix','lubridate','plotly','RColorBrewer',
  'data.table','scales','rfm','forecast','TTR','xts','dplyr', 'treemapify'
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
crm <- read_csv("CRM_interacions_table.csv")
gift <- read_csv("gift_transactions_table.csv")
video <- read_csv("video_email_data_table.csv")
constituent <- read_csv("constituent_profiles_table.csv")

################
# UI
################
ui <- dashboardPage(
  dashboardHeader(title = "Apra Challenge 2025",
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
      menuItem("Donor Portfolio", tabName = "segmentation", icon = icon("list")),
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
      
      #======== 
      # Overview
      #======== 
      
      #======== 
      # Donor Portfolio
      #======== 
      tabItem(tabName = "segment",
              sidebarLayout(
                sidebarPanel(width = 3,
                             selectInput("campaignInput", "Campaign", 
                                         choices = campaign, selected = campaign, multiple = TRUE),
                             selectInput("primaryUnitInput", "Primary Unit", 
                                         choices = primary_unit, selected = primary_unit,multiple = TRUE),
                             selectInput("giftTypeInput", "Gift Type", 
                                         choices = gift_type, selected = gift_type,multiple = TRUE),
                             selectInput("giftChannelInput", "Gift Channel", 
                                         choices = gift_channel, selected = gift_channel,multiple = TRUE),
                             selectInput("paymentTypeInput", "Payment Type", 
                                         choices = payment_type, selected = payment_type,multiple = TRUE),
                             submitButton("Submit")
                ),
                mainPanel(
                  fluidRow(
                    DT::dataTableOutput("rfmTable")
                  )
                )
              )
      ),
      #======== 
      # Donor Prediction
      #======== 
    )
  )
)

 
      

################
# Server
################
server <- function(input, output,session) {}

shinyApp(ui, server)
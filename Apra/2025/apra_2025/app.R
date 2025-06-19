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
# library(bslib)

packages <- c(
  'ggplot2', 'corrplot','tidyverse','shiny','shinydashboard','bslib','DT',
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

# Data Information
# RFM
segment_titles <- c("First Grade", "Loyal", "Likely to be Loyal",
                    "New Ones", "Could be Promising", "Require Assistance", "Getting Less Frequent",
                    "Almost Out", "Can't Lose Them", "Don’t Show Up at All")

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
      menuItem("Donor Portfolio", tabName = "segment", icon = icon("list")),
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
                             selectInput("rfmInput", "Portfolios", 
                                         choices = segment_titles, selected = segment_titles, multiple = TRUE),
                             submitButton("Submit")
                ),
                mainPanel(
                  fluidRow(
                    valueBox(title="Avg. Recency",value=uiOutput("valueRecency")), #theme="bg-gradient-blue"
                    valueBox(title="Avg. Frequency",value=uiOutput("valueFrequency")),
                    valueBox(title="Avg. Monetary",value=uiOutput("valueMonetary")),
                  ),
                  fluidRow(
                    plotlyOutput("rfmTreemap")),
                    plotlyOutput("rfmBarChart")),
                  ),
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
  

 
      

################
# Server
################
server <- function(input, output,session) {

  #======== 
  # Donor Portfolio
  #========
  
  forecast_analysis_df1  <- reactive({
    
  })
    forecast_data <- df2 %>%
      filter(Country %in% c(input$countryInput) , 
             Industry %in% c(input$industryInput),
             `Gas Type` %in% c(input$gasInput)) %>%
      group_by(Year) %>%
      summarize(Total = sum(Total)) %>%
      select(Year, Total)
    
    df_xts <- xts(x = forecast_data$Total, 
                  order.by = (forecast_data$Year))
    
    
  
  output$rfmTable <- renderDataTable({
    
 
    
  }) 

}

shinyApp(ui, server)
################
# Shiny web app which provides MTA Insights
################
#rm(list = ls())
################
# Libraries
################
# library(ggplot2)
# library(tidyverse)
# library(shiny)
# library(shinydashboard)
# library(DT)
# library(lubridate)
# library(plotly)
# library(stopwords)
# library(tidytext)
# library(stringr)
# library(wordcloud)
# library(wordcloud2)
# library(textmineR)
# library(topicmodels)
# library(textclean)
# library(tm)
# library(htmltools)
# library(markdown)
# library(scales)
# library(leaflet)

# remove when publihsing
packages <- c(
  'ggplot2','tidyverse',
  'shiny',
  'shinydashboard','DT',
  'lubridate','plotly','RColorBrewer','scales','stopwords',
  'tidytext','stringr','wordcloud','wordcloud2',
  'SnowballC','textmineR','topicmodels','textclean','tm','leaflet'
)
for (package in packages) { 
  if (!require(package, character.only = T, quietly = T)) {
    install.packages(package)
    library(package, character.only = T)
  }
}


################
# Data
################
mta_daily_ridership <- read.csv("MTA_Daily_Ridership.csv")
mta_monthly_ridership <- read.csv("MTA_Monthly_Ridership.csv")
mta_service_reliability <- read.csv("MTA_LIRR_Service_Reliability.csv")
mta_customer_feedback <- read.csv("MTA_Customer_Feedback.csv")
mat_customer_engagement <- read.csv("MTA_NYCT_Customer_Engagement_Statistics.csv")
mta_customer_feedback_kpi <- read.csv("MTA_NYCT_Customer_Feedback_Performance_Metrics.csv")
mta_subway_stations <- read.csv("MTA_Subway_Stations.csv")
mta_colors <- read.csv("MTA_Colors.csv")

year_data <- c(2015,2016,2017,2018,2019,2020,2021,2022,2023,2024)
month_data <- c("January",'February','March','April','May','June','July','August','September','October','November','December')

mta_service_reliability$Year <- lubridate::year(mta_service_reliability$Month)
mta_service_reliability$Month <- lubridate::month(mta_service_reliability$Month,label = TRUE,abbr = FALSE)


################
# UI
################
ui <- dashboardPage(
  #===Headers=======
  dashboardHeader(
    title = "MTA Insights",
    tags$li(a(href = 'https://new.mta.info/',
              img(src = 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/MTA_NYC_logo.svg/1200px-MTA_NYC_logo.svg.png',
                  title = "Home", height = "30px"),
              style = "padding-top:10px; padding-bottom:10px;"),
            class = "dropdown")
  ),
  #===Sidebars=======
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("house")),
      menuItem("Performance", tabName = "performance", icon = icon("book")),
      menuItem("Customer Insights", tabName = "customer", icon = icon("book")),
      menuItem("Ridership", tabName = "ridership", icon = icon("book")),
      menuItem("About", tabName = "about", icon = icon("th"))
    )
  ),
  dashboardBody(
    
    tabItems(
      
      #===About=======
      tabItem(tabName = "about",shiny::includeMarkdown("about.md"),hr()),
      #===Overview====
      tabItem(tabName = "overview",
              fluidRow(
                valueBoxOutput("operatorBox"),
                valueBoxOutput("lineBox"),
                valueBoxOutput("stationBox")
              ),
              fluidRow(
                #  - Subway stations map
              )
      ),
      #===Performance====
      tabItem(tabName = "performance",
              sidebarLayout(
                sidebarPanel(width = 3,
                             sliderInput("yearPerformanceInput", "Year",
                                         min = min(year_data), max =  max(year_data),
                                         value = c(min(year_data),max(year_data))),
                             selectInput("monthPerformanceInput", 
                                         label = "Month",
                                         choices = month_data)
                ),
                
                mainPanel (
                  
                  tabsetPanel(
                    tabPanel("Service Reliability",
                             fluidRow(
                               #plotlyOutput("eventFlowPlot")
                             ),
                    ),
                    tabPanel("Customer Feedback Metrics",
                             fluidRow(
                               
                               #plotlyOutput("sentimentPlot"),
                             )
                    )
                  )
                )
            )
      #=====Customer Insights=====
      
      #=====Ridership======
      )
    )
  )
)


################
# Server
################
server <- function(input, output, session) {
  
  output$operatorBox <- renderValueBox({
    valueBox(
      value = tags$p("# of Operators", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(length(unique(mta_colors$Operator))), 
                        style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })
  
  output$lineBox <- renderValueBox({
    valueBox(
      value = tags$p("# of Lines", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(length(unique(mta_subway_stations$Line))), 
                        style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })
  
  output$stationBox <- renderValueBox({
    valueBox(
      value = tags$p("# of Stations", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(length(unique(mta_subway_stations$Stop.Name))), 
                        style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })
  
  
  
}


# Run the application 
shinyApp(ui = ui, server = server)
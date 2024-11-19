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

# remove when publihsing
packages <- c(

  'ggplot2','tidyverse',
  'shiny',
  'shinydashboard','DT',
  'lubridate','plotly','RColorBrewer','scales','stopwords',
  'tidytext','stringr','wordcloud','wordcloud2',
  'SnowballC','textmineR','topicmodels','textclean','tm'
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

################
# UI
################
ui <- dashboardPage(
  dashboardHeader(
    title = "MTA Insights",
    tags$li(a(href = 'https://new.mta.info/',
              img(src = 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/MTA_NYC_logo.svg/1200px-MTA_NYC_logo.svg.png',
                  title = "Home", height = "30px"),
              style = "padding-top:10px; padding-bottom:10px;"),
            class = "dropdown")
  ),
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
       
      #===About====
      tabItem(tabName = "about",shiny::includeMarkdown("about.md"),hr()),
      #===Overview====
      
      tabItem(tabName = "overview",
              fluidRow(
                #valueBoxOutput("libraryBox"),
                #valueBoxOutput("libraryBox"),
                #valueBoxOutput("libraryBox"),
                #valueBoxOutput("libraryBox"),
              )
      )
    )
  )
 )


################
# Server
################
server <- function(input, output, session) {
  
}
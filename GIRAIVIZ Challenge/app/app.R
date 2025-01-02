################
# Shiny web app for GraViz Hackathon
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
# library(htmltools)
# library(markdown)
# library(leaflet)
# library(readxl)

# remove when publishing
packages <- c(
  'ggplot2','tidyverse','plotly','leaflet','readxl',
  'shiny','shinydashboard','DT','lubridate'
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
dimension_df <- read_excel("data.xlsx","Data")
ranking_df <- read_excel("data.xlsx","Rankings and Scores")

# Ranking
region <- sort(unique(ranking_df$))
sub_region <- sort(unique(ranking_df$))
country

#Dimension

################
# UI
################
ui <- dashboardPage(
  #===Headers=======
  dashboardHeader(
    title = "GIRAIVIZ Challenge 2024",
    tags$li(a(href = 'https://www.global-index.ai',
              img(src = 'https://framerusercontent.com/images/JTXP9ZslSZX5hODB4PGcwbkDnzI.svg',
                  title = "Home", height = "30px"),
              style = "padding-top:10px; padding-bottom:10px;"),
            class = "dropdown")
  ),
  #===Sidebars=======
  dashboardSidebar(
    sidebarMenu(
      menuItem("About", tabName = "about", icon = icon("house")),
      menuItem("Ranking and Scores", tabName = "rank", icon = icon("list")),
      menuItem("Themes", tabName = "theme", icon = icon("list"))
    )
  ),
  dashboardBody(
    tabItems(
      
      #===About=======
      tabItem(tabName = "about",shiny::includeMarkdown("about.md"),hr()),
      #===Overview====
      tabItem(tabName = "rank",
              fluidRow(
               
              ),
              fluidRow(
                h3("Rank",style="text-align: center;text-style:bold"),
                
                
              )
      ),
      tabItem(tabName = "theme",
              fluidRow(
               
              ),
              fluidRow(
                h3("Themes",style="text-align: center;text-style:bold"),
                
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
    





# Run the application 
shinyApp(ui = ui, server = server)
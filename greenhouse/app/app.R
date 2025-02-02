################
# Shiny web app for Greenhouse Gas Air Emissions Data
################

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
# library(RColorBrewer)
# library(scales)
# library(readxl)

packages <- c(
  'ggplot2','tidyverse','plotly','leaflet',
  'shiny','shinydashboard','readxl',
  'DT','lubridate','RColorBrewer','scales'
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
df <- read_excel("data.xlsx")

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
      menuItem("Overview", tabName = "overview", icon = icon("th")),
      menuSubItem("Interaction", tabName = "interaction"),
      menuSubItem("Gifts", tabName = "gift"),
      menuItem("Customer Segmentation", tabName = "segment", icon = icon("list")),
      menuItem("Gift Forecasting Overview", tabName = "forecast_overview", icon = icon("list")),
      menuSubItem("Gift Forecasting Analysis", tabName = "forecast_analysis"),
      menuSubItem("Gift Forecasting", tabName = "forecast")
   )
 )
)

################
# Server
################
server <- function(input, output,session) {
  
}
  
shinyApp(ui, server)
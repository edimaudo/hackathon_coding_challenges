# Shiny web app to analyze time series cpu usage
####### Libraries #####

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
# library(anomalize)

packages <- c(
  'ggplot2','tidyverse','plotly','leaflet',
  'shiny','shinydashboard','readxl',
  'xts','forecast','anomalize',
  'DT','lubridate','RColorBrewer','scales'
)
for (package in packages) { 
  if (!require(package, character.only = T, quietly = T)) {
    install.packages(package)
    library(package, character.only = T)
  }
}


#### Data ####

####### UI #########
ui <- dashboardPage(
  dashboardHeader(title = "Greenhouse Gas Emissions Data",
                  tags$li(a(href = 'https://climatedata.imf.org/datasets/c8579761f19740dfbe4418b205654ddf_0/about',
                            img(src = 'https://imf-dataviz.maps.arcgis.com/sharing/rest/content/items/bf9aa914b237454babc8ed059575c1a7/resources/imf-climate-logo.png',
                                title = "Home", height = "30px"),
                            style = "padding-top:10px; padding-bottom:10px;"),
                          class = "dropdown")
  ),
  dashboardSidebar(
    sidebarMenu(
      menuItem("About", tabName = "about", icon = icon("th")),
      menuItem("Overview", tabName = "overview", icon = icon("th")),
      menuItem("Details", tabName = "detail", icon = icon("list")), 
      menuItem("Gas Type Analysis", tabName = "analysis", icon = icon("list")),
      menuSubItem("Gas Type Forecasting", tabName = "riderhsip_forecast",icon = icon("th"))
    )
  ),
  dashboardBody(
    tabItems(
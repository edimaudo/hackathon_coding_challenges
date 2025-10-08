# US National Park Insights

# Clear setting
rm(list = ls())

################  Packages ################

library(ggplot2)
library(corrplot)
library(tidyverse)
library(shiny)
library(shinydashboard)
library(mlbench)
library(caTools)
library(gridExtra)
library(doParallel)
library(grid)
library(reshape2)
library(caret)
library(tidyr)
library(Matrix)
library(lubridate)
library(plotly)
library(RColorBrewer)
library(data.table)
library(scales)
library(rfm)
library(forecast)
library(TTR)
library(xts)
library(dplyr)
library(treemapify)
library(shinycssloaders)
library(bslib)
library(readxl)
library(htmltools)
library(markdown)
library(scales)
library(leaflet)
library(stringr)

# packages <- c(
#   'ggplot2', 'corrplot','tidyverse','shiny','shinydashboard','shinycssloaders',
#   'bslib','readxl','DT','mlbench','caTools','gridExtra','doParallel','grid',
#   'reshape2','caret','tidyr','Matrix','lubridate','plotly','RColorBrewer','stringr',
#   'data.table','scales','rfm','forecast','TTR','xts','dplyr', 'treemapify','leaflet'
# )
# for (package in packages) {
#   if (!require(package, character.only=T, quietly=T)) {
#     install.packages(package)
#     library(package, character.only=T)
#   }
# }

################ Load Data ################
parks <- read_csv("US-National-Parks_RecreationVisits_1979-2023.csv")
park_year_min <- min(parks$Year)
park_year_max <- max(parks$Year)

################ UI ################
ui <- dashboardPage(
  dashboardHeader(title = "US National Park Visits"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("About", tabName = "about", icon = icon("house")),
      menuItem("Visits Insights", tabName = "visit_insight", icon = icon("th")),
      menuItem("Visit Forecasting ", tabName = "visit_forecast",icon = icon("thumbs-up"))
    )
  ),
  dashboardBody(
    tabItems(
      ######### About #########
      tabItem(tabName = "about",includeMarkdown("about.md"),hr()), 
      
      ######### Visit Insights ######### 
      tabItem(tabName = "visit_insight",
              sidebarLayout(
                sidebarPanel(width = 2,
                             sliderInput("yearVisitInput","Year", min = park_year_min, max = park_year_max, 
                                         value = c(park_year_min,park_year_max), step = 1),
                             submitButton("Submit")
                ),
                mainPanel(width = 10,
                          layout_column_wrap(
                                             plotlyOutput("parkTrendPlot")
                          ),
                          br(),br(),
                          layout_columns_wrap(width = 1/2,
                            plotlyOutput("RegionPlot"),
                            plotlyOutput("parkPlot")
                          )
                )
            )
          )
        )
      )
    )
# Define server logic required to draw a histogram
server <- function(input, output) {


}

# Run the application 
shinyApp(ui = ui, server = server)

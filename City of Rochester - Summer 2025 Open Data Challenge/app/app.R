#========================================
# Shiny web app leveraging City of Rochester Open Data
#=========================================
rm(list = ls())
################  Packages ################
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
# library(shinycssloaders)
# library(bslib)
# library(readxl)
# library(htmltools)
# library(markdown)
# library(scales)
# library(leaflet)

packages <- c(
  'ggplot2', 'corrplot','tidyverse','shiny','shinydashboard','shinycssloaders',
  'bslib','readxl','DT','mlbench','caTools','gridExtra','doParallel','grid',
  'reshape2','caret','tidyr','Matrix','lubridate','plotly','RColorBrewer',
  'data.table','scales','rfm','forecast','TTR','xts','dplyr', 'treemapify','leaflet'
)
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}
################ Load Data ################
parks <- read_csv("parks_playground.csv")
tree <- read_csv("trees.csv")


ui <- dashboardPage(
  dashboardHeader(title = "Open Data Challenge 2025",
                  tags$li(a(href = 'https://data.cityofrochester.gov',
                            img(src = 'https://www.arcgis.com/sharing/rest/content/items/273dc226904e43f0a83baecf54a31397/resources/logo.png?v=1754582471296',
                                title = "Home", height = "30px"),
                            style = "padding-top:10px; padding-bottom:10px;"),
                          class = "dropdown")),
  dashboardSidebar(
    sidebarMenu(
      menuItem("About", tabName = "about", icon = icon("house"))#,
      #menuItem("Park Overiew", tabName = "park_overview", icon = icon("th")),
      #menuItem("Park Insights", tabName = "park_insight", icon = icon("thumbs-up")),
      
    )
  ),
  dashboardBody(
    tabItems(
      ######### About #########
      tabItem(tabName = "about",includeMarkdown("about.md"),hr())#, 
      
      ######### Park Overview ######### 
      # tabItem(tabName = "park_overview",
      #         sidebarLayout(
      #           sidebarPanel(width = 2,
      #                        sliderInput("yearDonationInput","Year", min = 2015, max = 2025, 
      #                                    value = c(2015,2025), step = 1),
      #                        selectInput("monthDonationInput", "Month", 
      #                                    choices = month_titles, selected = month_titles, multiple = TRUE),
      #                        submitButton("Submit")
      #           ),
      #           mainPanel(width = 10,
      #                     layout_column_wrap(width = 1/2,
      #                                        plotlyOutput("giftCRMPlot"),
      #                                        plotlyOutput("giftYearPlot"),
      #                     ),
      #                     br(),br(),
      #                     layout_columns(
      #                       plotlyOutput("giftMonthPlot"),
      #                       plotlyOutput("giftDOWPlot"),
      #                     )
      #           )
      #         )
      #         
      # )
    )
  ) 
)



################  Server ################
server <- function(input, output,session) {
  
}

shinyApp(ui, server)
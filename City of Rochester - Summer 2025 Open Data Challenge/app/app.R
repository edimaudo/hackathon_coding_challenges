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
parks <- read_csv("Parks_and_Playgrounds.csv")
tree <- read_csv("Trees.csv")
tree_address <- read_csv("Trees_address.csv")


ui <- dashboardPage(
  dashboardHeader(title = "Open Data Challenge 2025",
                  tags$li(a(href = 'https://data.cityofrochester.gov',
                            img(src = 'https://www.arcgis.com/sharing/rest/content/items/273dc226904e43f0a83baecf54a31397/resources/logo.png?v=1754582471296',
                                title = "Home", height = "30px"),
                            style = "padding-top:10px; padding-bottom:10px;"),
                          class = "dropdown")),
  dashboardSidebar(
    sidebarMenu(
      menuItem("About", tabName = "about", icon = icon("house")),
      menuItem("Park Overview", tabName = "park_overview", icon = icon("th"))#,
      #menuItem("Park Insights", tabName = "park_insight", icon = icon("thumbs-up")),
      
    )
  ),
  dashboardBody(
    tabItems(
      ######### About #########
      tabItem(tabName = "about",includeMarkdown("about.md"),hr()), 
      
      ######### Overview ######### 
       tabItem(tabName = "park_overview",

                 mainPanel(width = 10,
                           fluidRow(
                             column(width = 12,
                                    valueBoxOutput("speciesValueBox"),
                                    valueBoxOutput("genusValueBox"),
                                    valueBoxOutput("treeNameValueBox")
                             )
                           ),
                           br(),br(),
                          fluidRow(
                            leafletOutput("subwayMap", width = 'auto',height="600px")
                          ),   
                           layout_column_wrap(width = 1/2,
                                              plotlyOutput("giftCRMPlot"),
                                              plotlyOutput("giftYearPlot"),
                           ),
                           br(),br(),
                           layout_columns(width = 1/2,
                             plotlyOutput("giftMonthPlot"),
                             plotlyOutput("giftDOWPlot"),
                           )
                 )
               )
      ######### Insights ######### 
    )
  ) 
)



################  Server ################
server <- function(input, output,session) {
  
########## Overview #######


output$speciesValueBox <- renderValueBox({
    valueBox("Species Type", paste0(length(unique(tree$SPECIES))), icon = icon("list"),color = "aqua")
}) 

output$genusValueBox <- renderValueBox({
  valueBox("Genus Type", paste0(length(unique(tree$GENUS))), icon = icon("list"),color = "aqua")
}) 

output$treeNameValueBox <- renderValueBox({
  valueBox("Tree Tyoes", paste0(length(unique(tree$TREE_NAME_VAL))), icon = icon("list"),color = "aqua")
}) 

  
}

shinyApp(ui, server)
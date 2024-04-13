#========================================
# Shiny web app which provides insights 
# for a fundraising project
#=========================================
rm(list = ls())
#=============
# Packages 
#=============
packages <- c(
  'ggplot2', 'corrplot','tidyverse','shiny','shinydashboard','DT','readxl',
  'mlbench','caTools','gridExtra','doParallel','grid','forecast','reshape2',
  'caret','dummies','tidyr','Matrix','lubridate','plotly','RColorBrewer',
  'data.table','scales','rfm'
)
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}
#=============
# Load Data
#=============
constituent <- read_csv("Apra Constituent Data.csv")
transaction <- read_csv("Apra Gift Transactions Data.csv")
interaction <- read_csv("Apra Interactions Data.csv")

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
      menuItem("Customer Segmentation", tabName = "segment", icon = icon("list")),
      menuItem("Gift Prediction", tabName = "prediction", icon = icon("list")),
      menuItem("Gift Forecasting", tabName = "forecast", icon = icon("list"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "about",includeMarkdown("about.md"),hr()), 
      #========  
      # Segment
      #========
      tabItem(tabName = "segment",
              fluidRow(
                
              ),
      )
    )
  )
)
                
    #Apra gift transaction
#dropdown --> campaign, appeal, primary unit, gift channel, payment type, gift type            

server <- function(input, output,session) {}              

df <- reactive({
  charity_impact %>%
    filter(`Name of charity/Project` == input$charityInput)
})               
                
                
                
                
shinyApp(ui, server)
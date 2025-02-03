# Shiny web app for Greenhouse Gas Air Emissions Data

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

####### Data #######
df <- read_excel("data.xlsx")

####### UI #########


ui <- dashboardPage(
  dashboardHeader(title = "Greenhouse Gas Air Emissions Data",
                  tags$li(a(href = 'https://climatedata.imf.org/datasets/c8579761f19740dfbe4418b205654ddf_0/about',
                            img(src = 'https://imf-dataviz.maps.arcgis.com/sharing/rest/content/items/bf9aa914b237454babc8ed059575c1a7/resources/imf-climate-logo.png',
                                title = "Home", height = "30px"),
                            style = "padding-top:10px; padding-bottom:10px;"),
                          class = "dropdown")),
  dashboardSidebar(
    sidebarMenu(
      menuItem("About", tabName = "about", icon = icon("th")),
      menuItem("Overview", tabName = "overview", icon = icon("th")),
      menuItem("Details", tabName = "detail", icon = icon("list"))
   ),
   dashboardBody(
     tabItems(
      #### Overview ####
      tabItem(tabName = "overview",
              fluidRow(
                valueBoxOutput("countryBox"),
                valueBoxOutput("industryBox"),
                valueBoxOutput("gasBox")
              ),
              
              fluidRow(
                h2("Overview",style="text-align: center;text-style:bold"),
                #plotlyOutput("tplOverviewTrendPlot") 
              )
      ),
     )
   )
 )
)

####### Server #########
server <- function(input, output,session) {

  output$countryBox <- renderValueBox({
    valueBox(
      value = tags$p("Country", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(length(df$Country)), style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })
  
  
}
  
shinyApp(ui, server)
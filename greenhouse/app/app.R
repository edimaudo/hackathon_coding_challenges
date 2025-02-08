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

df2 <- df %>% 
  pivot_longer(!c("ObjectId2","Country","ISO2","ISO3","Indicator","Unit","Source","CTS Code","CTS Name","CTS Full Descriptor","Industry","Gas Type","Seasonal Adjustment","Scale"),
               names_to = 'Year',
               values_to = 'Total')

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
      menuItem("Forecasting", tabName = "forecast", icon = icon("list"))
   )
  ),
   dashboardBody(
     tabItems(
      #### About ###
      tabItem(tabName = "about",shiny::includeMarkdown("about.md"),hr()),
      #### Overview ####
      tabItem(tabName = "overview",
              fluidRow(
                valueBoxOutput("countryBox"),
                valueBoxOutput("industryBox"),
                valueBoxOutput("gasBox")
              ),
              fluidRow(
                h2("Gas Types",style="text-align: center;text-style:bold"),
                plotlyOutput("gasTypeOverviewTrendPlot") 
              )
      )
     )
   )
 )

####### Server #########
server <- function(input, output,session) {
  #### Value Boxes ####
  output$countryBox <- renderValueBox({
      valueBox(
        value = tags$p("Countries", style = "font-size: 100%;"),
        subtitle = tags$p(paste0(length(unique(df$Country))), style = "font-size: 100%;"),
        icon = icon("book"),
        color = "aqua"
      )
  })

  output$industryBox <- renderValueBox({
    valueBox(
      value = tags$p("Industries", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(length(unique(df$Industry))), style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })

  output$gasBox <- renderValueBox({
    valueBox(
      value = tags$p("Gas Type", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(length(unique(df$`Gas Type`))), style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })
  
  #### Overview Gas Type Plot ####
  output$gasTypeOverviewTrendPlot <- renderPlotly({
    
    trend <- df2  %>%
      group_by(Year, `Gas Type`) %>%
      summarise(Total = sum(Total)) %>%
      select(Year, `Gas Type`, Total)
    
    
    g <- ggplot(trend, aes(Year, Total, group=`Gas Type`, colour = `Gas Type`)) + 
      geom_line( size=1) + theme_minimal() +
      labs(x = "Year", y = "Total", color="Gas Type") + 
      scale_y_continuous(labels = comma) +
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10),
            axis.text.x = element_text(angle = 0, hjust = 1))
    
    ggplotly(g)
    
    
  })
  
}
  
shinyApp(ui, server)
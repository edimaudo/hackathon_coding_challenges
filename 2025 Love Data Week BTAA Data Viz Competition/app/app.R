# US National Park Insights

# Clear setting
rm(list = ls())

################  Packages ################

library(ggplot2)
library(corrplot)
library(tidyverse)
library(shiny)
library(shinydashboard)
library(caTools)
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
library(forecast)
library(TTR)
library(xts)
library(dplyr)
library(treemapify)
library(shinycssloaders)
library(bslib)
library(htmltools)
library(markdown)
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
                          layout_column_wrap(width = 1/2,
                                             plotlyOutput("parkTrendPlot")
                          ),
                          br(),br(),
                          layout_column_wrap(width = 1/2,
                            plotlyOutput("regionPlot"),
                            plotlyOutput("parkPlot")
                          )
                )
            )
          )
        )
      )
    )
# Define server logic
server <- function(input, output) {
  
  #Visits Insights
  
  filtered_df_visit <- reactive({
    df <- parks %>%
      filter(Year %in% c(input$yearVisitInput[1],input$yearVisitInput[2]))
  })
  
  output$parkTrendPlot <- renderPlotly({
    g <- ggplot(filtered_df_visit() , aes(Year, Total)) + 
      geom_line(size=1) + theme_minimal() +
      labs(x = "Year", y = "Total") +  scale_y_continuous(labels = comma) +
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10),
            axis.text.x = element_text(angle = 0, hjust = 1))
    
    ggplotly(g)
   
     
  })
  
  output$regionPlot <- renderPlotly({
    g <- filtered_df_visit() %>%
      group_by(Region) %>%
      summarise(Total = sum(RecreationVisits)) %>%
      select(Region, Total) %>% 
      ggplot(aes(x = reorder(Region,Total) ,y = Total))  +
      geom_bar(stat = "identity",width = 0.5, fill='black') + coord_flip() +
      labs(x ="Region", y = "Total", title="Region Visits") 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          axis.title = element_text(size = 12),
          axis.text = element_text(size = 10),
          plot.title = element_text(hjust=0.5))
    
    ggplotly(g) 
  })
  
  output$parkPlot <- renderPlotly({
    g <- filtered_df_visit() %>%
      group_by(ParkName) %>%
      summarise(Total = sum(RecreationVisits)) %>%
      select(ParkName, Total) %>% 
      ggplot(aes(x = reorder(ParkName,Total) ,y = Total))  +
      geom_bar(stat = "identity",width = 0.5, fill='black') + coord_flip() +
      labs(x ="Park", y = "Total", title="Park Visits") 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          axis.title = element_text(size = 12),
          axis.text = element_text(size = 10),
          plot.title = element_text(hjust=0.5))
    
    ggplotly(g) 
    
  })


}

# Run the application 
shinyApp(ui = ui, server = server)

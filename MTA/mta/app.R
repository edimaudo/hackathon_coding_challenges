################
# Shiny web app which provides MTA Insights
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
# library(stopwords)
# library(tidytext)
# library(stringr)
# library(wordcloud)
# library(wordcloud2)
# library(textmineR)
# library(topicmodels)
# library(textclean)
# library(tm)
# library(htmltools)
# library(markdown)
# library(scales)
# library(leaflet)

# remove when publishing
packages <- c(
  'ggplot2','tidyverse','plotly','leaflet',
  'shiny','shinyWidgets','shinydashboard',
  'DT','lubridate','RColorBrewer','scales','stopwords',
  'tidytext','stringr','wordcloud','wordcloud2',
  'SnowballC','textmineR','topicmodels','textclean','tm'
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
mta_monthly_ridership <- read.csv("MTA_Monthly_Ridership.csv")
mta_service_reliability <- read.csv("MTA_LIRR_Service_Reliability.csv")
mta_customer_feedback <- read.csv("MTA_Customer_Feedback.csv")
mat_customer_engagement <- read.csv("MTA_NYCT_Customer_Engagement_Statistics.csv")
mta_customer_feedback_kpi <- read.csv("MTA_NYCT_Customer_Feedback_Performance_Metrics.csv")
mta_subway_stations <- read.csv("MTA_Subway_Stations.csv")
mta_colors <- read.csv("MTA_Colors.csv")

# Data Updates
year_data <- c(2015,2016,2017,2018,2019,2020,2021,2022,2023,2024)
month_data <- c("January",'February','March','April','May','June','July','August','September','October','November','December')

mta_service_reliability$Year <- lubridate::year(lubridate::mdy(mta_service_reliability$Month))
mta_service_reliability$MonthName <- lubridate::month(mta_service_reliability$Month,label = TRUE,abbr = FALSE)

mta_customer_feedback_kpi$Year <- lubridate::year(lubridate::mdy(mta_customer_feedback_kpi$Month))
mta_customer_feedback_kpi$MonthName <- lubridate::month(lubridate::mdy(mta_customer_feedback_kpi$Month),label = TRUE,abbr = FALSE)

note_info <- "From 2008 onwards:"
agency <- c(sort(unique(mta_monthly_ridership$Agency)))
horizon_info <- c(1:50) #default 14
frequency_info <- c(7, 12, 52, 365)
difference_info <- c("Yes","No")
log_info <- c("Yes","No")
model_info <- c('auto-arima','auto-exponential','simple-exponential',
                'double-exponential','triple-exponential', 'tbat', 'lstm')
################
# UI
################
ui <- dashboardPage(
  #===Headers=======
  dashboardHeader(
    title = "MTA Insights",
    tags$li(a(href = 'https://new.mta.info/',
              img(src = 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/MTA_NYC_logo.svg/1200px-MTA_NYC_logo.svg.png',
                  title = "Home", height = "30px"),
              style = "padding-top:10px; padding-bottom:10px;"),
            class = "dropdown")
  ),
  #===Sidebars=======
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("house")),
      menuItem("Performance", tabName = "performance", icon = icon("list")),
      menuItem("Customer Insights", tabName = "customer", icon = icon("list")),
      menuItem("Ridership Overview", tabName = "ridership_overview", icon = icon("list")),
      menuSubItem("Riderhsip Analysis", tabName = "ridership_analysis"),
      menuSubItem("Riderhsip Forecasting", tabName = "riderhsip_forecast"),
      menuItem("About", tabName = "about", icon = icon("th"))
    )
  ),
  dashboardBody(
    
    tabItems(
      
      #===About=======
      tabItem(tabName = "about",shiny::includeMarkdown("about.md"),hr()),
      #===Overview====
      tabItem(tabName = "overview",
              fluidRow(
                valueBoxOutput("operatorBox"),
                valueBoxOutput("lineBox"),
                valueBoxOutput("stationBox")
              ),
              fluidRow(
                h3("MTA Subway Station Map",style="text-align: center;text-style:bold"),
                #  - Subway stations map
                leafletOutput("subwayMap", width = 'auto',height="600px")
              )
      ),
      #====Performance====
      tabItem(tabName = "performance",
              sidebarLayout(
                sidebarPanel(width = 3,
                             sliderInput("yearPerformanceInput", "Year",
                                         min = min(year_data), max =  max(year_data),
                                         value = c(min(year_data),max(year_data))),
                             selectInput("monthPerformanceInput", 
                                         label = "Month",choices = month_data, 
                                         selected = month_data,
                                         multiple = TRUE, width = "250px")
                ),
                
                mainPanel (
                  tabsetPanel(
                    h3("Yearly Trends",style="text-align: center;text-style:bold"),
                    tabPanel("Service Reliability",
                               fluidRow(
                                 radioButtons( 
                                   inputId = "serviceReliabilityInput", 
                                   label = "", 
                                   choices = list( 
                                     "Major Incidents" = 1, 
                                     "No of Short Trains" = 2
                                   ) ,
                                   inline=T
                                 ),
                                 plotlyOutput("serviceReliabilityTrendPlot")
                               )
                             
                    ),
                    tabPanel("Customer Feedback Metrics",
                             fluidRow(
                               radioButtons( 
                                 inputId = "customerPerformanceInput", 
                                 label = "", 
                                 choices = list( 
                                   "Total Complaints" = 1, 
                                   "Total Commendations" = 2
                                 ) ,
                                 inline=T
                               ),
                               plotlyOutput("customerPerformanceTrendPlot")
                             )
                    )
                  )
                )
            )
      #====Customer Insights=====
      
      #====Ridership=============
      tabItem(tabName = "ridership_overview",h6(note_info),
              fluidRow(
                plotlyOutput("ridershipMonthlyPlot")
              )
      ),
      tabItem(tabName = "ridership_analysis",
              sidebarLayout(
                sidebarPanel(width = 3,
                             selectInput("agencyInput", "Agency", 
                                         choices = agency, selected = agency,
                                         multiple = TRUE),
                             selectInput("frequencyInput", "Frequency", 
                                         choices = frequency_info, selected = 7),
                             radioButtons("differenceInput","Difference",
                                          choices = difference_info, selected = "No"),
                             numericInput("differenceNumericInput", "Difference Input", 
                                          1, min = 1, max = 52, step = 0.5),
                             radioButtons("logInput","Log",
                                          choices = log_info, selected = "No"),
                             submitButton("Submit")
                ),
                mainPanel(
                  h1("Analysis",style="text-align: center;"),h6(note_info),
                  tabsetPanel(type = "tabs",
                              tabPanel(
                                h4("Decomposition",
                                   style="text-align: center;"),
                                plotlyOutput("decompositionPlot")),
                              tabPanel(
                                h4("Multi seasonal Decomposition",
                                   style="text-align: center;"),
                                plotlyOutput("multidecompositionPlot")),
                              tabPanel(
                                h4("ACF Plot",style="text-align: center;"), 
                                plotlyOutput("acfPlot")),
                              tabPanel(
                                h4("PACF Plot",style="text-align: center;"), 
                                plotlyOutput("pacfPlot"))
                  )
                )
              )  
      ),
      tabItem(tabName = "riderhsip_forecast",
              sidebarLayout(
                sidebarPanel(width = 3,
                             selectInput("agencyInput", "Agency", 
                                         choices = agency, selected = agency,
                                         multiple = TRUE),
                             selectInput("horizonInput", "Horizon",
                                         choices = horizon_info, selected = 14),
                             selectInput("frequencyInput", "Frequency",
                                         choices = frequency_info, selected = 7),
                             submitButton("Submit")
                ),
                mainPanel(
                  h1("Forecasting",style="text-align: center;"),
                  tabsetPanel(type = "tabs",
                              tabPanel(h4("Forecast Visualization",style="text-align: center;"),
                                       plotOutput("forecastPlot")),
                              tabPanel(h4("Forecast Results",style="text-align: center;"),
                                       DT::dataTableOutput("forecastOutput")),
                              tabPanel(h4("Forecast Metrics",style="text-align: center;"),
                                       DT::dataTableOutput("accuracyOutput")),
                              tabPanel(h4("Forecast Prediction",style="text-align: center;"),
                                       DT::dataTableOutput("predictionOutput"))
                  )
                  
                )
              )
              
      )
      )
    )
  )
)


################
# Server
################
server <- function(input, output, session) {
  #===Overview====
  output$operatorBox <- renderValueBox({
    valueBox(
      value = tags$p("# of Operators", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(length(unique(mta_colors$Operator))), 
                        style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })
  
  output$lineBox <- renderValueBox({
    valueBox(
      value = tags$p("# of Lines", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(length(unique(mta_subway_stations$Line))), 
                        style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })
  
  output$stationBox <- renderValueBox({
    valueBox(
      value = tags$p("# of Stations", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(length(unique(mta_subway_stations$Stop.Name))), 
                        style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })
  
  output$subwayMap <- renderLeaflet({
    
    subMap <- leaflet() %>%
        addTiles() %>% 
        setView(lng=mta_subway_stations$GTFS.Longitude[1],
                         lat=mta_subway_stations$GTFS.Latitude[1],zoom=15) %>%
        addMarkers(lng=mta_subway_stations$GTFS.Longitude,
                   lat = mta_subway_stations$GTFS.Latitude,
                   popup = mta_subway_stations$Stop.Name)
   
    subMap
    
  })
  
  #===Performance====
  mta_service_reliability_df  <- reactive({
    mta_service_reliability %>%
      filter(Year %in% c(input$yearPerformanceInput[1]:input$yearPerformanceInput[2]) , 
             MonthName %in% c(input$monthPerformanceInput)) %>%
      group_by(Year,MonthName) %>%
      summarize(MajorIncidents = sum(MajorIncidents), NoofShortTrains = sum(NoofShortTrains)) %>%
      select(Year,MajorIncidents,NoofShortTrains)
  }) 
  
  
  output$serviceReliabilityTrendPlot <- renderPlotly({
    if (input$serviceReliabilityInput == 1) {
      service_trend <- mta_service_reliability_df()  %>%
        group_by(Year) %>%
        summarise(Total = sum(MajorIncidents)) %>%
        select(Year, Total)
    } else if (input$serviceReliabilityInput == 2){
      service_trend <- mta_service_reliability_df()  %>%
        group_by(Year)%>%
        summarise(Total = sum(NoofShortTrains)) %>%
        select(Year, Total)
    }

    g <- ggplot(service_trend, aes(x = Year, y = Total))  +
      geom_bar(stat = "identity",width = 0.5, fill='#0039A5') + theme_classic() +
      labs(x ="Year", y = "Total") + scale_x_continuous(breaks = breaks_pretty()) +
      scale_y_continuous(breaks = breaks_pretty(),labels = label_comma()) +
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 12),
            axis.title = element_text(size = 14),
            axis.text = element_text(size = 12))

    ggplotly(g)
    
    
  })
  
  mta_customer_feedback_kpi_df  <- reactive({
    mta_customer_feedback_kpi %>%
      filter(Year %in% c(input$yearPerformanceInput[1]:input$yearPerformanceInput[2]) , 
             MonthName %in% c(input$monthPerformanceInput)) %>%
      group_by(Year,MonthName, Subject) %>%
      summarize(Complaints = sum(Total.Complaints), Commendations = sum(Total.Commendations)) %>%
      select(Year,Subject,Commendations,Complaints)
  }) 
  
  output$customerPerformanceTrendPlot <- renderPlotly({
    if (input$customerPerformanceInput == 1) {
      service_trend <-   mta_customer_feedback_kpi_df()  %>%
        group_by(Year, Subject) %>%
        summarise(Total = sum(Complaints)) %>%
        select(Year, Subject, Total)
    } else if (input$customerPerformanceInput == 2){
      service_trend <- mta_customer_feedback_kpi_df()  %>%
        group_by(Year, Subject)%>%
        summarise(Total = sum(Commendations)) %>%
        select(Year, Subject,Total)
    }
    
    g <- ggplot(service_trend, aes(Year, Total, colour = Subject)) + 
      geom_line(size=1) + theme_minimal() +
      labs(x = "Year", y = "Total", color="Subject") +  scale_y_continuous(labels = comma) +
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10),
            axis.text.x = element_text(angle = 0, hjust = 1))
    
    ggplotly(g)
    
    
    
  })
  
 
}


# Run the application 
shinyApp(ui = ui, server = server)
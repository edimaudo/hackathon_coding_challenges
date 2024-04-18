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
  'data.table','scales','rfm','forecast','TTR','xts'
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
rfm_score <- read_excel("rfm_score.xlsx")
#=============
# Data munging
#=============
campaign <- sort(unique(na.omit(transaction$CAMPAIGN)))
appeal <- sort(unique(na.omit(transaction$APPEAL)))
primary_unit <- sort(unique(na.omit(transaction$PRIMARY_UNIT)))
payment_type <- sort(unique(na.omit(transaction$PAYMENT_TYPE)))
gift_type <- sort(unique(na.omit(transaction$GIFT_TYPE)))
gift_designation <- sort(unique(na.omit(transaction$GIFT_DESIGNATION)))
aggregate_info <- c("daily",'weekly','monthly')
horizon_info <- c(1:50) #default 14
frequency_info <- c(7, 12, 52, 365)
difference_info <- c("Yes","No")
log_info <- c("Yes","No")
model_info <- c('auto-arima','auto-exponential','simple-exponential',
                'double-exponential','triple-exponential', 'tbat','manual-arima')

#=============
# Functions
#============

forecast_data <- function(timeInput, sizeInput,frequencyInput, timeSeriesInput) {
  if (timeInput == 'daily') {
    gift.data <- apply.daily(timeSeriesInput,mean)
    gift.end <- floor(as.numeric(sizeInput)*length(gift.data)) 
    gift.train <- gift.data[1:gift.end,] 
    gift.test <- gift.data[(gift.end+1):length(gift.data),]
    gift.start <- c(year (start(gift.train)), month(start(gift.train)),
                    week(start(gift.train)))
    gift.end <- c(year(end(gift.train)), month(end(gift.train)), 
                  day(end(gift.train)))
  } else if (timeInput == 'weekly') {
    gift.data <- apply.weekly(timeSeriesInput,mean)
    gift.end <- floor(as.numeric(sizeInput)*length(gift.data)) 
    gift.train <- gift.data[1:gift.end,] 
    gift.test <- gift.data[(gift.end+1):length(gift.data),]
    gift.start <- c(year (start(gift.train)), month(start(gift.train)),
                    week(start(gift.train)))
    gift.end <- c(year(end(gift.train)), month(end(gift.train)), 
                  week(end(gift.train)))

  } else {
    gift.data <- apply.monthly(timeSeriesInput,mean)
    gift.end <- floor(as.numeric(sizeInput)*length(gift.data)) 
    gift.train <- gift.data[1:gift.end,] 
    gift.test <- gift.data[(gift.end+1):length(gift.data),]
    gift.start <- c(year (start(gift.train)), month(start(gift.train)),
                    week(start(gift.train)))
    gift.end <- c(year(end(gift.train)), month(end(gift.train)))
   
  }
  gift.train <- ts(as.numeric(gift.train), start = gift.start, 
                   end = gift.end, frequency = as.numeric(frequencyInput))
 
}


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
      menuItem("Customer Segmentation", tabName = "segment", icon = icon("list")),
      menuItem("Gift Forecasting", tabName = "forecast", icon = icon("list"))
    )
  ),
  dashboardBody(
    tabItems(
      #======== 
      # About
      #======== 
      tabItem(tabName = "about",includeMarkdown("about.md"),hr()), 
      #========  
      # Segmentation
      #========
      tabItem(tabName = "segment",
              sidebarLayout(
                sidebarPanel(width = 3,
                  selectInput("campaignInput", "Campaign", 
                              choices = campaign, selected = campaign, multiple = TRUE),
                  selectInput("primaryUnitInput", "Primary", 
                              choices = primary_unit, selected = primary_unit,multiple = TRUE),
                  selectInput("giftTypeInput", "Gift Type", 
                              choices = gift_type, selected = gift_type,multiple = TRUE),
                  selectInput("paymentTypeInput", "Payment Type", 
                              choices = payment_type, selected = payment_type,multiple = TRUE),
                  submitButton("Submit")
                ),
                mainPanel(
                  fluidRow(
                    DT::dataTableOutput("rfmTable")
                  )
                )
              )
            ),
      #========  
      # forecasting
      #======== 
      tabItem(tabName = "forecast",
              sidebarLayout(
                sidebarPanel(width = 3,
                             selectInput("aggregateInput", "Aggregate", 
                                         choices = aggregate_info, selected = 'daily'),
                             selectInput("horizonInput", "Horizon", 
                                         choices = horizon_info, selected = 14),
                             selectInput("frequencyInput", "Frequency", 
                                         choices = frequency_info, selected = 7),
                             sliderInput("traintestInput", "Train/Test Split",
                                         min = 0, max = 1,value = 0.8),
                             selectInput("modelInput", "Models",choices = model_info, 
                                                selected = model_info, multiple = TRUE),
                             sliderInput("autoInput", "Auto-regression",
                                         min = 0, max = 100,value = 0),
                             sliderInput("difference2Input", "Difference",
                                         min = 0, max = 52,value = 0),
                             sliderInput("maInput", "Moving Average",
                                         min = 0, max = 100,value = 0),
                             submitButton("Submit")
                ), 
                mainPanel(
                  h1("Forecasting",style="text-align: center;"), 
                  tabsetPanel(type = "tabs",
                              tabPanel(h4("Forecast Visualization",style="text-align: center;"), 
                                       plotOutput("forecastPlot")),
                              tabPanel(h4("Forecast Results",style="text-align: center;"), 
                                       DT::dataTableOutput("forecastOutput")),
                              tabPanel(h4("Forecast Accuracy",style="text-align: center;"), 
                                       DT::dataTableOutput("accuracyOutput"))
                  )
                    
                  )
                )
              ),
      tabItem(tabName = "overview",
              sidebarLayout(
                sidebarPanel(width = 3,
                             selectInput("aggregateInput", "Aggregate", 
                                         choices = aggregate_info, selected = 'daily'),
                             selectInput("horizonInput", "Horizon", 
                                         choices = horizon_info, selected = 14),
                             selectInput("frequencyInput", "Frequency", 
                                         choices = frequency_info, selected = 7),
                             sliderInput("traintestInput", "Train/Test Split",
                                         min = 0, max = 1,value = 0.8),
                             selectInput("modelInput", "Models",choices = model_info, 
                                         selected = model_info, multiple = TRUE),
                             sliderInput("autoInput", "Auto-regression",
                                         min = 0, max = 100,value = 0),
                             sliderInput("difference2Input", "Difference",
                                         min = 0, max = 52,value = 0),
                             sliderInput("maInput", "Moving Average",
                                         min = 0, max = 100,value = 0),
                             submitButton("Submit")
                ), 
                mainPanel(
                  h1("Forecasting",style="text-align: center;"), 
                  tabsetPanel(type = "tabs",
                              tabPanel(h4("Forecast Visualization",style="text-align: center;"), 
                                       plotOutput("forecastPlot")),
                              tabPanel(h4("Forecast Results",style="text-align: center;"), 
                                       DT::dataTableOutput("forecastOutput")),
                              tabPanel(h4("Forecast Accuracy",style="text-align: center;"), 
                                       DT::dataTableOutput("accuracyOutput"))
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
server <- function(input, output,session) {
  
#=============
# RFM analysis
#=============
output$rfmTable <- renderDataTable({
  
  rfm_data <- transaction %>%
    filter(CAMPAIGN %in% input$campaignInput,
           PRIMARY_UNIT %in% input$primaryUnitInput,
           PAYMENT_TYPE %in%  input$paymentTypeInput,
           GIFT_TYPE %in%  input$giftTypeInput#,
           ) %>%
    na.omit()

  rfm_data_orders <- rfm_data %>%
    mutate("customer_id" = CONTACT_ID, "order_date" = GIFT_DATE, "revenue" = GIFT_AMOUNT) %>%
    select(customer_id, order_date, revenue) %>%
    distinct()
  
  analysis_date <- lubridate::as_date(min(interaction$INTERACTION_DATE))
  rfm_result <- rfm_table_order(rfm_data_orders, customer_id, order_date, revenue, analysis_date)
  
  df_rfm_segment <-  right_join(rfm_score,rfm_segment(rfm_result),by="rfm_score") %>%
    select(customer_id, rfm_segment,rfm_score, transaction_count, recency_days, amount)
  
})  

#==================
# Forecast Results
#==================
gift_xts <- reactive({
  
  df_forecast <- transaction %>%
    group_by(GIFT_DATE) %>%
    summarise(Total = sum(GIFT_AMOUNT)) %>%
    select(GIFT_DATE,Total)
  gift.xts <- xts(x = df_forecast$Total, order.by = df_forecast$GIFT_DATE) 
  
})
  
  #gift.weekly <- apply.weekly(gift_xts(), mean) 
  #gift.monthly <- apply.monthly(gift_xts(), mean) 
  
 
  




output$forecastPlot <- renderPlot({
  
})

output$forecastOutput <- DT::renderDataTable({
  
})

output$accuracyOutput <- DT::renderDataTable({
  
})
                
}             
                
shinyApp(ui, server)
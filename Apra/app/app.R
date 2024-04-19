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
gift_channel <- sort(unique(na.omit(transaction$GIFT_CHANNEL)))
aggregate_info <- c("daily",'weekly','monthly')
horizon_info <- c(1:50) #default 14
frequency_info <- c(7, 12, 52, 365)
difference_info <- c("Yes","No")
log_info <- c("Yes","No")
model_info <- c('auto-arima','auto-exponential','simple-exponential',
                'double-exponential','triple-exponential', 'tbat','manual-arima')




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
                  selectInput("primaryUnitInput", "Primary Unit", 
                              choices = primary_unit, selected = primary_unit,multiple = TRUE),
                  selectInput("giftTypeInput", "Gift Type", 
                              choices = gift_type, selected = gift_type,multiple = TRUE),
                  selectInput("giftChannelInput", "Gift Channel", 
                              choices = gift_channel, selected = gift_channel,multiple = TRUE),
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

      #=========
      # Overview
      #=========
      tabItem(tabName = "overview",
                fluidRow(),
              
                  tabsetPanel(type = "tabs",
                              tabPanel(h4("Gift",style="text-align: center;"), 
                                       plotOutput("forecastPlot")),
                              tabPanel(h4("Interaction",style="text-align: center;"), 
                                       DT::dataTableOutput("forecastOutput"))
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
# EDA  
#=============  

#=============
# RFM analysis
#=============
output$rfmTable <- renderDataTable({
  
  rfm_data <- transaction %>%
    filter(CAMPAIGN %in% input$campaignInput,
           PRIMARY_UNIT %in% input$primaryUnitInput,
           PAYMENT_TYPE %in%  input$paymentTypeInput,
           GIFT_TYPE %in%  input$giftTypeInput,
           GIFT_CHANNEL %in% input$giftChannelInput
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
  
output$forecastPlot <- renderPlot({
  
})

output$forecastOutput <- DT::renderDataTable({
  
})

output$accuracyOutput <- DT::renderDataTable({
  
})
                
}             
                
shinyApp(ui, server)
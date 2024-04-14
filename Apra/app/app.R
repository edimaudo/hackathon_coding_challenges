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
      #======== 
      # About
      #======== 
      tabItem(tabName = "about",includeMarkdown("about.md"),hr()), 
      #========  
      # Segment
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
      # ML model
      #======== 
      tabItem(tabName = "prediction",
              sidebarLayout(
                sidebarPanel(width = 3,
                  selectInput("campaignInput", "Campaign", 
                            choices = campaign, selected = campaign, multiple = TRUE)
                  
                ), 
                mainPanel(
                  fluidRow(
                    
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
  

# RFM analysis
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
                
}             
                
shinyApp(ui, server)
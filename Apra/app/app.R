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
      menuSubItem("Interaction", tabName = "interaction"),
      menuSubItem("Gifts", tabName = "gift"),
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
              fluidRow(
                valueBoxOutput("interactionTypeBox"),
                valueBoxOutput("interactionSummaryBox"),
                valueBoxOutput("campaignBox")
              ),
              fluidRow(
                valueBoxOutput("appealBox"),
                valueBoxOutput("primaryUnitBox"),
                valueBoxOutput("giftChannelBox")
              ),
              fluidRow(
                valueBoxOutput("paymentTypeBox"),
                valueBoxOutput("giftDesgnationBox"),
                valueBoxOutput("giftTypeBox")
              ),
              fluidRow(
                h2("Interaction",style="text-align: center;"),
                plotlyOutput("interactionOverviewOutput"),
                h2("Gifts",style="text-align: center;"),
                plotlyOutput("giftOverviewOutput")
              )
              
      ), 
      tabItem(tabName = "interaction",
              tabsetPanel(type = "tabs",
                          tabPanel(h4("Interaction Trends",style="text-align: center;"), 
                                   plotlyOutput("interactionOverviewPlot"),
                                   plotlyOutput("interactionYearPlot"),
                                   plotlyOutput("interactionQuarterPlot"), 
                                   plotlyOutput("interactionMonthPlot"), 
                                   plotlyOutput("interactionDOWPlot")
                          ),
                          tabPanel(h4("Interaction Insights",style="text-align: center;"), 
                                            DT::dataTableOutput("interactionInsightsOutput")),
                          tabPanel(h4("Interaction Flow",style="text-align: center;"), 
                                            DT::dataTableOutput("interactionFlowOutput"))
                          )
              ),
              tabItem(tabName = "gift",
                      tabsetPanel(type = "tabs",
                                  tabPanel(h4("Gift Trends",style="text-align: center;"), 
                                           plotlyOutput("giftTrendPlot")),
                                  tabPanel(h4("Gift Insights",style="text-align: center;"), 
                                           DT::dataTableOutput("giftInsightsOutput")),
                                  tabPanel(h4("Gift Flow",style="text-align: center;"), 
                                           DT::dataTableOutput("giftFlowOutput"))
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
    # Overview
    #=============
    output$interactionTypeBox <- renderValueBox({
      valueBox("Interaction Type", paste0(length(unique(interaction$INTERACTION_TYPE))), icon = icon("list"),color = "aqua")
    })  
    
    output$interactionSummaryBox <- renderValueBox({
      valueBox("Interaction Summary", paste0(length(unique(interaction$INTERACTION_SUMMARY))), icon = icon("list"),color = "aqua")
    })
    
    output$giftAmtBox <- renderValueBox({
      valueBox("Avg. Gift Amt.", paste0(round(mean(transaction$GIFT_AMOUNT)),2), icon = icon("thumbs-up"),color = "green")
    })  
    
    output$campaignBox <- renderValueBox({
      valueBox("Campaign", paste0(length(unique(transaction$CAMPAIGN))), icon = icon("list"),color = "aqua")
    })
    
    output$appealBox <- renderValueBox({
      valueBox("Appeals", paste0(length(unique(transaction$APPEAL))), icon = icon("list"),color = "aqua")
    })
    
    output$primaryUnitBox <- renderValueBox({
      valueBox("Primary Unit", paste0(length(unique(transaction$PRIMARY_UNIT))), icon = icon("list"),color = "aqua")
    })
    
    output$giftChannelBox <- renderValueBox({
      valueBox("Gift Channel", paste0(length(unique(transaction$GIFT_CHANNEL))), icon = icon("list"),color = "aqua")
    })
    
    output$paymentTypeBox <- renderValueBox({
      valueBox("Payment Type", paste0(length(unique(transaction$PAYMENT_TYPE))), icon = icon("list"),color = "aqua")
    })
    
    output$giftDesgnationBox <- renderValueBox({
      valueBox("Gift Designation", paste0(length(unique(transaction$GIFT_DESIGNATION))), icon = icon("list"),color = "aqua")
    })
    
    output$giftTypeBox <- renderValueBox({
      valueBox("Gift Type", paste0(length(unique(transaction$GIFT_TYPE))), icon = icon("list"),color = "aqua")
    })
    
    output$interactionOverviewOutput <- renderPlotly({
      
      g <- interaction %>%
        group_by(INTERACTION_DATE) %>%
        filter(INTERACTION_DATE <= today()) %>%
        summarise(Total = sum(SUBSTANTIVE_INTERACTION)) %>%
        select(INTERACTION_DATE, Total) %>%
        ggplot(aes(x = INTERACTION_DATE ,y = Total))  +
        geom_line() + theme_classic() + 
        labs(x ="Interaction Type", y = "Total Interactions") 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 12),
            axis.title = element_text(size = 14),
            axis.text = element_text(size = 12))
      
      ggplotly(g)
      
    })
    
    output$giftOverviewOutput <- renderPlotly({
      
      g <- transaction %>%
        filter(GIFT_DATE <= today()) %>%
        group_by(GIFT_DATE) %>%
        summarise(Total = sum(GIFT_AMOUNT)) %>%
        select(GIFT_DATE, Total) %>%
        ggplot(aes(x = GIFT_DATE ,y = Total))  +
        geom_line(stat ="identity") + theme_classic() + 
        labs(x ="Gift Date", y = "Gift Amount") + scale_y_continuous(labels = scales::comma) + 
        theme(legend.text = element_text(size = 12),
              legend.title = element_text(size = 12),
              axis.title = element_text(size = 14),
              axis.text = element_text(size = 12))
      
      ggplotly(g)
      
    })
    
    #==========
    # Interaction Trends
    #==========
    
    interaction_df <- interaction %>%
      mutate(year = lubridate::year(INTERACTION_DATE),
             quarter = lubridate::quarter(INTERACTION_DATE),
             month = lubridate::year(INTERACTION_DATE),
             dow = lubridate::wday(INTERACTION_DATE, label=TRUE)
      )
    
    
    
    
    
    
    
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
    
  }             
  
  shinyApp(ui, server)
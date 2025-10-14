#========================================
# Shiny web app which provides insights 
# for the 2024 Apra Challenge
#=========================================
rm(list = ls())
#=============
# Packages 
#=============
packages <- c(
  'ggplot2', 'corrplot','tidyverse','shiny','shinydashboard','DT','readxl',
  'mlbench','caTools','gridExtra','doParallel','grid','forecast','reshape2',
  'caret','tidyr','Matrix','lubridate','plotly','RColorBrewer',
  'data.table','scales','rfm','forecast','TTR','xts','dplyr'
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

#=============
# Drop downs
#=============
aggregate_info <- c("daily",'weekly','monthly')
horizon_info <- c(1:50) #default 14
frequency_info <- c(7, 12, 52, 365)
difference_info <- c("Yes","No")
log_info <- c("Yes","No")
model_info <- c('auto-arima','auto-exponential','simple-exponential',
                'double-exponential','triple-exponential', 'tbat','manual-arima')
note_info <- "Using only data from 2010 onwards"
forecast_info <- "Series: forecast data"
gift_train_df <- as.data.frame(tibble())
gift_test_df <- as.data.frame(tibble())
#=============
# Forecast info
#=============
# generating range of dates 
start_date <- as.Date("2010-01-01") 
end_date <- as.Date(today()) 
date_range <- data.frame(seq(start_date, end_date,"days")) 
gift_data <- data.frame(data=c(1:nrow(date_range)))
colnames(date_range) <- "GIFT_DATE"
date_range <- cbind(date_range,gift_data)

# transaction
transaction_f1 <- transaction %>%
  filter(GIFT_DATE >= '2010-01-01',GIFT_DATE <= today()) %>%
  group_by(GIFT_DATE) %>%
  summarise(Total = sum(GIFT_AMOUNT)) %>%
  right_join(date_range,by='GIFT_DATE', copy = TRUE) %>%
  replace(is.na(.), 0) %>%
  select(GIFT_DATE,Total)
  #select(GIFT_DATE,Total)

transaction_f <- transaction_f1 %>%
  right_join(date_range,by='GIFT_DATE', copy = TRUE) %>%
  replace(is.na(.), 0) %>%
  select(GIFT_DATE,Total)

gift_xts <- xts(x = transaction_f$Total, order.by = transaction_f$GIFT_DATE) 
gift_daily <- apply.daily(gift_xts,mean)
gift_weekly <- apply.weekly(gift_xts, mean) 
gift_monthly <- apply.monthly(gift_xts, mean) 

forecast_df <- function (ts_df,aggregateInput,frequencyInput,dataType) {
  if(aggregateInput == 'daily'){
    gift_data <- apply.daily(ts_df,mean)
    gift_end <- floor(0.8*length(gift_data)) 
    gift_train <- gift_data[1:gift_end,] 
    gift_test <- gift_data[(gift_end+1):length(gift_data),]
    gift_start <- c(year (start(gift_train)), month(start(gift_train)),
                    day(start(gift_train)))
    gift_end <- c(year(end(gift_train)), month(end(gift_train)), 
                  day(end(gift_train)))
    gift_train <- ts(as.numeric(gift_train), start = gift_start, 
                     end = gift_end, frequency = as.numeric(frequencyInput) )
    gift_start <- c(year (start(gift_test)), month(start(gift_test)),
                    day(start(gift_test)))
    gift_end <- c(year(end(gift_test)), month(end(gift_test)), 
                  day(end(gift_test)))
    gift_test <- ts(as.numeric(gift_test), start = gift_start, 
                    end = gift_end, frequency = as.numeric(frequencyInput))
  } else if(aggregateInput == 'weekly'){
    gift_data <- apply.weekly(ts_df, mean) 
    gift_end <- floor(0.8*length(gift_data)) 
    gift_train <- gift_data[1:gift_end,] 
    gift_test <- gift_data[(gift_end+1):length(gift_data),]
    gift_start <- c(year (start(gift_train)), month(start(gift_train)),
                    week(start(gift_train)))
    gift_end <- c(year(end(gift_train)), month(end(gift_train)), 
                  week(end(gift_train)))
    gift_train <- ts(as.numeric(gift_train), start = gift_start, 
                     end = gift_end, frequency = as.numeric(frequencyInput) )
    gift_start <- c(year (start(gift_test)), month(start(gift_test)),
                    week(start(gift_test)))
    gift_end <- c(year(end(gift_test)), month(end(gift_test)), 
                  week(end(gift_test)))
    gift_test <- ts(as.numeric(gift_test), start = gift_start, 
                    end = gift_end, frequency = as.numeric(frequencyInput))
  } else {
    gift_data <- apply.monthly(ts_df, mean) 
    gift_end <- floor(0.8*length(gift_data)) 
    gift_train <- gift_data[1:gift_end,] 
    gift_test <- gift_data[(gift_end+1):length(gift_data),]
    gift_start <- c(year (start(gift_train)), month(start(gift_train)))
    gift_end <- c(year(end(gift_train)), month(end(gift_train)))
    gift_train <- ts(as.numeric(gift_train), start = gift_start, 
                     end = gift_end, frequency = as.numeric(frequencyInput) )
    gift_start <- c(year (start(gift_test)), month(start(gift_test)))
    gift_end <- c(year(end(gift_test)), month(end(gift_test)))
    gift_test <- ts(as.numeric(gift_test), start = gift_start, 
                    end = gift_end, frequency = as.numeric(frequencyInput))
  }
  
  if (dataType == "train") {
    output <- gift_train
  } else {
    output <- gift_test
  }
  output
  
}

numeric_update <- function(df){
  rownames(df) <- c()
  is.num <- sapply(df, is.numeric)
  df[is.num] <- lapply(df[is.num], round, 0)           
  return (df)
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
      menuSubItem("Interaction", tabName = "interaction"),
      menuSubItem("Gifts", tabName = "gift"),
      menuItem("Customer Segmentation", tabName = "segment", icon = icon("list")),
      menuItem("Gift Forecasting Overview", tabName = "forecast_overview", icon = icon("list")),
      menuSubItem("Gift Forecasting Analysis", tabName = "forecast_analysis"),
      menuSubItem("Gift Forecasting", tabName = "forecast")
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
                plotlyOutput("interactionOverviewOutput"),
                plotlyOutput("giftOverviewOutput")
              )
              
      ), 
      #=========
      # Interaction
      #=========
      tabItem(tabName = "interaction",
              tabsetPanel(type = "tabs",
                          tabPanel(h4("Interaction Trends",style="text-align: center;"), 
                                   plotlyOutput("interactionYearPlot"),
                                   plotlyOutput("interactionQuarterPlot"), 
                                   plotlyOutput("interactionMonthPlot"), 
                                   plotlyOutput("interactionDOWPlot")
                          ),
                          tabPanel(h4("Interaction Insights",style="text-align: center;"), 
                                   plotlyOutput("interactionInsightPlot")),
                          tabPanel(h4("Interaction Flow",style="text-align: center;"),
                                   plotlyOutput("interactionFlowPlot"))
                  )
              ),
      #=========
      # Gift
      #=========
      tabItem(tabName = "gift",
              tabsetPanel(type = "tabs",
                          tabPanel(h4("Gift Trends",style="text-align: center;"),h6(note_info), 
                                           plotlyOutput("giftYearPlot"),
                                           plotlyOutput("giftQuarterPlot"), 
                                           plotlyOutput("giftMonthPlot"), 
                                           plotlyOutput("giftDOWPlot"),
                                           plotlyOutput("giftAmtPaymentTypePlot"),
                                           plotlyOutput("giftAmtGiftChannelPlot"),
                                           plotlyOutput("giftAmtGiftTypePlot")
                                           ),
                            tabPanel(h4("Gift Insights",style="text-align: center;"),h6(note_info), 
                                          plotlyOutput("giftchannelInsightPlot"), 
                                          plotlyOutput("giftpaymentTypePlot"), 
                                          plotlyOutput("giftTypePlot")),
                            tabPanel(h4("Gift Flow",style="text-align: center;"),h6(note_info),
                                           plotlyOutput("giftFlowPlot"))
              )      
            ), 
      #=========
      # Forecasting
      #=========
      tabItem(tabName = "forecast_overview",h6(note_info),
              fluidRow(
                plotlyOutput("giftDailyPlot"),br(),br(),
                plotlyOutput("giftWeeklyPlot"),br(),br(),
                plotlyOutput("giftMonthlyPlot")
              )
          ),
      tabItem(tabName = "forecast_analysis",
              sidebarLayout(
                sidebarPanel(width = 3,
                  selectInput("aggregateInput", "Aggregate", 
                              choices = aggregate_info, selected = 'daily'),
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
      tabItem(tabName = "forecast",
              sidebarLayout(
                sidebarPanel(width = 3,
                             selectInput("aggregateInput", "Aggregate",
                                         choices = aggregate_info, selected = 'daily'),
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
                                       DT::dataTableOutput("accuracyOutput"))#,
                              #tabPanel(h4("Forecast Prediction",style="text-align: center;"),
                              #         DT::dataTableOutput("predictionOutput"))
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
    # Data 
    #============= 
    interaction_df <- reactive({
      interaction %>%
        mutate(Year = lubridate::year(INTERACTION_DATE),
               Quarter = lubridate::quarter(INTERACTION_DATE),
               Month = lubridate::month(INTERACTION_DATE, label = TRUE),
               DOW = lubridate::wday(INTERACTION_DATE, label=TRUE))
      
    })
    
    transaction_df <- reactive({
      transaction %>%
        filter(GIFT_DATE >= '2010-01-01',GIFT_DATE <= today()) %>%
        mutate(Year = lubridate::year(GIFT_DATE),
               Quarter = lubridate::quarter(GIFT_DATE),
               Month = lubridate::month(GIFT_DATE, label = TRUE),
               DOW = lubridate::wday(GIFT_DATE, label=TRUE))
    })
    
    forecast_analysis_df <- reactive({
      gift_daily <- apply.daily(gift_xts,mean)
      gift_weekly <- apply.weekly(gift_xts, mean) 
      gift_monthly <- apply.monthly(gift_xts, mean) 
      
      if (input$aggregateInput == 'daily'){
        gift_end <- floor(1*length(gift_daily)) 
        gift_data <- gift_daily[1:gift_end,] 
        gift_start <- c(year (start(gift_data)), month(start(gift_data)),
                        day(start(gift_data)))
        gift_end <- c(year(end(gift_data)), month(end(gift_data)), 
                      day(end(gift_data)))
        gift_data <- ts(as.numeric(gift_data), start = gift_start, 
                        end = gift_end, frequency = as.numeric(input$frequencyInput))             
      } else if(input$aggregateInput == 'weekly'){
        gift_end <- floor(1*length(gift_weekly)) 
        gift_data <- gift_weekly[1:gift_end,] 
        gift_start <- c(year (start(gift_data)), month(start(gift_data)),
                        week(start(gift_data)))
        gift_end <- c(year(end(gift_data)), month(end(gift_data)), 
                      week(end(gift_data)))
        gift_data <- ts(as.numeric(gift_data), start = gift_start, 
                        end = gift_end, frequency = as.numeric(input$frequencyInput))         
      } else if(input$aggregateInput == 'monthly') {
        gift_end <- floor(1*length(gift_monthly)) 
        gift_data <- gift_monthly[1:gift_end,] 
        gift_start <- c(year (start(gift_data)), month(start(gift_data)))
        gift_end <- c(year(end(gift_data)), month(end(gift_data)))
        gift_data <- ts(as.numeric(gift_data), start = gift_start, 
                        end = gift_end, frequency = as.numeric(input$frequencyInput))               
      }
      
      if (input$differenceInput == "Yes"){
        gift_data <- diff(gift_data, differences = as.numeric(input$differenceNumericInput)) 
      }
      
      gift_data
      
    })
    
    
      
    
    
    #=============
    # Overview
    #=============
    output$interactionTypeBox <- renderValueBox({
      valueBox("Interaction Type", paste0(length(unique(interaction_df()$INTERACTION_TYPE))), icon = icon("list"),color = "aqua")
    })  
    
    output$interactionSummaryBox <- renderValueBox({
      valueBox("Interaction Summary", paste0(length(unique(interaction_df()$INTERACTION_SUMMARY))), icon = icon("list"),color = "aqua")
    })
    
    output$giftAmtBox <- renderValueBox({
      valueBox("Avg. Gift Amt.", paste0(round(mean(transaction_df()$GIFT_AMOUNT)),2), icon = icon("thumbs-up"),color = "green")
    })  
    
    output$campaignBox <- renderValueBox({
      valueBox("Campaign", paste0(length(unique(transaction_df()$CAMPAIGN))), icon = icon("list"),color = "aqua")
    })
    
    output$appealBox <- renderValueBox({
      valueBox("Appeals", paste0(length(unique(transaction_df()$APPEAL))), icon = icon("list"),color = "aqua")
    })
    
    output$primaryUnitBox <- renderValueBox({
      valueBox("Primary Unit", paste0(length(unique(transaction_df()$PRIMARY_UNIT))), icon = icon("list"),color = "aqua")
    })
    
    output$giftChannelBox <- renderValueBox({
      valueBox("Gift Channel", paste0(length(unique(transaction_df()$GIFT_CHANNEL))), icon = icon("list"),color = "aqua")
    })
    
    output$paymentTypeBox <- renderValueBox({
      valueBox("Payment Type", paste0(length(unique(transaction_df()$PAYMENT_TYPE))), icon = icon("list"),color = "aqua")
    })
    
    output$giftDesgnationBox <- renderValueBox({
      valueBox("Gift Designation", paste0(length(unique(transaction_df()$GIFT_DESIGNATION))), icon = icon("list"),color = "aqua")
    })
    
    output$giftTypeBox <- renderValueBox({
      valueBox("Gift Type", paste0(length(unique(transaction_df()$GIFT_TYPE))), icon = icon("list"),color = "aqua")
    })
    
    
    #=============
    # Interaction Data plots
    #=============
    output$interactionOverviewOutput <- renderPlotly({
      
      g <- interaction_df() %>%
        group_by(INTERACTION_DATE) %>%
        filter(INTERACTION_DATE <= today()) %>%
        summarise(Total = sum(SUBSTANTIVE_INTERACTION)) %>%
        select(INTERACTION_DATE, Total) %>%
        ggplot(aes(x = INTERACTION_DATE ,y = Total))  +
        geom_line()  + 
        labs(x ="Date", y = "Total Interactions") 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 12),
            axis.title = element_text(size = 14),
            axis.text = element_text(size = 12))
      
      ggplotly(g)
      
    })

    output$interactionYearPlot <- renderPlotly({
      g <- interaction_df() %>%
        filter(INTERACTION_DATE <= today()) %>%
        group_by(Year) %>%
        summarise(Total = sum(SUBSTANTIVE_INTERACTION)) %>%
        select(Year, Total) %>%
        ggplot(aes(x = as.factor(Year) ,y = Total))  +
        geom_bar(stat = "identity",width = 0.5, fill='black') +
        labs(x ="Years", y = "Total Interactions") 
        theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 12),
            axis.title = element_text(size = 14),
            axis.text = element_text(size = 12))
      
      ggplotly(g)
    })
    output$interactionQuarterPlot <- renderPlotly({
      g <- interaction_df() %>%
        filter(INTERACTION_DATE <= today()) %>%
        group_by(Quarter) %>%
        summarise(Total = sum(SUBSTANTIVE_INTERACTION)) %>%
        select(Quarter, Total) %>%
        ggplot(aes(x = as.factor(Quarter) ,y = Total))  +
        geom_bar(stat = "identity",width = 0.5, fill='black')  +
        labs(x ="Quarter", y = "Total Interactions") 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 12),
            axis.title = element_text(size = 14),
            axis.text = element_text(size = 12))
      
      ggplotly(g)
      
    })
    output$interactionMonthPlot <- renderPlotly({
      g <- interaction_df() %>%
        filter(INTERACTION_DATE <= today()) %>%
        group_by(Month) %>%
        summarise(Total = sum(SUBSTANTIVE_INTERACTION)) %>%
        select(Month, Total) %>%
        ggplot(aes(x = as.factor(Month) ,y = Total))  +
        geom_bar(stat = "identity",width = 0.5, fill='black')  +
        labs(x ="Month", y = "Total Interactions") 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 12),
            axis.title = element_text(size = 14),
            axis.text = element_text(size = 12))
      
      ggplotly(g)
      
    })
    output$interactionDOWPlot <- renderPlotly({
      g <- interaction_df() %>%
        filter(INTERACTION_DATE <= today()) %>%
        group_by(DOW) %>%
        summarise(Total = sum(SUBSTANTIVE_INTERACTION)) %>%
        select(DOW, Total) %>%
        ggplot(aes(x = as.factor(DOW) ,y = Total))  +
        geom_bar(stat = "identity",width = 0.5, fill='black')  +
        labs(x ="Day of Week", y = "Total Interactions") 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 12),
            axis.title = element_text(size = 14),
            axis.text = element_text(size = 12))
      
      ggplotly(g)
      
    })
    
    output$interactionInsightPlot <- renderPlotly({
      g <- interaction_df() %>%
        filter(INTERACTION_DATE <= today()) %>%
        group_by(INTERACTION_TYPE) %>%
        summarise(Total = sum(SUBSTANTIVE_INTERACTION)) %>%
        select(INTERACTION_TYPE, Total) %>%
        ggplot(aes(x = reorder(INTERACTION_TYPE,Total) ,y = Total))  +
        geom_bar(stat = "identity",width = 0.5, fill='black')  + 
        labs(x ="Interaction Type", y = "Total Interactions") + coord_flip() +
        theme(legend.text = element_text(size = 12),
              legend.title = element_text(size = 12),
              axis.title = element_text(size = 14),
              axis.text = element_text(size = 12))
      
      ggplotly(g)
    })
    
    
    output$interactionFlowPlot <- renderPlotly({
      frequencies <- interaction_df() %>% 
        count(INTERACTION_TYPE, INTERACTION_SUMMARY) %>% 
        arrange(INTERACTION_TYPE, desc(n))
      
      # create a table of frequencies
      freq_table <- interaction_df() %>% group_by(INTERACTION_TYPE, INTERACTION_SUMMARY) %>% 
        summarise(n = n())
      
      # create a nodes data frame
      nodes <- data.frame(name = unique(c(as.character(freq_table$INTERACTION_TYPE),
                                          as.character(freq_table$INTERACTION_SUMMARY))))
      
      
      
      # create links dataframe
      links <- data.frame(source = match(freq_table$INTERACTION_TYPE, nodes$name) - 1,
                          target = match(freq_table$INTERACTION_SUMMARY, nodes$name) - 1,
                          value = freq_table$n,
                          stringsAsFactors = FALSE)
      
      links <- rbind(links,
                     data.frame(source = match(freq_table$INTERACTION_TYPE, nodes$name) - 1,
                                target = match(freq_table$INTERACTION_SUMMARY, nodes$name) - 1,
                                value = freq_table$n,
                                stringsAsFactors = FALSE))
      
      
      # Make Sankey diagram
      plot_ly(
        type = "sankey",
        orientation = "h",
        node = list(pad = 15,
                    thickness = 35,
                    line = list(color = "black", width = 0.3),
                    label = nodes$name),
        link = list(source = links$source,
                    target = links$target,
                    value = links$value),
        textfont = list(size = 10),
        width = 900,
        height = 600
      ) %>%
        layout(title = "Interaction Type --> Interaction Summary",
               font = list(size = 14),
               margin = list(t = 40, l = 10, r = 10, b = 10))
    })
    #=============
    # Gift Data Plots
    #=============
    output$giftOverviewOutput <- renderPlotly({
      
      g <- transaction_df() %>%
        group_by(GIFT_DATE) %>%
        summarise(Total = sum(GIFT_AMOUNT)) %>%
        select(GIFT_DATE, Total) %>%
        ggplot(aes(x = GIFT_DATE ,y = Total))  +
        geom_line(stat ="identity")  + 
        labs(x ="Gift Date", y = "Gift Amount") + scale_y_continuous(labels = scales::comma) + 
        theme(legend.text = element_text(size = 12),
              legend.title = element_text(size = 12),
              axis.title = element_text(size = 14),
              axis.text = element_text(size = 12))
      
      ggplotly(g)
      
    })

    output$giftYearPlot <- renderPlotly({
      g <- transaction_df() %>%
        group_by(Year) %>%
        summarise(Total = sum(GIFT_AMOUNT)) %>%
        select(Year, Total) %>%
        ggplot(aes(x = as.factor(Year) ,y = Total))  +
        geom_bar(stat = "identity",width = 0.5, fill='black') + 
        scale_y_continuous(labels = scales::comma) + 
        labs(x ="Year", y = "Gift Amount") 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 12),
            axis.title = element_text(size = 14),
            axis.text = element_text(size = 12))
      
      ggplotly(g)
    })
    
    output$giftQuarterPlot <- renderPlotly({
      g <- transaction_df() %>%
        group_by(Quarter) %>%
        summarise(Total = sum(GIFT_AMOUNT)) %>%
        select(Quarter, Total) %>%
        ggplot(aes(x = as.factor(Quarter) ,y = Total))  +
        geom_bar(stat = "identity",width = 0.5, fill='black') +
        scale_y_continuous(labels = scales::comma) + 
        labs(x ="Quarter", y = "Gift Amount") 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 12),
            axis.title = element_text(size = 14),
            axis.text = element_text(size = 12))
      
      ggplotly(g)
      
    })
    output$giftMonthPlot <- renderPlotly({
      g <- transaction_df() %>%
        group_by(Month) %>%
        summarise(Total = sum(GIFT_AMOUNT)) %>%
        select(Month, Total) %>%
        ggplot(aes(x = as.factor(Month) ,y = Total))  +
        geom_bar(stat = "identity",width = 0.5, fill='black') +
        scale_y_continuous(labels = scales::comma) + 
        labs(x ="Month", y = "Gift Amount") 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 12),
            axis.title = element_text(size = 14),
            axis.text = element_text(size = 12))
      
      ggplotly(g)
      
    })
    
    output$giftDOWPlot <- renderPlotly({
      g <- transaction_df() %>%
        group_by(DOW) %>%
        summarise(Total = sum(GIFT_AMOUNT)) %>%
        select(DOW, Total) %>%
        ggplot(aes(x = as.factor(DOW) ,y = Total))  +
        geom_bar(stat = "identity",width = 0.5, fill='black')  +
        scale_y_continuous(labels = scales::comma) + 
        labs(x ="Day of Week", y = "Gift Amount") 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 12),
            axis.title = element_text(size = 14),
            axis.text = element_text(size = 12))
      
      ggplotly(g)
      
    })

    
    output$giftchannelInsightPlot <- renderPlotly({
      
      g <- transaction_df() %>%
        group_by(GIFT_CHANNEL) %>%
        summarise(Total = sum(GIFT_AMOUNT)) %>%
        select(GIFT_CHANNEL, Total) %>%
        ggplot(aes(x = reorder(GIFT_CHANNEL,Total) ,y = Total))  +
        geom_bar(stat = "identity",width = 0.5, fill='black')  +
        scale_y_continuous(labels = scales::comma) +
        labs(x ="Gift Channel", y = "Gift Amount") + coord_flip() +
        theme(legend.text = element_text(size = 12),
              legend.title = element_text(size = 12),
              axis.title = element_text(size = 14),
              axis.text = element_text(size = 12))
      
      ggplotly(g)
      
    })
    output$giftpaymentTypePlot <- renderPlotly({
      g <- transaction_df() %>%
        group_by(PAYMENT_TYPE) %>%
        summarise(Total = sum(GIFT_AMOUNT)) %>%
        select(PAYMENT_TYPE, Total) %>%
        ggplot(aes(x = reorder(PAYMENT_TYPE,Total) ,y = Total))  +
        geom_bar(stat = "identity",width = 0.5, fill='black')  +
        scale_y_continuous(labels = scales::comma) +
        labs(x ="Gift Payment Type", y = "Gift Amount") + coord_flip() +
        theme(legend.text = element_text(size = 12),
              legend.title = element_text(size = 12),
              axis.title = element_text(size = 14),
              axis.text = element_text(size = 12))
      
      ggplotly(g)
    })
    output$giftTypePlot <- renderPlotly({
      g <- transaction_df() %>%
        group_by(GIFT_TYPE) %>%
        summarise(Total = sum(GIFT_AMOUNT)) %>%
        select(GIFT_TYPE, Total) %>%
        ggplot(aes(x = reorder(GIFT_TYPE,Total) ,y = Total))  +
        geom_bar(stat = "identity",width = 0.5, fill='black')  +
        scale_y_continuous(labels = scales::comma) +
        labs(x ="Gift Type", y = "Gift Amount") + coord_flip() +
        theme(legend.text = element_text(size = 12),
              legend.title = element_text(size = 12),
              axis.title = element_text(size = 14),
              axis.text = element_text(size = 12))
      
      ggplotly(g)
    })
    
   
    output$giftAmtPaymentTypePlot <- renderPlotly({
      g <- transaction_df() %>%
        group_by(GIFT_DATE,PAYMENT_TYPE) %>%
        summarise(Total = sum(GIFT_AMOUNT)) %>%
        select(GIFT_DATE,PAYMENT_TYPE, Total) %>%
        ggplot(aes(x = GIFT_DATE ,y = Total,col=PAYMENT_TYPE))  +
        geom_line(stat ="identity")  + 
        labs(x ="Date", y = "Gift Amount",col="Payment Type") + scale_y_continuous(labels = scales::comma) + 
        theme(legend.text = element_text(size = 12),
              legend.title = element_text(size = 12),
              axis.title = element_text(size = 14),
              axis.text = element_text(size = 12))
      
      ggplotly(g)
    })
    
    output$giftAmtGiftChannelPlot <- renderPlotly({
      g <- transaction_df() %>%
        group_by(GIFT_DATE,GIFT_CHANNEL) %>%
        summarise(Total = sum(GIFT_AMOUNT)) %>%
        select(GIFT_DATE,GIFT_CHANNEL, Total) %>%
        ggplot(aes(x = GIFT_DATE ,y = Total,col=GIFT_CHANNEL))  +
        geom_line(stat ="identity")  + 
        labs(x ="Date", y = "Gift Amount", col = "Gift Channel") + scale_y_continuous(labels = scales::comma) + 
        theme(legend.text = element_text(size = 12),
              legend.title = element_text(size = 12),
              axis.title = element_text(size = 14),
              axis.text = element_text(size = 12))
      
      ggplotly(g)
    })
 
    output$giftAmtGiftTypePlot <- renderPlotly({
      g <- transaction_df() %>%
        group_by(GIFT_DATE,GIFT_TYPE) %>%
        summarise(Total = sum(GIFT_AMOUNT)) %>%
        select(GIFT_DATE,GIFT_TYPE, Total) %>%
        ggplot(aes(x = GIFT_DATE ,y = Total,col=GIFT_TYPE))  +
        geom_line(stat ="identity")  + 
        labs(x ="Date", y = "Gift Amount", col = "Gift Type") + scale_y_continuous(labels = scales::comma) + 
        theme(legend.text = element_text(size = 12),
              legend.title = element_text(size = 12),
              axis.title = element_text(size = 14),
              axis.text = element_text(size = 12))
      
      ggplotly(g)      
    })
    
    output$giftFlowPlot <- renderPlotly({
      frequencies <- transaction_df() %>%
        count(APPEAL, GIFT_CHANNEL, PAYMENT_TYPE) %>%
        arrange(APPEAL, desc(n))
      
      # create a table of frequencies
      freq_table <- transaction_df() %>% group_by(APPEAL, GIFT_CHANNEL, PAYMENT_TYPE) %>%
        summarise(n = n())
      
      # create a nodes data frame
      nodes <- data.frame(name = unique(c(as.character(freq_table$APPEAL),
                                          as.character(freq_table$GIFT_CHANNEL),
                                          as.character(freq_table$PAYMENT_TYPE))))
      
      
      
      # create links dataframe
      links <- data.frame(source = match(freq_table$APPEAL, nodes$name) - 1,
                          target = match(freq_table$GIFT_CHANNEL, nodes$name) - 1,
                          value = freq_table$n,
                          stringsAsFactors = FALSE)
      
      links <- rbind(links,
                     data.frame(source = match(freq_table$GIFT_CHANNEL, nodes$name) - 1,
                                target = match(freq_table$PAYMENT_TYPE, nodes$name) - 1,
                                value = freq_table$n,
                                stringsAsFactors = FALSE))
      
      
      # Make Sankey diagram
      plot_ly(
        type = "sankey",
        orientation = "h",
        node = list(pad = 15,
                    thickness = 35,
                    line = list(color = "black", width = 0.3),
                    label = nodes$name),
        link = list(source = links$source,
                    target = links$target,
                    value = links$value),
        textfont = list(size = 10),
        width = 900,
        height = 600
      ) %>%
        layout(title = "Appeal --> GIFT Channel --> Payment Type",
               font = list(size = 14),
               margin = list(t = 40, l = 10, r = 10, b = 10))
    })
    
    
    
    #=============
    # RFM
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
    # Forecasting
    #==================
    
    # Forecast overview
    output$giftDailyPlot <- renderPlotly({
      gift_daily <- apply.daily(gift_xts,mean)
      
      g <- autoplot(gift_daily) +   
        scale_y_continuous(labels = scales::comma) + labs(x ="Gift Date", y = "Gift Amount",
                                                          title = "Daily Gift Chart") + 
        theme(plot.title = element_text(hjust=0.5))
      ggplotly(g)
    })
    output$giftWeeklyPlot <- renderPlotly({
      gift_weekly <- apply.weekly(gift_xts, mean) 
      g <- autoplot(gift_weekly) +   
        scale_y_continuous(labels = scales::comma) + labs(x ="Gift Date", y = "Gift Amount",
                                                          title = "Weekly Gift Chart") +
        theme(plot.title = element_text(hjust=0.5))
      ggplotly(g)
    })
    output$giftMonthlyPlot <- renderPlotly({
      gift_monthly <- apply.monthly(gift_xts, mean)
      g <- autoplot(gift_monthly) +   
        scale_y_continuous(labels = scales::comma) + labs(x ="Gift Date", y = "Gift Amount",
                                                          title = "Monthly Gift Chart") + 
        theme(plot.title = element_text(hjust=0.5))
      ggplotly(g)
    })
    
    # Forecast analysis
    output$decompositionPlot <- renderPlotly({
      p <- forecast_analysis_df() %>%
        decompose() %>%
        autoplot() + scale_y_continuous(labels = scales::comma) + 
        theme(plot.title = element_text(hjust=0.5))
      ggplotly(p)
    })
    output$multidecompositionPlot <- renderPlotly({
      p <- forecast_analysis_df() %>%
        mstl() %>%
        autoplot()  + scale_y_continuous(labels = scales::comma)
      ggplotly(p)
    })
    
    output$acfPlot <- renderPlotly({
      
      if (input$logInput == "No"){
        ggAcf(forecast_analysis_df()) + labs(title=forecast_info) + 
          theme(plot.title = element_text(hjust=0.5))
      } else {
        ggAcf(log(forecast_analysis_df())) + labs(title=forecast_info) + 
          theme(plot.title = element_text(hjust=0.5))
      }
      
    })
    output$pacfPlot <- renderPlot({
      if (input$logInput == "No"){
        ggPacf(forecast_analysis_df()) + labs(title=forecast_info) + 
          theme(plot.title = element_text(hjust=0.5))
      } else {
        ggPacf(log(forecast_analysis_df())) + labs(title=forecast_info) + 
          theme(plot.title = element_text(hjust=0.5))
      }
    })
    
    
    # Forecast visualization
    output$forecastPlot <- renderPlot({
      
      # set forecast horizon
      forecast.horizon <- as.numeric(input$horizonInput)
      train <- forecast_df(gift_xts,input$aggregateInput,input$frequencyInput,"train")
      
      # models
      auto_exp_model <- train %>% ets %>% forecast(h=forecast.horizon)
      auto_arima_model <- train %>% auto.arima() %>% forecast(h=forecast.horizon)
      simple_exp_model <- train %>% HoltWinters(beta=FALSE, gamma=FALSE) %>% 
        forecast(h=forecast.horizon)
      double_exp_model <- train %>% HoltWinters(beta = TRUE, gamma=FALSE) %>% 
        forecast(h=forecast.horizon)
      triple_exp_model <- train %>% HoltWinters(beta = TRUE, gamma = TRUE) %>% 
        forecast(h=forecast.horizon)
      tbat_model <- train %>% tbats %>% forecast(h=forecast.horizon)
      
      autoplot(train) +
        autolayer(auto_arima_model,series="auto arima", alpha=0.2) +
        autolayer(auto_exp_model, series = "auto exponential", alpha=0.2) +
        autolayer(simple_exp_model, series= "simple exponential", alpha=0.5) +
        autolayer(double_exp_model, series = "double exponential", alpha=0.25) +
        autolayer(triple_exp_model, series = "triple exponential", alpha=0.25) +
        autolayer(tbat_model, series = "tbat", alpha=0.7) + 
        guides(colour = guide_legend("Models")) + scale_y_continuous(labels = scales::comma) + 
        labs(x ="Gift Date", y = "Gift Amount", title = "Gift Amt. Forecast") + 
        theme(plot.title = element_text(hjust=0.5))
      
      
    })
    
    # Forecast results
    output$forecastOutput <- DT::renderDataTable({
      
      forecast.horizon <- as.numeric(input$horizonInput)
      
      train <- forecast_df(gift_xts,input$aggregateInput,input$frequencyInput,"train")
      test <- forecast_df(gift_xts,input$aggregateInput,input$frequencyInput,"test")
      
      # models
      gift_train_auto_exp_forecast <- ets(train) %>% 
        forecast(h=forecast.horizon)    
      
      gift_train_auto_arima_forecast <- auto.arima(train) %>% 
        forecast(h=forecast.horizon)             
      
      gift_train_simple_exp_forecast <- HoltWinters(train,
                                                    beta=FALSE, 
                                                    gamma=FALSE) %>% 
        forecast(h=forecast.horizon)             
      
      gift_train_double_exp_forecast <- HoltWinters(train,
                                                    beta=TRUE, 
                                                    gamma=FALSE) %>% 
        forecast(h=forecast.horizon)  
      
      gift_train_triple_exp_forecast <- HoltWinters(train,
                                                    beta=TRUE, 
                                                    gamma=TRUE) %>% 
        forecast(h=forecast.horizon)  
      
      gift_train_tbat_forecast <-  tbats(train) %>% forecast(h=forecast.horizon)
      
      
      
      # forecast output
      auto_exp_forecast <- as.data.frame(gift_train_auto_exp_forecast$mean)
      auto_arima_forecast <- as.data.frame(gift_train_auto_arima_forecast$mean)
      simple_exp_forecast <- as.data.frame(gift_train_simple_exp_forecast$mean)
      double_exp_forecast <- as.data.frame(gift_train_double_exp_forecast$mean)
      triple_exp_forecast <- as.data.frame(gift_train_triple_exp_forecast$mean)
      tbat_forecast <- as.data.frame(gift_train_tbat_forecast$mean)
      
      auto_exp_forecast <- numeric_update(auto_exp_forecast)
      auto_arima_forecast <- numeric_update(auto_arima_forecast)
      simple_exp_forecast <- numeric_update(simple_exp_forecast)
      double_exp_forecast <- numeric_update(double_exp_forecast)
      triple_exp_forecast <- numeric_update(triple_exp_forecast)
      tbat_forecast <- numeric_update(tbat_forecast)
      
      models <- c("auto-exponential","auto-arima","simple-exponential","double-exponential",
                  "triple-exponential","tbat")
      
      outputInfo <- cbind(auto_exp_forecast,auto_arima_forecast,
                          simple_exp_forecast,double_exp_forecast,
                          triple_exp_forecast,tbat_forecast)
      
      colnames(outputInfo) <- models 
      
      
      DT::datatable(outputInfo, options = list(scrollX = TRUE))
      
    })
    
    # Forecast accuracy
    output$accuracyOutput <- DT::renderDataTable({
      forecast.horizon <- as.numeric(input$horizonInput)
      
      train <- forecast_df(gift_xts,input$aggregateInput,input$frequencyInput,"train")
      test <- forecast_df(gift_xts,input$aggregateInput,input$frequencyInput,"test")
      # models
      gift_train_auto_exp_forecast <- ets(train) %>% 
        forecast(h=forecast.horizon)    
      
      gift_train_auto_arima_forecast <- auto.arima(train) %>% 
        forecast(h=forecast.horizon)             
      
      gift_train_simple_exp_forecast <- HoltWinters(train,
                                                    beta=FALSE, 
                                                    gamma=FALSE) %>% 
        forecast(h=forecast.horizon)             
      
      gift_train_double_exp_forecast <- HoltWinters(train,
                                                    beta=TRUE, 
                                                    gamma=FALSE) %>% 
        forecast(h=forecast.horizon)  
      
      gift_train_triple_exp_forecast <- HoltWinters(train,
                                                    beta=TRUE, 
                                                    gamma=TRUE) %>% 
        forecast(h=forecast.horizon)  
      
      gift_train_tbat_forecast <-  tbats(train) %>% forecast(h=forecast.horizon)
      
      auto_exp_accuracy <- as.data.frame(accuracy( gift_train_auto_exp_forecast ,test))
      auto_arima_accuracy <- as.data.frame(accuracy(gift_train_auto_arima_forecast ,test))
      simple_exp_accuracy <- as.data.frame(accuracy(gift_train_simple_exp_forecast ,test))
      double_exp_accuracy <- as.data.frame(accuracy(gift_train_double_exp_forecast ,test))
      triple_exp_accuracy <- as.data.frame(accuracy(gift_train_triple_exp_forecast ,test))
      tbat_accuracy <- as.data.frame(accuracy(gift_train_tbat_forecast ,test))
      
      auto_exp_accuracy <- numeric_update(auto_exp_accuracy)
      auto_arima_accuracy <- numeric_update(auto_arima_accuracy)
      simple_exp_accuracy <- numeric_update(simple_exp_accuracy)
      double_exp_accuracy <- numeric_update(double_exp_accuracy)
      triple_exp_accuracy <- numeric_update(triple_exp_accuracy)
      tbat_accuracy <- numeric_update(tbat_accuracy)
      
      models<- c("auto-exponential","auto-exponential",
                 "auto-arima","auto-arima",
                 "simple-exponential","simple-exponential",
                 "double-exponential","double-exponential",
                 "triple-exponential","triple-exponential",
                 "tbat","tbat")
      
      data<- c("Training set", 'Test set',
               "Training set", 'Test set',
               "Training set", 'Test set',
               "Training set", 'Test set',
               "Training set", 'Test set',
               "Training set", 'Test set')
      
      outputInfo <- rbind(auto_exp_accuracy,auto_arima_accuracy,
                          simple_exp_accuracy,double_exp_accuracy,
                          triple_exp_accuracy,tbat_accuracy)           
      

      outputInfo <- cbind(models, data, outputInfo)
      
      DT::datatable(outputInfo, options = list(scrollX = TRUE))
    })
    
    # Forecast Prediction
    output$predictionOutput <- DT::renderDataTable({})
    
  }             
  
  shinyApp(ui, server)
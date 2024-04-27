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

#=============
# Forecast info
#=============
# generating range of dates 
date_range <- data.frame(seq(start_date, end_date,"days")) 
gift_data <- data.frame(data=c(1:nrow(date_range)))
colnames(date_range) <- "GIFT_DATE"
date_range <- cbind(date_range,gift_data)

# transaction
transaction <- as.tibble(transaction)
date_range <- as.tibble(date_range)
transaction_f1 <- transaction %>%
  filter(GIFT_DATE >= '2010-01-01',GIFT_DATE <= today()) %>%
  group_by(GIFT_DATE) %>%
  summarise(Total = sum(GIFT_AMOUNT)) %>%
  select(GIFT_DATE,Total)

transaction_f <- transaction_f1 %>%
right_join(date_range,by='GIFT_DATE', copy = TRUE) %>%
replace(is.na(.), 0) %>%
select(GIFT_DATE,Total)

gift_xts <- xts(x = transaction_f$Total, order.by = transaction_f$GIFT_DATE) 

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
      menuSubItem("Gift Forecasting", tabName = "gift_forecasting")
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
                h4("Daily Gift plot",style="text-align: center;"),
                plotlyOutput("giftDailyPlot"),
                h4("Weekly Gift plot",style="text-align: center;"),
                plotlyOutput("giftWeeklyPlot"),
                h4("Monthly Gift plot",style="text-align: center;"),
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
    
# 
#     date_range <- reactive({
#       seq(as.Date("2010-01-01"), as.Date(today()) ,"days") 
#     })
#     
#     gift_xts <-  reactive({
#       transaction_f <- transaction %>%
#         filter(GIFT_DATE >= '2010-01-01',GIFT_DATE <= today()) %>%
#         group_by(GIFT_DATE) %>%
#         summarise(Total = sum(GIFT_AMOUNT)) %>%
#         right_join(transaction,date_range(),by='GIFT_DATE',copy = FALSE) %>%
#         replace(is.na(.), 0) %>%
#         select(GIFT_DATE,Total)
#         glimpse(transaction_f)
#       xts(x = transaction_f$Total, order.by = transaction_f$GIFT_DATE) 
#     })
      
  
    
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
    # Interaction plots
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
    # Gift Plots
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
      
      g <- autoplot(gift_daily, main = "Daily Gift amount from 2010 onwards") +   
        scale_y_continuous(labels = scales::comma) + labs(x ="Gift Date", y = "Gift Amount")
      ggplotly(g)
    })
    output$giftWeeklyPlot <- renderPlotly({
      gift_weekly <- apply.weekly(gift_xts, mean) 
      g <- autoplot(gift_weekly, main = "Weekly Gift amount from 2010 onwards") +   
        scale_y_continuous(labels = scales::comma) + labs(x ="Gift Date", y = "Gift Amount")
      ggplotly(g)
    })
    output$giftMonthlyPlot <- renderPlotly({
      gift_monthly <- apply.monthly(gift_xts, mean)
      g <- autoplot(gift_monthly, main = "Monthly Gift amount from 2010 onwards") +   
        scale_y_continuous(labels = scales::comma) + labs(x ="Gift Date", y = "Gift Amount")
      ggplotly(g)
    })
    
    # Forecast analysis
    output$decompositionPlot <- renderPlotly({})
    output$multidecompositionPlot <- renderPlotly({})
    output$acfPlot <- renderPlotly({})
    output$pacfPlot <- renderPlotly({})
    
    
    # Forecast prediction
    
  }             
  
  shinyApp(ui, server)
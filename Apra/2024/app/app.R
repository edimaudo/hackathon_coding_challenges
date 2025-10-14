#========================================
# Shiny web app which provides insights 
# for the 2024 Apra Challenge
#=========================================
rm(list = ls())
################ Packages ################
# library(ggplot2)
# library(corrplot)
# library(tidyverse)
# library(shiny)
# library(shinydashboard)
# library(mlbench)
# library(caTools)
# library(gridExtra)
# library(doParallel)
# library(grid)
# library(reshape2)
# library(caret)
# library(tidyr)
# library(Matrix)
# library(lubridate)
# library(plotly)
# library(RColorBrewer)
# library(data.table)
# library(scales)
# library(rfm)
# library(forecast)
# library(TTR)
# library(xts)
# library(dplyr)
# library(treemapify)
# library(shinycssloaders)
# library(bslib)
# library(readxl)
# library(ggalluvial)
# library(ggforce)
packages <- c(
  'ggplot2', 'corrplot','tidyverse','shiny','shinydashboard','DT','readxl',
  'mlbench','caTools','gridExtra','doParallel','grid','forecast','reshape2',
  'caret','tidyr','Matrix','lubridate','plotly','RColorBrewer','bslib','shinycssloaders',
  'data.table','scales','rfm','forecast','TTR','xts','dplyr'
)
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}
#============= Load Data =============
#constituent <- read_csv("Apra Constituent Data.csv")
transaction <- read_csv("Apra Gift Transactions Data.csv")
interaction <- read_csv("Apra Interactions Data.csv")


#============= Data munging =============
campaign <- sort(unique(na.omit(transaction$CAMPAIGN)))
appeal <- sort(unique(na.omit(transaction$APPEAL)))
primary_unit <- sort(unique(na.omit(transaction$PRIMARY_UNIT)))
payment_type <- sort(unique(na.omit(transaction$PAYMENT_TYPE)))
gift_type <- sort(unique(na.omit(transaction$GIFT_TYPE)))
gift_designation <- sort(unique(na.omit(transaction$GIFT_DESIGNATION)))
gift_channel <- sort(unique(na.omit(transaction$GIFT_CHANNEL)))
note_info <- "Using only data from 2010 onwards"

################ UI ################
ui <- dashboardPage(
  dashboardHeader(title = "Apra Data Science Challenge",
                  tags$li(a(href = 'https://www.aprahome.org',
                            img(src = 'https://www.aprahome.org/Portals/_default/skins/siteskin/images/logo.png',
                                title = "Home", height = "30px"),
                            style = "padding-top:10px; padding-bottom:10px;"),
                          class = "dropdown")),
  dashboardSidebar(
    sidebarMenu(
      menuItem("About", tabName = "about", icon = icon("home")),
      menuItem(" Donor Overview", tabName = "overview", icon = icon("thumbs-up")),
      menuItem("Donor Portfolio", tabName = "segment", icon = icon("th")),
      menuSubItem("Donation Forecasting", tabName = "forecast",icon = icon("credit-card"))
    )
  ),
  dashboardBody(
    tabItems(
      #======== About ======== 
      tabItem(tabName = "about",includeMarkdown("about.md"),hr()), 
      #========  Donor Portfolio ========
      tabItem(tabName = "segment",
              sidebarLayout(
                sidebarPanel(width = 3,
                             selectInput("rfmInput", "Donor Portfolios", 
                                         choices = segment_titles, selected = segment_titles, 
                                         multiple = TRUE),
                             submitButton("Submit")
                ),
                mainPanel(width = 9,
                          fluidRow(
                            column(width = 12,
                                   valueBoxOutput("valueRecency"),
                                   valueBoxOutput("valueFrequency"),
                                   valueBoxOutput("valueMonetary"),
                            )
                          ),
                          br(),br(),
                          tabsetPanel(type = "tabs",
                                      tabPanel(h4("Donor Portfolio Mix",style="text-align: center;"),
                                               plotOutput('rfmTreemap') %>% withSpinner() , #plotOutput
                                      ),
                                      tabPanel(h4("Donor Portfolio Description",style="text-align: center;"), 
                                               DT::dataTableOutput("rfmDescription"),
                                      ),
                                      tabPanel(h4("Recency",style="text-align: center;"),
                                               plotlyOutput("rfmRecencyChart") %>% withSpinner() ,
                                      ),
                                      tabPanel(h4("Frequency",style="text-align: center;"),
                                               plotlyOutput("rfmFrequencyChart") %>% withSpinner() ,
                                      ),
                                      tabPanel(h4("Monetary",style="text-align: center;"),
                                               plotlyOutput("rfmMonetaryChart") %>% withSpinner() 
                                      ),
                                      tabPanel(h4("Donor Constituent Portfolio",style="text-align: center;"), 
                                               DT::dataTableOutput("rfmTable") %>% withSpinner() ,
                                      )
                          ),
                          br(),br(),
                          tabsetPanel(type = "tabs",
                                      tabPanel(h4("Donor Relationship",style="text-align: center;"),
                                               #plotlyOutput("rfmRecencyChart"),
                                      ),
                                      tabPanel(h4("Engagement",style="text-align: center;"),
                                               #plotOutput('rfmTreemap'),
                                      ),
                                      tabPanel(h4("Giving Level",style="text-align: center;"),
                                               #plotlyOutput("rfmRecencyChart"),
                                      ),
                                      tabPanel(h4("Online Performance",style="text-align: center;"),
                                               #plotlyOutput("rfmRecencyChart"),
                                      )
                                      
                                      
                          )  
                )
              )
      ),
      
#=========Overview =========
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
                                       DT::dataTableOutput("forecastOutput"))
                  )
                )
              )
              
      )
    )
  )  
)
################ Server ################
server <- function(input, output,session) {
  
#============= Data Setup ============= 
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
  
  
  
  
  
  
  #============= Donation Overview =============
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
  
  
  #============= Interaction =============
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

#============= Gift Insights =============
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
  
  
  
#============= RFM =============

    
  
#================== Forecasting ==================
  
# Forecast overview

    
  
  
  
}             

shinyApp(ui, server)
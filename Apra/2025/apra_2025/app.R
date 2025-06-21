#========================================
# Shiny web app which provides insights 
# for Apra data science challenge
#=========================================
rm(list = ls())
################
# Packages 
################
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
# library(shinycssloader)

packages <- c(
  'ggplot2', 'corrplot','tidyverse','shiny','shinydashboard','shinycssloaders','DT',
  'mlbench','caTools','gridExtra','doParallel','grid','reshape2',
  'caret','tidyr','Matrix','lubridate','plotly','RColorBrewer',
  'data.table','scales','rfm','forecast','TTR','xts','dplyr', 'treemapify'
)
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}
################
# Load Data
################
crm <- read_csv("CRM_interacions_table.csv")
gift <- read_csv("gift_transactions_table.csv")
video <- read_csv("video_email_data_table.csv")
constituent <- read_csv("constituent_profiles_table.csv")

# Data Information
segment_titles <- c("Champions", "Loyal Customers", "Potential Loyalist",
                    "Recent Ones", "Could be Promising", "Requires Assistance", "Getting Less Frequent",
                    "At Risk", "Can't Lose Them", "Lost")
month_titles <- c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec')

#Label Encoder
labelEncoder <-function(x){
  as.numeric(factor(x))-1
}
#normalize data
normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}

################
# UI
################
ui <- dashboardPage(
  dashboardHeader(title = "Apra Challenge 2025",
                  tags$li(a(href = 'https://www.aprahome.org',
                            img(src = 'https://www.aprahome.org/Portals/_default/skins/siteskin/images/logo.png',
                                title = "Home", height = "30px"),
                            style = "padding-top:10px; padding-bottom:10px;"),
                          class = "dropdown")),
  dashboardSidebar(
    sidebarMenu(
      menuItem("About", tabName = "about", icon = icon("house")),
      menuItem("Weekly Donation Insights", tabName = "weekly", icon = icon("th")),
      menuItem("Monthly Donation Insights", tabName = "monthly",icon = icon("th")),
      menuItem("Yearly Donation Insights", tabName = "yearly",icon = icon("th")),
      menuItem("Donation Overiew", tabName = "donations_overview", icon = icon("th")),
      menuSubItem("Donor Portfolio", tabName = "segment", icon = icon("pencil")),
      menuSubItem("Gift Forecasting ", tabName = "donation_forecast",icon = icon("pencil")),
      menuSubItem("Next Best Gift", tabName = "donation_prediction",icon = icon("pencil"))
    )
  ),
  dashboardBody(
    tabItems(
      ######### About #########
      tabItem(tabName = "about",includeMarkdown("about.md"),hr()), 
      
      ######### Overview ######### 
      
      ######### Donor Overview ######### 
      tabItem(tabName = "donations_overview",
              sidebarLayout(
                sidebarPanel(width = 3,
                             sliderInput("yearDonationInput","Year", min = 2015, max = 2025, value = c(2015,2025), step = 1),
                             selectInput("monthDonationInput", "Month", 
                                         choices = month_titles, selected = month_titles, multiple = TRUE),
                             submitButton("Submit")
                ),
                mainPanel(width = 9,
                          fluidRow(
                                   plotlyOutput("giftCRMPlot"),
                                   plotlyOutput("giftYearPlot"),
                                   plotlyOutput("giftMonthPlot"),
                                   plotlyOutput("giftDOWPlot"),
                          )
                )
              )
                
      ),
      ######### Donor Portfolio ######### 
      tabItem(tabName = "segment",
              sidebarLayout(
                sidebarPanel(width = 2,
                             selectInput("rfmInput", "Donor Portfolios", 
                                         choices = segment_titles, selected = segment_titles, multiple = TRUE),
                             submitButton("Submit")
                ),
                mainPanel(width = 10,
                  fluidRow(
                    column(width = 12,
                           valueBoxOutput("valueRecency"),
                           valueBoxOutput("valueFrequency"),
                           valueBoxOutput("valueMonetary"),
                    )
                  ),
                  br(),br(),
                  fluidRow(
                    column(width = 12,
                           plotlyOutput("rfmRecencyChart"),
                           plotlyOutput("rfmFrequencyChart"),
                           plotlyOutput("rfmMonetaryChart"),
                    )
                  ),
                  br(),br(),
                  fluidRow(
                    h4("Donor Portfolio Table",style="text-align: center;"),
                    DT::dataTableOutput("rfmTable")
                  )
                )
              )
      ),
      ######### Donor Forecasting #########
      tabItem(tabName = "donation_forecast",
              sidebarLayout(
                sidebarPanel(width = 3,
                             selectInput("forecastSegmentInput", "Portfolios", 
                                         choices = segment_titles, selected = segment_titles[1], multiple = TRUE),
                             sliderInput("forecastHorizonInput", "Forecast Period (in months)", 
                                         min = 1, max = 24, value = 12), 
                             submitButton("Submit")
                ),
                mainPanel(
                    plotlyOutput("donationForecastPlot") %>% withSpinner()
                  )
                )
      ),
      ######### Donor Prediction ######### 
      tabItem(tabName = "donation_prediction",
              sidebarLayout(
                sidebarPanel(width = 3,
                             selectInput("predictionSegmentInput", "Portfolios", 
                                         choices = segment_titles, selected = segment_titles[0]),
                             sliderInput("predictionCRMInput", "# of CRM Interactions", 
                                         min = 0, max = 100, value = 1), 
                             sliderInput("predictionCRMInteractionInput", "Unique CRM Interactions", 
                                         min = 0, max = 5, value = 1), 
                             sliderInput("predictionGiftInput", "# of Gifts", 
                                         min = 0, max = 50, value = 1), 
                             sliderInput("predictionDayInput", "# of Days Since last gift", 
                                         min = 0, max = 3000, value = 100), 
                             submitButton("Submit")
                ),
                mainPanel(
                  fluidRow(),
                  
                    #plotlyOutput("rfmRecencyChart"),
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
  
  ##### =====Gift Overview==== #####
  
  gift_df <- reactive({
    df <- gift %>%
      mutate(Year =  as.integer(as.numeric(lubridate::year(GIFT_DATE))),
             Month = lubridate::month(GIFT_DATE, label = TRUE),
             DOW = lubridate::wday(GIFT_DATE, label=TRUE)) %>%
      filter((Year >= input$yearDonationInput[1] & Year <= input$yearDonationInput[2]), 
             Month %in% input$monthDonationInput)
    df
    
  })
  
  output$giftCRMPlot <- renderPlotly({
    gift_df() %>%
      left_join(crm,by='CONSTITUENT_ID') %>%
      group_by(CRM_INTERACTION_TYPE) %>%
      summarise(Total = mean(AMOUNT)) %>%
      select(CRM_INTERACTION_TYPE,Total) %>%
      na.omit() %>%
      ggplot(aes(x = reorder(CRM_INTERACTION_TYPE,Total) ,y = Total))  +
      geom_bar(stat = "identity",width = 0.5, fill='black')  +
      scale_y_continuous(labels = scales::comma) +
      labs(x ="CRM Interaction Type", y = "Avg. Gift Amount", title="CRM Interaction & Avg. Gift Amount") + coord_flip() +
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            plot.title = element_text(size = 12, hjust = 0.5),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10))
  })
  
  gift_df <- reactive({
    df <- gift %>%
      mutate(Year =  as.integer(as.numeric(lubridate::year(GIFT_DATE))),
             Month = lubridate::month(GIFT_DATE, label = TRUE),
             DOW = lubridate::wday(GIFT_DATE, label=TRUE)) %>%
      filter((Year >= input$yearDonationInput[1] & Year <= input$yearDonationInput[2]), 
              Month %in% input$monthDonationInput)
    df
      
  })

  
  output$giftYearPlot <- renderPlotly({
    g <- gift_df() %>%
    group_by(Year) %>%
      summarise(Total = mean(AMOUNT)) %>%
      select(Year, Total) %>% 
      na.omit() %>%
      ggplot(aes(Year, Total)) + 
      geom_bar(stat = "identity",width = 0.5, fill='black')  +
      labs(x = "Year", y = "Avg. Gift Amount", title="Avg. Gift Amount by Year") + 
      scale_y_continuous(labels = comma) +
      scale_x_continuous(labels = scales::number_format(accuracy = 1, big.mark = "")) + 
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            plot.title = element_text(size = 12, hjust = 0.5),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10),
            axis.text.x = element_text(angle = 0, hjust = 1))
    ggplotly(g)
    
  })
  
  output$giftMonthPlot <- renderPlotly({
    g <- gift_df() %>%
      group_by(Month) %>%
      summarise(Total = mean(AMOUNT)) %>%
      select(Month, Total) %>% 
      na.omit() %>%
      ggplot(aes(Month, Total)) + 
      geom_bar(stat = "identity",width = 0.5, fill='black') + 
      labs(x = "Month", y = "Avg. Gift Amount", title="Avg. Gift Amount by Month") + 
      scale_y_continuous(labels = comma) +
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            plot.title = element_text(size = 12, hjust = 0.5),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10),
            axis.text.x = element_text(angle = 0, hjust = 1))
    ggplotly(g)
    
  })
  
  output$giftDOWPlot <- renderPlotly({
    g <- gift_df() %>%
      group_by(DOW) %>%
      summarise(Total = mean(AMOUNT)) %>%
      select(DOW, Total) %>% 
      na.omit() %>%
      ggplot(aes(DOW, Total)) + 
      geom_bar(stat = "identity",width = 0.5, fill='black') + 
      labs(x = "Day Of Week", y = "Avg. Gift Amount", title="Avg. Gift Amount by Day of Week") + 
      scale_y_continuous(labels = comma) +
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            plot.title = element_text(size = 12, hjust = 0.5),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10),
            axis.text.x = element_text(angle = 0, hjust = 1))
    ggplotly(g)
    
  })
  
  ##### =====Donor Portfolio==== #####
  
  
  ##### RFM Calculation #####
  rfm_info  <- reactive({
    rfm_df <- gift %>%
      filter(GIFT_DATE >= '2015-01-01') %>%
      select(CONSTITUENT_ID,GIFT_DATE,AMOUNT) %>%
      na.omit()
    
    names(rfm_df)[names(rfm_df) == 'CONSTITUENT_ID'] <- 'customer_id' ## due to rfm library
    analysis_date <- lubridate::as_date(today(), tz = "UTC")
    report <- rfm_table_order(rfm_df, customer_id,GIFT_DATE,AMOUNT, analysis_date)
    
    # numerical thresholds
    r_low <- c(4, 2, 3, 4, 3, 2, 2, 1, 1, 1)
    r_high <- c(5, 5, 5, 5, 4, 3, 3, 2, 1, 2)
    f_low <- c(4, 3, 1, 1, 1, 2, 1, 2, 4, 1)
    f_high <- c(5, 5, 3, 1, 1, 3, 2, 5, 5, 2)
    m_low <- c(4, 3, 1, 1, 1, 2, 1, 2, 4, 1)
    m_high  <- c(5, 5, 3, 1, 1, 3, 2, 5, 5, 2)
    
    divisions<-rfm_segment(report, segment_titles, r_low, r_high, f_low, f_high, m_low, m_high)
    
  })
  
  ###### RFM Metrics ######
  value_box_calculations <- reactive({
    rfm_info() %>%
      filter(segment %in% input$rfmInput) %>%
      summarize(average_recency = mean(recency_days),
                average_frequency = mean(transaction_count),
                average_monetary = mean(amount)
      ) %>%
      select(average_recency,average_frequency,average_monetary)
  })
  
  
  output$valueRecency <- renderValueBox({
  
    valueBox(
      value = tags$p("Avg. # of Days since last gift", style = "font-size: 24px;"),
      subtitle = tags$p((sprintf(value_box_calculations()$average_recency, fmt = '%.0f')), style = "font-size: 100%;"),
      #icon = icon("calendar"),
      color = "black"
    )
    
  })
  
  output$valueFrequency <- renderValueBox({
    valueBox(
      value = tags$p("Avg. # of Gifts", style = "font-size: 24px;"),
      subtitle = tags$p((sprintf(value_box_calculations()$average_frequency, fmt = '%.0f')), style = "font-size: 100%;"),
      #icon = icon("thumbs-up"),
      color = "black"
      )
  })
  
  output$valueMonetary <- renderValueBox({
    valueBox(
      value = tags$p("Avg. Gift Amount", style = "font-size: 24px;"),
      subtitle = tags$p((sprintf(value_box_calculations()$average_monetary, fmt = '%.0f')), style = "font-size: 100%;"),
      #icon = icon("credit-card"),
      color = "black"
    )
    
  
  })
  
  ##### RFM Charts ####
  output$rfmTreemap <- renderPlot({
    division_count <- rfm_info() %>% 
      filter(segment %in% input$rfmInput) %>%
      count(segment) %>% 
      arrange(desc(n)) %>% rename(Segment = segment, Count = n)
    `Portfolios` <- c(unique(division_count$Segment))
    ggplot(division_count, aes(area = Count, fill = `Portfolios`, label = `Segment`) ) +
      geom_treemap(stat = "identity",
                   position = "identity") +
      geom_treemap_text(place = "centre",size = 12)
    
  })
  
  rfm_chart <- reactive({
    rfm_info() %>%
      filter(segment %in% input$rfmInput) %>%
      group_by(segment) %>%
      summarise(Recency_avg = mean(recency_days),
                Frequency_avg =mean(transaction_count),
                Monetary_avg = mean(amount)
                ) %>%
      select(segment,Recency_avg,Frequency_avg,Monetary_avg)
    
  })

  
  output$rfmRecencyChart <- renderPlotly({

    g <- ggplot(rfm_chart(), aes(x = reorder(segment,desc(Recency_avg)) ,y = Recency_avg))  +
      geom_bar(stat = "identity",width = 0.5, fill='black')  +
      scale_y_continuous(labels = scales::comma) +
      labs(x ="Segment", y = "Days", title="Average # of Days since last gift") + coord_flip() +
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            plot.title = element_text(size = 12, hjust = 0.5),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10))
    ggplotly(g)
    
  })
  
  
  output$rfmFrequencyChart <- renderPlotly({
    
    g <- ggplot(rfm_chart(), aes(x = reorder(segment,Frequency_avg) ,y = Frequency_avg))  +
      geom_bar(stat = "identity",width = 0.5, fill='black')  +
      scale_y_continuous(labels = scales::comma) +
      labs(x ="Segment", y = "Gifts", title = "Average # of Gifts") + coord_flip() +
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            plot.title = element_text(size = 12, hjust = 0.5),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10))
    ggplotly(g)
    
  })  
  
  output$rfmMonetaryChart <- renderPlotly({
    
    g <- ggplot(rfm_chart(), aes(x = reorder(segment,Monetary_avg) ,y = Monetary_avg))  +
      geom_bar(stat = "identity",width = 0.5, fill='black')  +
      scale_y_continuous(labels = scales::comma) +
      labs(x ="Segment", y = "Amount", title = "Average Donation Amount") + coord_flip() +
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            plot.title = element_text(size = 12, hjust = 0.5),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10))
    ggplotly(g)
    
    
  })
    
  ##### RFM Table ######
  rfm_output <- reactive({
      df <- rfm_info() %>%
        filter(segment %in% input$rfmInput) %>%
        select(customer_id,segment,rfm_score,transaction_count,recency_days,amount)
        colnames(df) <- c('CONSTITUENT_ID', 'Segment','RFM Score','# of Gifts','# of days since last gift', 'Gift Amount')
        df
  })
   
  output$rfmTable <- renderDataTable({
    rfm_output()
  })    
  
  ##### =====Donation Forecasting ==== #####
  ##### Donation Forecast setup ######
  gifts_df <- reactive ({
    gift %>%
      filter(GIFT_DATE >= '2015-01-01') %>%
      inner_join(rfm_output(),'CONSTITUENT_ID') %>%
      group_by(CONSTITUENT_ID) %>%
      select(CONSTITUENT_ID,Segment,GIFT_DATE,AMOUNT) %>%
      na.omit()
  })
  
  monthly_donations <- reactive({
    gifts_df() %>%
      filter(Segment %in% c(input$forecastSegmentInput)) %>%
      mutate(GIFT_DATE = ymd(GIFT_DATE)) %>%
      # Extract year and month for grouping
      mutate(year_month = floor_date(GIFT_DATE, "month")) %>%
      group_by(year_month) %>%
      summarise(total_donations = sum(AMOUNT, na.rm = TRUE), .groups = 'drop') %>%
      arrange(year_month)
  })
   
   start_year <- reactive({lubridate::year(min(monthly_donations()$year_month))})
   start_month <- reactive({lubridate::month(min(monthly_donations()$year_month))})
   
   donations_ts <- reactive({
     ts(monthly_donations()$total_donations,
        start = c(start_year(), start_month()),
        frequency = 12)
   }) 
   
  arima_model <- reactive({auto.arima(donations_ts())})

  forecast_arima <- reactive({
    forecast(arima_model(), h = input$forecastHorizonInput)
  })
   
   # Extracting forecast values
   forecast_df <- reactive({
     as_data_frame(forecast_arima()) %>%
       rename(
         `Forecasted Donation` = `Point Forecast`
       ) %>%
       mutate(
         Month = seq(from = max(monthly_donations()$year_month) + months(1),
                     by = "month",
                     length.out = input$forecastHorizonInput)
       ) %>%
       select(Month, `Forecasted Donation`)
   })
  

    

  
  output$donationForecastPlot <- renderPlotly({
    
      #input$go
      Sys.sleep(1.5)
      #plot(runif(10))
    
    
    g <- forecast_df() %>%
      select(Month, `Forecasted Donation`) %>%
      ggplot(aes(x = Month ,y = `Forecasted Donation`))  +
      geom_bar(stat = "identity",width = 8, fill='black')  +
      labs(x ="Date", y = "Gift Amount", title = "Forecasted Donations") + scale_y_continuous(labels = scales::comma) +
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            plot.title = element_text(size = 12, hjust = 0.5),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10))
    
     ggplotly(g)
  })
    

  
  
  output$donationForecastTable <- renderDataTable({
    #forecast_df()$`Forecasted Donation` <- format(round(forecast_df()$`Forecasted Donation`, 2), nsmall = 2)
    #forecast_df()
    
  })
    
  #===== Next Best Donation =====#
    
    
  

}

shinyApp(ui, server)
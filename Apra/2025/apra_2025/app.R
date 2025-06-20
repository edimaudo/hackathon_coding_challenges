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
# library(bslib)

packages <- c(
  'ggplot2', 'corrplot','tidyverse','shiny','shinydashboard','bslib','DT',
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
segment_titles <- c("First Grade", "Loyal", "Likely to be Loyal",
                    "New Ones", "Could be Promising", "Require Assistance", "Getting Less Frequent",
                    "Almost Out", "Can't Lose Them", "Don’t Show Up at All")

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
      menuItem("About", tabName = "about", icon = icon("th")),
      menuItem("Overview", tabName = "overview", icon = icon("list")),
      menuSubItem("Weekly Insights", tabName = "weekly"),
      menuSubItem("Monthly Insights", tabName = "monthly"),
      menuSubItem("Yearly Insights", tabName = "yearly"),
      menuItem("Donor Portfolio", tabName = "segment", icon = icon("list")),
      menuItem("Donation Forecasting ", tabName = "donation_forecast",icon = icon("list")),
      menuItem("Next Best Donation", tabName = "donation_prediction",icon = icon("list"))
    )
  ),
  dashboardBody(
    tabItems(
      #========  About =====#
      tabItem(tabName = "about",includeMarkdown("about.md"),hr()), 
      
      #======== Overview ========# 
      
      #======== Donor Portfolio ========# 
      tabItem(tabName = "segment",
              sidebarLayout(
                sidebarPanel(width = 3,
                             selectInput("rfmInput", "Portfolios", 
                                         choices = segment_titles, selected = segment_titles, multiple = TRUE),
                             submitButton("Submit")
                ),
                mainPanel(
                  layout_column_wrap(
                    value_box(title="Avg. # of days",value=uiOutput("valueRecency"),theme="bg-gradient-blue-purple"),
                    value_box(title="Avg. # of Gifts",value=uiOutput("valueFrequency"),theme="bg-gradient-blue-purple"),
                    value_box(title="Avg. Amount",value=uiOutput("valueMonetary"),theme="bg-gradient-blue-purple"),
                  ),
                  fluidRow(),
                  layout_columns(
                    plotlyOutput("rfmRecencyChart"),
                    plotlyOutput("rfmFrequencyChart"),
                    plotlyOutput("rfmMonetaryChart"),
                  ),
                  fluidRow(),
                  fluidRow(
                    DT::dataTableOutput("rfmTable")
                  )
                )
              )
      ),
      #======== Donor Forecasting ========#
      tabItem(tabName = "donation_forecast",
              sidebarLayout(
                sidebarPanel(width = 3,
                             selectInput("forecastSegmentInput", "Portfolios", 
                                         choices = segment_titles, selected = segment_titles, multiple = TRUE),
                             sliderInput("forecastHorizonInput", "Forecast Period (in months)", 
                                         min = 1, max = 24, value = 1), 
                             submitButton("Submit")
                ),
                mainPanel(
                  fluidRow(),
                  layout_columns(
                    plotlyOutput("donationForecastPlot"),
                    DT::dataTableOutput("donationForecastTable")
                  )
                )
              )
      ),
      #======== Donor Prediction ========# 
      tabItem(tabName = "donation_prediction",
              sidebarLayout(
                sidebarPanel(width = 3,
                             selectInput("predictionSegmentInput", "Portfolios", 
                                         choices = segment_titles, selected = segment_titles[0]),
                             sliderInput("predictionCRMInput", "# of CRM Interactions", 
                                         min = 0, max = 100, value = 1), 
                             sliderInput("predictionCRMInteractionInput", "Unique CRM Interactions", 
                                         min = 0, max = 5, value = 1), 
                             sliderInput("predictionCRMInput", "# of CRM Interactions", 
                                         min = 0, max = 100, value = 1), 
                             sliderInput("predictionGiftInput", "# of Gifts", 
                                         min = 0, max = 50, value = 1), 
                             sliderInput("predictionDayInput", "# of Days Since last gift", 
                                         min = 0, max = 3000, value = 100), 
                             submitButton("Submit")
                ),
                mainPanel(
                  fluidRow(),
                  layout_columns(
                    #plotlyOutput("rfmRecencyChart"),
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
  
  
  output$valueRecency <- renderText({
     glue::glue("{sprintf(value_box_calculations()$average_recency, fmt = '%.0f')} days")
    
  })
  
  output$valueFrequency <- renderText({
    glue::glue("{sprintf(value_box_calculations()$average_frequency, fmt = '%.0f')} gifts")
  })
  
  output$valueMonetary <- renderText({
    glue::glue("{sprintf(value_box_calculations()$average_monetary, fmt = '%.0f')} $")
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

    g <- ggplot(rfm_chart(), aes(x = reorder(segment,Recency_avg) ,y = Recency_avg))  +
      geom_bar(stat = "identity",width = 0.5, fill='black')  +
      scale_y_continuous(labels = scales::comma) +
      labs(x ="Segment", y = "Avg. # of days") + coord_flip() +
      theme(legend.text = element_text(size = 8),
            legend.title = element_text(size = 8),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 8))
    ggplotly(g)
    
  })
  
  
  output$rfmFrequencyChart <- renderPlotly({
    
    g <- ggplot(rfm_chart(), aes(x = reorder(segment,Frequency_avg) ,y = Frequency_avg))  +
      geom_bar(stat = "identity",width = 0.5, fill='black')  +
      scale_y_continuous(labels = scales::comma) +
      labs(x ="Segment", y = "Avg. # of Gifts") + coord_flip() +
      theme(legend.text = element_text(size = 8),
            legend.title = element_text(size = 8),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 8))
    ggplotly(g)
    
  })  
  
  output$rfmMonetaryChart <- renderPlotly({
    
    g <- ggplot(rfm_chart(), aes(x = reorder(segment,Monetary_avg) ,y = Monetary_avg))  +
      geom_bar(stat = "identity",width = 0.5, fill='black')  +
      scale_y_continuous(labels = scales::comma) +
      labs(x ="Segment", y = "Avg. Amount") + coord_flip() +
      theme(legend.text = element_text(size = 8),
            legend.title = element_text(size = 8),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 8))
    ggplotly(g)  
    
    
  })
    
  ##### RFM Table ######
  rfm_output <- reactive({
      df <- rfm_info() %>%
        filter(segment %in% input$rfmInput) %>%
        select(customer_id,segment,rfm_score,transaction_count,recency_days,amount)
        colnames(df) <- c('CONSTITUENT_ID', 'Segment','RFM Score','# of Gifts','# of days since last gift', 'Gift Amount')
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
      filter(segment %in% input$forecastSegmentInput) %>%
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
  
  arima_model <- reactive({auto.arima(donations_ts)})
  
  forecast_arima <- reactive({
    forecast(arima_model(), h = forecastHorizonInput)
  })
  
  # Extracting forecast values
  forecast_df <- reactive({
    as_data_frame(forecast_arima) %>%
      rename(
        `Forecasted Donation` = `Point Forecast`,
      ) %>%
      mutate(
        Month = seq(from = max(monthly_donations$year_month) + months(1),
                    by = "month",
                    length.out = input$forecastHorizonInput)
      ) %>%
      select(Month, `Forecasted Donation`)
  })
    
    

  
  output$donationForecastPlot <- renderPlotly({
    g <- forecast_df() %>%
      select(Month, `Forecasted Donation`) %>%
      ggplot(aes(x = Month ,y = `Forecasted Donation`))  +
      geom_line(stat ="identity")  + 
      labs(x ="Date", y = "Forecasted Donations") + scale_y_continuous(labels = scales::comma) + 
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            axis.title = element_text(size = 12),
            axis.text = element_text(size = 10))
    
    ggplotly(g)
  })
    
  output$donationForecastTable <- renderDataTable({
    forecast_df()
  })
    
  #===== Next Best Donation =====#
    
    
  

}

shinyApp(ui, server)
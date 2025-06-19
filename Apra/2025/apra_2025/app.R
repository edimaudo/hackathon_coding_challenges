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
# RFM
segment_titles <- c("First Grade", "Loyal", "Likely to be Loyal",
                    "New Ones", "Could be Promising", "Require Assistance", "Getting Less Frequent",
                    "Almost Out", "Can't Lose Them", "Don’t Show Up at All")

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
      menuSubItem("Weekly", tabName = "weekly"),
      menuSubItem("Monthly", tabName = "monthly"),
      menuSubItem("Yearly", tabName = "yearly"),
      menuItem("Donor Portfolio", tabName = "segment", icon = icon("list")),
      menuItem("Donor Prediction", tabName = "forecast_overview", icon = icon("list")),
      menuSubItem("Donation Forecasting ", tabName = "donation_forecast"),
      menuSubItem("Next Best Donation", tabName = "donation_prediction")
    )
  ),
  dashboardBody(
    tabItems(
      #======== 
      # About
      #======== 
      tabItem(tabName = "about",includeMarkdown("about.md"),hr()), 
      
      #======== 
      # Overview
      #======== 
      
      #======== 
      # Donor Portfolio
      #======== 
      tabItem(tabName = "segment",
              sidebarLayout(
                sidebarPanel(width = 3,
                             selectInput("rfmInput", "Portfolios", 
                                         choices = segment_titles, selected = segment_titles, multiple = TRUE),
                             submitButton("Submit")
                ),
                mainPanel(
                  layout_column_wrap(
                    value_box(title="Avg. Recency",value=uiOutput("valueRecency"),theme="bg-gradient-blue-purple"), #theme="bg-gradient-blue"
                    value_box(title="Avg. Frequency",value=uiOutput("valueFrequency"),theme="bg-gradient-blue-purple"),
                    value_box(title="Avg. Monetary",value=uiOutput("valueMonetary"),theme="bg-gradient-blue-purple"),
                  ),
                  
                  layout_column_wrap(
                    plotOutput("rfmTreemap")),
                    plotlyOutput("rfmBarChart")),
                  ),
                  fluidRow(
                    DT::dataTableOutput("rfmTable")
                  )
                )
              )
      ),
      #======== 
      # Donor Prediction
      #======== 
    )
  

 
      

################
# Server
################
server <- function(input, output,session) {

  #======== 
  # Donor Portfolio
  #========
  
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
    #names(rfm_df)[names(rfm_df) == 'customer_id'] <- 'CONSTITUENT_ID'
    
  })
  
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
  
  output$rfmBarChart <- renderPlotly({
    
  })
    
    
  
  output$rfmTable <- renderDataTable({
    rfm_output <- rfm_info() %>%
      filter(segment %in% input$rfmInput) %>%
      select(customer_id,segment,rfm_score,transaction_count,recency_days,amount)
    
    colnames(rfm_output) <- c('CONSTITUENT_ID', 'Segment','RFM Score','# of Gifts','# of days since last gift', 'Gift Amount')
    rfm_output
    
  }) 

}

shinyApp(ui, server)
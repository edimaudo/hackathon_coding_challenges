################################################
# Shiny web app which provides insights 
# for Apra data science challenge 2025
################################################
rm(list = ls())

################  Packages ####################
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
  'ggplot2', 'corrplot','tidyverse','shiny','shinydashboard','shinycssloaders',
  'bslib','readxl','DT','mlbench','caTools','gridExtra','doParallel','grid',
  'reshape2','caret','tidyr','Matrix','lubridate','plotly','RColorBrewer',
  'data.table','scales','rfm','forecast','TTR','xts','dplyr', 'treemapify','ggalluvial','ggforce'
)
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}
#===== Load Data ========
crm <- read_csv("CRM_interacions_table.csv")
gift <- read_csv("gift_transactions_table.csv")
video <- read_csv("video_email_data_table.csv")
constituent <- read_csv("constituent_profiles_table.csv")
rfm_segment <- read_excel("rfm_segments_strategy.xlsx")
rfm_segment_encoding <- read_excel("Portfolio_segment_coding.xlsx")

#===== Load ML model ========
model_load = readRDS("model.rda")

#===== Data Information ========
segment_titles <- rfm_segment$`Donor Portfolio`
month_titles <- c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec')

################### UI #############################  
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
      menuItem("Donation Overiew", tabName = "donation_overview", icon = icon("th")),
      menuItem("Donor Portfolio", tabName = "donation_segment", icon = icon("thumbs-up")),
      menuItem("Donation Forecasting ", tabName = "donation_forecast",icon = icon("credit-card")),
      menuItem("Next Best Donation", tabName = "donation_prediction",icon = icon("credit-card"))
    )
  ),
  dashboardBody(
    tabItems(
#====== About ======
      tabItem(tabName = "about",includeMarkdown("about.md"),hr()), 
#====== Donor Overview ======
      tabItem(tabName = "donation_overview",
              sidebarLayout(
                sidebarPanel(width = 3,
                             sliderInput("yearDonationInput","Year", min = 2015, max = 2024, 
                                         value = c(2015,2024), step = 1),
                             selectInput("monthDonationInput", "Month", 
                                         choices = month_titles, selected = month_titles, multiple = TRUE),
                             submitButton("Submit")
                ),
                mainPanel(width = 9,

                  tabsetPanel(type = "tabs",
                              tabPanel(h4("Donor Relationship",style="text-align: center;"),
                                       layout_column_wrap(width = 1,
                                                          plotlyOutput("donorGrowthRatePlot") %>% withSpinner()
                                       ),
                                       layout_column_wrap(width = 1,  
                                       plotlyOutput("donorRetentionChurnRatePlot") %>% withSpinner(),
                                       
                                       )
                              ),
                              tabPanel(h4("Engagement",style="text-align: center;"),
                                       layout_column_wrap(width = 1,
                                                          plotlyOutput("giftCRMPlot") %>% withSpinner() ,
                                                          plotlyOutput("CRMPlot") %>% withSpinner()
                                       ) 
                                       
                              ) ,
                              tabPanel(h4("Giving Level",style="text-align: center;"),
                                       layout_column_wrap(width = 1/2,
                                                          plotlyOutput("giftYearPlot") %>% withSpinner(),
                                                          plotlyOutput("giftYearCountPlot") %>% withSpinner()
                                       ),
                                       layout_column_wrap(width = 1,
                                                          plotlyOutput("giftYearGrowth") %>% withSpinner()
                                       ),  
                                       layout_column_wrap(width = 1/2,
                                                          plotlyOutput("giftMonthPlot") %>% withSpinner(),
                                                          plotlyOutput("giftDOWPlot") %>% withSpinner()
                                       )
                              ),

                              tabPanel(h4("Online Performance",style="text-align: center;"),
                                       layout_column_wrap(width = 1/2,
                                                          plotlyOutput("videoViewPlot") %>% withSpinner(),
                                                          plotlyOutput("clickPlot") %>% withSpinner()
                                       ),
                                       layout_column_wrap(width = 1,
                                                          plotlyOutput("bounceUnsubPlot") %>% withSpinner()
                                                          )
                              ),

                  )
              )
          )      
      ),
#====== Donor Portfolio ======
      tabItem(tabName = "donation_segment",
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
#====== Donor Forecasting ======
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
                  tabsetPanel(type = "tabs",
                              tabPanel(h4("Forecast Graph",style="text-align: center;"),
                                       plotlyOutput("donationForecastPlot") %>% withSpinner(),
                              ),
                              tabPanel(h4("Forecast Table",style="text-align: center;"),
                                       DT::dataTableOutput("donationForecastTable") %>% withSpinner(),
                              ),
                  )
                )
              )
      ),
#====== Donor Prediction ======
      tabItem(tabName = "donation_prediction",
              sidebarLayout(
                sidebarPanel(width = 3,
                             selectInput("predictionSegmentInput", "Portfolios", 
                                         choices = segment_titles, selected = segment_titles[0]),
                             sliderInput("predictionCRMInteractionInput", "Unique CRM Interactions", 
                                         min = 0, max = 5, value = 1), 
                             numericInput("predictionCRMInput", "# of CRM Interactions", 
                                          value = 1,min = 0, max = 100), 
                             numericInput("predictionGiftInput", "# of Gifts",
                                          value=1,min = 0, max = 50),
                             numericInput("predictionDayInput", "# of Days Since last gift",
                                          value=1300,min=0,max=5000),
                             submitButton("Submit")
                ),
                mainPanel(width = 9,
                    fluidRow(
                      column(width = 12,
                             valueBoxOutput("predictionOutput")
                      )
                    )
               )
             )
           )
          )
         ) 
        )    
       


################  Server ################
server <- function(input, output,session) {
  

################ Donor Overview ################
#====== Gift Data setup ======
gift_df <- reactive({
    df <- gift  %>%
      mutate(Year =  as.integer(as.numeric(lubridate::year(GIFT_DATE))),
             Month = lubridate::month(GIFT_DATE, label = TRUE),
             DOW = lubridate::wday(GIFT_DATE, label=TRUE)) %>%
      filter((Year >= input$yearDonationInput[1] & Year <= input$yearDonationInput[2]), 
             Month %in% input$monthDonationInput)
    df
  })
#====== Donor Relationship ======
# Donor Growth Rate
output$donorGrowthRatePlot <- renderPlotly({
  g <- gift_df() %>%
    group_by(Year) %>%
    summarise(Unique_Constituents = n_distinct(CONSTITUENT_ID)) %>%
    arrange(Year) %>%
    mutate(
      donorGrowth = ((Unique_Constituents - lag(Unique_Constituents)) / lag(Unique_Constituents)) * 100,
      donorGrowth = round(donorGrowth, 1),
      donorGrowth = replace_na(donorGrowth, 0)
    ) %>%
    ggplot(aes(Year, donorGrowth,  text = paste0(
      "Year: ", Year,
      "<br>Donor Growth: ", donorGrowth, "%"
    ))) + 
      geom_bar(stat = "identity",width = 0.5, fill='black')  +
      labs(x = "Year", y = "Donor Growth", title="Donor Growth by Year") + 
      scale_y_continuous(labels = comma) +
      scale_x_continuous(labels = scales::number_format(accuracy = 1, big.mark = "")) + 
    theme_minimal(base_size = 12) + 
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            plot.title = element_text(size = 12, hjust = 0.5),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10),
            axis.text.x = element_text(angle = 0, hjust = 1))
    ggplotly(g, tooltip = "text")
  
  
})

# Donor Retention and Churn rate setup
donor_churn_retention <- reactive ({
  donor_by_year <- gift_df() %>%
    group_by(Year) %>%
    summarise(donors = list(unique(CONSTITUENT_ID)),
              n_donors = n_distinct(CONSTITUENT_ID)) %>%
    arrange(Year)
  
  donor_rates <- donor_by_year %>%
    mutate(
      prev_donors = lag(donors),
      retained = map2_int(donors, prev_donors, ~ length(intersect(.x, .y))),
      retention_rate = round((retained / lag(n_donors)) * 100, 1),
      churn_rate = round(100 - retention_rate, 1)
    ) %>%
    replace_na(list(retention_rate = 0, churn_rate = 0)) %>%
    select(Year, retention_rate, churn_rate)
})



# Donor Retention & Churn Rate
output$donorRetentionChurnRatePlot <- renderPlotly({
  g <- donor_churn_retention() %>%
  ggplot(aes(x = Year)) +
    # Retention rate line (left axis)
    geom_line(aes(y = retention_rate, 
                  text = paste0("Year: ", Year,
                                "<br>Retention Rate: ", retention_rate, "%")),
              color = "darkgreen", size = 1.2, group = 1) +
    geom_point(aes(y = retention_rate), color = "darkgreen", size = 2) +
    
    # Churn rate line (right axis)
    geom_line(aes(y = churn_rate, 
                  text = paste0("Year: ", Year,
                                "<br>Churn Rate: ", churn_rate, "%")),
              color = "red", size = 1.2, group = 1, linetype = "dashed") +
    geom_point(aes(y = churn_rate), color = "red", size = 2) +
    
    # Dual axis setup
    scale_y_continuous(
      name = "Retention Rate (%)",
      sec.axis = sec_axis(~ ., name = "Churn Rate (%)")  # mirror axis
    ) +
    
    labs(
      title = "Donor Retention vs Churn Rate by Year",
      x = "Year"
    ) +
    
    scale_x_continuous(labels = scales::number_format(accuracy = 1)) +
    
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(size = 13, hjust = 0.5),
      axis.title.y.left = element_text(color = "darkgreen"),
      axis.title.y.right = element_text(color = "red"),
      axis.text = element_text(size = 10)
    )
  
  ggplotly(g, tooltip = "text")
  
})


#====== Engagement Level======
# Engagement Amount
output$giftCRMPlot <- renderPlotly({
    g <- gift_df() %>%
      left_join(crm,by='CONSTITUENT_ID') %>%
      group_by(CRM_INTERACTION_TYPE) %>%
      summarise(Total = round(mean(AMOUNT),1)) %>%
      select(CRM_INTERACTION_TYPE,Total) %>%
      na.omit() %>%
      ggplot(aes(x = reorder(CRM_INTERACTION_TYPE,Total) ,y = Total,
        text = paste0(
        "CRM Interaction Type: ", CRM_INTERACTION_TYPE,
        "<br>Amount: ", "$", Total
      ))) +
      geom_bar(stat = "identity",width = 0.5, fill='black')  +
      scale_y_continuous(labels = scales::comma) +
      labs(x ="CRM Interaction Type", y = "Avg. Gift Amount", 
           title="CRM Interaction & Avg. Gift Amount") + coord_flip() +
      theme_minimal(base_size = 12) +
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            plot.title = element_text(size = 12, hjust = 0.5),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10))
    ggplotly(g,tooltip = "text")
})

# Engagement Count
output$CRMPlot <- renderPlotly({
    crm_df <- crm %>%
      mutate(Year =  as.integer(as.numeric(lubridate::year(CRM_INTERACTION_DATE))),
             Month = lubridate::month(CRM_INTERACTION_DATE, label = TRUE)
             #DOW = lubridate::wday(CRM_INTERACTION_DATE, label=TRUE)
      ) %>%
      filter((Year >= input$yearDonationInput[1] & Year <= input$yearDonationInput[2]), 
             Month %in% input$monthDonationInput)
    
    g <- crm_df %>%
      group_by(CRM_INTERACTION_TYPE) %>%
      summarise(Total = n()) %>%
      mutate(RunningTotal = cumsum(Total),
             Percent = round((Total / sum(Total)) * 100,2)
      ) %>%
      select(CRM_INTERACTION_TYPE, Percent) %>%
      na.omit() %>%
      ggplot(aes(x = reorder(CRM_INTERACTION_TYPE,Percent) ,y = Percent,
                 text = paste0(
                   "CRM Interaction Type: ", CRM_INTERACTION_TYPE,
                   "<br>OutReach Rate: ", Percent, "%"
                 )))  +
      geom_bar(stat = "identity",width = 0.5, fill='black')  +
      scale_y_continuous(labels = scales::comma) +
      labs(x ="CRM Interaction Type", y = "OutReach Rate", title="CRM Interaction Outreach Rate") + 
      theme_minimal(base_size = 12) +
      coord_flip() +
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            plot.title = element_text(size = 12, hjust = 0.5),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10))
    
    ggplotly(g,tooltip = "text")
    
})
  
#====== Giving Level ======
# Avg. Gift Amount
output$giftYearPlot <- renderPlotly({
    g <- gift_df() %>%
    group_by(Year) %>%
      summarise(Total = round(mean(AMOUNT),1)) %>%
      select(Year, Total) %>% 
      na.omit() %>%
      ggplot(aes(Year, Total,
                 text = paste0(
                   "Year: ", Year,
                   "<br>Amount: ", "$", Total
                 ))) + 
      geom_bar(stat = "identity",width = 0.5, fill='black')  +
      labs(x = "Year", y = "Avg. Gift Amount", title="Avg. Gift Amount by Year") + 
      scale_y_continuous(labels = comma) +
      scale_x_continuous(labels = scales::number_format(accuracy = 1, big.mark = "")) + 
      theme_minimal(base_size = 12) +
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            plot.title = element_text(size = 12, hjust = 0.5),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10),
            axis.text.x = element_text(angle = 0, hjust = 1))
    ggplotly(g,tooltip = "text")
    
})
# Gift Count
output$giftYearCountPlot <- renderPlotly({
    g <- gift_df() %>%
      group_by(Year) %>%
      summarise(Total = n()) %>%
      select(Year, Total) %>% 
      na.omit() %>%
      ggplot(aes(Year, Total)) + 
      geom_bar(stat = "identity",width = 0.5, fill='black')  +
      labs(x = "Year", y = "Gift Count", title="Gift Count by Year") + 
      scale_y_continuous(labels = comma) +
      scale_x_continuous(labels = scales::number_format(accuracy = 1, big.mark = "")) + 
      theme_minimal(base_size = 12) +
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            plot.title = element_text(size = 12, hjust = 0.5),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10),
            axis.text.x = element_text(angle = 0, hjust = 1))
    ggplotly(g,tooltip = "text")
    
})

# Gift Growth
output$giftYearGrowth <- renderPlotly({
    g <- gift_df() %>%
      group_by(Year) %>%
      summarise(AvgGift = mean(AMOUNT, na.rm = TRUE)) %>%
      arrange(Year) %>%
      mutate(
        AvgGiftGrowth = ((AvgGift - lag(AvgGift)) / lag(AvgGift)) * 100,
        AvgGiftGrowth = round(AvgGiftGrowth, 1),
        AvgGiftGrowth = replace_na(AvgGiftGrowth, 0)
      ) %>%
      ggplot(aes(Year, AvgGiftGrowth,  text = paste0(
        "Year: ", Year,
        "<br>Donor Growth: ", AvgGiftGrowth, "%"
      ))) + 
      geom_col(width = 0.5, fill = "black") +
      labs(x = "Year", y = "Avg. Gift Amount Growth", title="Avg. Gift Amount Growth by Year") + 
      scale_y_continuous(labels = comma) +
      scale_x_continuous(labels = scales::number_format(accuracy = 1, big.mark = "")) + 
      theme_minimal(base_size = 12) +
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            plot.title = element_text(size = 12, hjust = 0.5),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10),
            axis.text.x = element_text(angle = 0, hjust = 1))
    ggplotly(g,tooltip = "text")
    
})
  
# Gift By Month
output$giftMonthPlot <- renderPlotly({
    g <- gift_df() %>%
      group_by(Month) %>%
      summarise(Total = round(mean(AMOUNT),1)) %>%
      select(Month, Total) %>% 
      na.omit() %>%
      ggplot(aes(Month, Total,text = paste0(
        "Month: ", Month,
        "<br>Amount: ", "$", Total
      ))) + 
      geom_col(width = 0.5, fill = "black") +
      labs(x = "Month", y = "Avg. Gift Amount", title="Avg. Gift Amount by Month") + 
      scale_y_continuous(labels = comma) + 
      theme_minimal(base_size = 12) +
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            plot.title = element_text(size = 12, hjust = 0.5),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10),
            axis.text.x = element_text(angle = 0, hjust = 1))
    ggplotly(g,tooltip = "text")
    
})
# Gift by DOW
output$giftDOWPlot <- renderPlotly({
    g <- gift_df() %>%
      group_by(DOW) %>%
      summarise(Total = round(mean(AMOUNT),1)) %>%
      select(DOW, Total) %>% 
      na.omit() %>%
      ggplot(aes(DOW, Total,text = paste0(
        "Day of Week: ", DOW,
        "<br>Amount: ",  "$", Total
      ))) + 
      geom_col(width = 0.5, fill = "black") +
      labs(x = "Day Of Week", y = "Avg. Gift Amount", title="Avg. Gift Amount by Day of Week") + 
      scale_y_continuous(labels = comma) +
      theme_minimal(base_size = 12) +
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            plot.title = element_text(size = 12, hjust = 0.5),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10),
            axis.text.x = element_text(angle = 0, hjust = 1))
    ggplotly(g,tooltip = "text")
    
})
  

  
#====== Online Performance ====== 
# Online Performance setup
video_df <- reactive({
  df <- video %>%
    mutate(Year =  as.integer(as.numeric(lubridate::year(SENT_DATE))),
           Month = lubridate::month(SENT_DATE, label = TRUE),
           DOW = lubridate::wday(SENT_DATE, label=TRUE)) %>%
    filter((Year >= input$yearDonationInput[1] & Year <= input$yearDonationInput[2]), 
           Month %in% input$monthDonationInput)
  df
})

video_df1 <- reactive({
  df <- video_df() %>%
    group_by(Year) %>%
    summarise(
      Total_Sent = n(),                            # total messages sent that year
      Total_Bounced = sum(BOUNCED, na.rm = TRUE),  # total bounces
      Total_Unsub = sum(UNSUBSCRIBED, na.rm = TRUE), # total unsubscribes
      Bounce_Rate = round((Total_Bounced / Total_Sent) * 100,2),
      Unsub_Rate = round((Total_Unsub / Total_Sent) * 100,2),
      Video_views = round(sum(VIDEO_VIEWS),0),
      Video_clicks = round(sum(CLICKS),0)
    )
})

# Video Views
output$videoViewPlot <- renderPlotly({
  g <- video_df1() %>%
    ggplot(aes(Year, Video_views,  text = paste0(
      "Year: ", Year,
      "<br>Video Views: ", Video_views
    ))) + 
    geom_bar(stat = "identity",width = 0.5, fill='black')  +
    labs(x = "Year", y = "Video Views", title="Video Views by Year") + 
    scale_y_continuous(labels = comma) +
    scale_x_continuous(labels = scales::number_format(accuracy = 1, big.mark = "")) + 
    theme_minimal(base_size = 12)  + 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          plot.title = element_text(size = 12, hjust = 0.5),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 0, hjust = 1))
  ggplotly(g, tooltip = "text")
})
# Video Clicks
output$clickPlot <- renderPlotly({
  g <- video_df1() %>%
    ggplot(aes(Year, Video_views,  text = paste0(
      "Year: ", Year,
      "<br>Video Clicks: ", Video_clicks
    ))) + 
    geom_bar(stat = "identity",width = 0.5, fill='black')  +
    labs(x = "Year", y = "Video Clicks", title="Video Clicks by Year") + 
    scale_y_continuous(labels = comma) +
    scale_x_continuous(labels = scales::number_format(accuracy = 1, big.mark = "")) + 
    theme_minimal(base_size = 12) +
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          plot.title = element_text(size = 12, hjust = 0.5),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 0, hjust = 1))
  ggplotly(g, tooltip = "text")
})

# Bounce and Unsub Rate
output$bounceUnsubPlot <- renderPlotly({
  g <- video_df1() %>%
  ggplot(aes(x = Year)) +
    geom_bar(
      aes(y = Bounce_Rate, 
          text = paste0("Year: ", Year,
                        "<br>Bounce Rate: ", Bounce_Rate, "%")),
      stat = "identity", width = 0.4, fill = "black"
    ) +
    geom_line(
      aes(y = Unsub_Rate, 
          text = paste0("Year: ", Year,
                        "<br>Unsubscribe Rate: ", Unsub_Rate, "%")),
      color = "red", size = 1.2, group = 1
    ) +
    geom_point(aes(y = Unsub_Rate), color = "red", size = 2) +
    scale_y_continuous(
      name = "Bounce Rate (%)",
      sec.axis = sec_axis(~ ., name = "Unsubscribe Rate (%)")  # mirror axis for readability
    ) +
    labs(
      title = "Bounce Rate vs Unsubscribe Rate by Year",
      x = "Year"
    ) +
    scale_x_continuous(labels = scales::number_format(accuracy = 1)) +
    theme_minimal(base_size = 12) +
    theme(
      axis.title.y.right = element_text(color = "red"),
      axis.title.y.left = element_text(color = "black"),
      plot.title = element_text(hjust = 0.5, size = 13),
      axis.text = element_text(size = 10)
    )
  
  ggplotly(g, tooltip = "text")
 
})


  
################ Donor Portfolio ################
#====== RFM Calculation ======
rfm_info  <- reactive({
    rfm_df <- gift %>%
      filter(GIFT_DATE >= '2015-01-01') %>%
      select(CONSTITUENT_ID,GIFT_DATE,AMOUNT) %>%
      na.omit()
    
    names(rfm_df)[names(rfm_df) == 'CONSTITUENT_ID'] <- 'customer_id' ## due to rfm library
    analysis_date <- lubridate::as_date(today(), tz = "UTC")
    report <- rfm_table_order(rfm_df, customer_id,GIFT_DATE,AMOUNT, analysis_date)
    
    # numerical thresholds
    r_low <-   c(5, 3, 2, 3, 4, 1, 1, 1, 2, 1)
    r_high <-   c(5, 5, 4, 4, 5, 2, 2, 3, 3, 1)
    f_low <- c(5, 3, 2, 1, 1, 3, 2, 3, 1, 1)
    f_high <- c(5, 5, 4, 3, 3, 4, 5, 5, 3, 5)
    m_low <-  c(5, 2, 2, 3, 1, 4, 4, 3, 1, 1)
    m_high <-  c(5, 5, 4, 5, 5, 5, 5, 5, 4, 5)
    
    divisions<-rfm_segment(report, segment_titles, r_low, r_high, f_low, f_high, m_low, m_high)
    
})
  
#====== RFM Metrics ======
value_box_calculations <- reactive({
    rfm_info() %>%
      filter(segment %in% input$rfmInput) %>%
      summarize(average_recency = mean(recency_days),
                average_frequency = mean(transaction_count),
                average_monetary = mean(amount)
      ) %>%
      select(average_recency,average_frequency,average_monetary)
  })
  
# RFM Recency Value Box
output$valueRecency <- renderValueBox({
    valueBox(
      value = tags$p("Avg. # of Days since last gift", style = "font-size: 18px;"),
      subtitle = tags$p((sprintf(value_box_calculations()$average_recency, fmt = '%.0f')), 
                        style = "font-size: 100%;"),
      #icon = icon("calendar"),
      color = "black"
    )
    
  })

# RFM Frequency Value Box  
output$valueFrequency <- renderValueBox({
    valueBox(
      value = tags$p("Avg. # of Gifts", style = "font-size: 18px;"),
      subtitle = tags$p((sprintf(value_box_calculations()$average_frequency, fmt = '%.0f')), 
                        style = "font-size: 100%;"),
      color = "black"
      )
  })

# RFM Monetary Value Box 
output$valueMonetary <- renderValueBox({
    valueBox(
      value = tags$p("Avg. Gift Amount", style = "font-size: 18px;"),
      subtitle = tags$p((sprintf(value_box_calculations()$average_monetary, fmt = '%.0f')), 
                        style = "font-size: 100%;"),
      color = "black"
    )
    
  
  })
  
#====== RFM Charts ======
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
      summarise(Recency_avg = round(mean(recency_days),0),
                Frequency_avg =round(mean(transaction_count),0),
                Monetary_avg = round(mean(amount),1)
                ) %>%
      select(segment,Recency_avg,Frequency_avg,Monetary_avg)
    
  })

  
output$rfmRecencyChart <- renderPlotly({

    g <- ggplot(rfm_chart(), aes(x = reorder(segment,desc(Recency_avg)) ,y = Recency_avg,
                                 text = paste0(
                                   "Segment: ", segment,
                                   "<br>Recency (Days): ", Recency_avg)))  +
      geom_bar(stat = "identity",width = 0.5, fill='black')  +
      scale_y_continuous(labels = scales::comma) +
      labs(x ="Segment", y = "Days", title="Average # of Days since last gift") + coord_flip() +
      theme_minimal(base_size = 12) +
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            plot.title = element_text(size = 10, hjust = 0.5),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10))
    ggplotly(g,tooltip = "text")
    
  })
  
  
output$rfmFrequencyChart <- renderPlotly({
    
    g <- ggplot(rfm_chart(), aes(x = reorder(segment,Frequency_avg) ,y = Frequency_avg,
                                 text = paste0(
                                   "Segment: ", segment,
                                   "<br>Frequency: ", Frequency_avg)))  +
      geom_bar(stat = "identity",width = 0.5, fill='black')  +
      scale_y_continuous(labels = scales::comma) +
      labs(x ="Segment", y = "Gifts", title = "Average # of Gifts") + coord_flip() +
      theme_minimal(base_size = 12) +
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            plot.title = element_text(size = 10, hjust = 0.5),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10))
    ggplotly(g,tooltip = "text")
    
  })  
  
output$rfmMonetaryChart <- renderPlotly({
    
    g <- ggplot(rfm_chart(), aes(x = reorder(segment,Monetary_avg) ,y = Monetary_avg,
                                 text = paste0(
                                   "Segment: ", segment,
                                   "<br>Monetary: ", "$", Monetary_avg
                                 )))  +
      geom_bar(stat = "identity",width = 0.5, fill='black')  +
      scale_y_continuous(labels = scales::comma) +
      labs(x ="Segment", y = "Amount", title = "Average Donation Amount") + coord_flip() +
      theme_minimal(base_size = 12) +
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            plot.title = element_text(size = 10, hjust = 0.5),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10))
    ggplotly(g,tooltip = "text")
    
    
  })
    
#====== RFM Table ======
output$rfmDescription <- renderDataTable({
    rfm_segment
})
  
rfm_output <- reactive({
      df <- rfm_info() %>%
        filter(segment %in% input$rfmInput) %>%
        select(customer_id,segment,rfm_score,transaction_count,recency_days,amount)
        colnames(df) <- c('CONSTITUENT_ID', 'Segment','RFM Score','# of Gifts',
                          '# of days since last gift', 'Gift Amount')
        df
})
  
output$rfmTable <- renderDataTable({
    rfm_output()
})    


#====== RFM Donor Relationship ======
# donor Growth Rate

# Donor Retention & Churn Rate

# Donor Lifetime value (constituent level and donor group level)

#====== RFM Engagement Level ======
# Engagement Amount

# Engagement Amount

#====== RFM Giving Level ======
# Avg. Gift Amount

# Gift Count

# Gift Growth

# Gift by Month

# Gift by DOW
#====== RFM Online Performance ======  
#Video Views

# Video Clicks

# Bounce & Unsub Rate

# sankey chart for sankey flow started --> 25% --> 50% 75% --> finished video for segments
################ Donation Forecasting ################
#====== Donation Forecast setup ======
forecast_df  <- reactive ({
    #set.seed(1234)
    gifts_df <- gift %>%
      filter(GIFT_DATE >= '2015-01-01') %>%
      inner_join(rfm_output(),'CONSTITUENT_ID') %>%
      group_by(CONSTITUENT_ID) %>%
      select(CONSTITUENT_ID,Segment,GIFT_DATE,AMOUNT) %>%
      na.omit()
    
     monthly_donations <- gifts_df %>%
    filter(Segment %in% c(input$forecastSegmentInput)) %>%
    mutate(GIFT_DATE = ymd(GIFT_DATE)) %>%
    # Extract year and month for grouping
    mutate(year_month = floor_date(GIFT_DATE, "month")) %>%
    group_by(year_month) %>%
    summarise(total_donations = sum(AMOUNT, na.rm = TRUE), .groups = 'drop') %>%
    arrange(year_month)
    
    start_year <- lubridate::year(min(monthly_donations$year_month))
    start_month <- lubridate::month(min(monthly_donations$year_month))
    
    donations_ts <- ts(monthly_donations$total_donations,
                       start = c(start_year, start_month),
                       frequency = 12)
    
    arima_model <- auto.arima(donations_ts)
    
    forecast_arima <- forecast(arima_model, h = input$forecastHorizonInput)
    
    df <- as_data_frame(forecast_arima) %>%
      rename(
        `Forecasted Donation` = `Point Forecast`
      ) %>%
      mutate(
        Month = seq(from = max(monthly_donations$year_month) + months(1),
                    by = "month",
                    length.out = input$forecastHorizonInput)
      ) %>%
      select(Month, `Forecasted Donation`)
    
    df$`Forecasted Donation`<-round(df$`Forecasted Donation`,2)
    df
  
  })
  output$donationForecastPlot <- renderPlotly({
    g <- forecast_df() %>%
      select(Month, `Forecasted Donation`) %>%
      ggplot(aes(x = Month ,y = `Forecasted Donation`))  +
      geom_bar(stat = "identity",width = 8, fill='black')  +
      labs(x ="Date", y = "Gift Amount", title = "Forecasted Donations") + 
      scale_y_continuous(labels = scales::comma) +
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            plot.title = element_text(size = 12, hjust = 0.5),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10))
    
     ggplotly(g)
  })
    
  output$donationForecastTable <- renderDataTable({
    forecast_df()
    
  })
    
################ Next Best Donation ################
# donation prediction setup
donation_df <- reactive({
    
    # data frame setup
    columns = c("transaction_count","recency_days","total_interactions","unique_interaction_types","segment")
    
    # Create a Empty DataFrame with 0 rows and n columns
    df = data.frame(matrix(nrow = 0, ncol = length(columns))) 
    
    # Assign column names
    colnames(df) = columns
    
    df1 <- rfm_segment_encoding %>%
      filter(rfm_segment_encoding$Portfolio == input$predictionSegmentInput) %>%
      select(Encoding)
    
    
    df <- rbind(df, c(input$predictionGiftInput,input$predictionDayInput,input$predictionCRMInput,
                      input$predictionCRMInteractionInput,df1$Encoding))
    colnames(df) = columns
    final_predictions <- predict(model_load, df)
    final_predictions <-round(final_predictions,2)
    final_predictions
    
  })
  
  output$predictionOutput <- renderValueBox({
    valueBox(
      value = tags$p("Next Best Donation", style = "font-size: 24px;"),
      subtitle = tags$p((donation_df()), style = "font-size: 100%;"),
    color = "green"
    )
  })
    
}

shinyApp(ui, server)
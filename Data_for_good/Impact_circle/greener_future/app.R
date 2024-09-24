# Twitter Analysis for greener future
rm(list = ls()) #clear environment
#===============
# libraries
#===============
packages <- c('ggplot2', 'corrplot','tidyverse',"caret",'scales',
              'dplyr','mlbench','caTools','forecast','TTR','xts','lubridate','shiny',
              'shinydashboard','tidyr','gridExtra','stopwords','tidytext','stringr',
              'reshape2', 'textdata','textmineR','topicmodels','textclean','pals','lubridate')
for (package in packages) {
    if (!require(package, character.only=T, quietly=T)) {
        install.packages(package)
        library(package, character.only=T)
    }
}
#=============
# Load data
#=============
df <- read.csv("filtered_tweets_labelled.csv")
#=============
# data update
#=============

# Time of day
df$time_info <- strptime(str_sub(df$time_collected, 12, 19), format = "%H:%M:%S")
df$time_info <- lubridate::hour(df$time_info)

# generate day of week name
df$day_of_week <- weekdays(as.Date(df$date))

# generate month information
df$month <- months.Date(as.Date(df$date))

# updated date information
df$date_info <- as.Date(df$date)

week_data <- c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")
month_data <- c("January",'February','March','April','May','June','July','August','September',
                'October','November','December')



#===============
# UI
#===============
# UI Drop-downs
time_info <- c('time','day','day of week','month')
keyword_info <- sort(c(unique(df$keyword)))
trend_info <- sort(c(unique(df$trend)))

# UI Design
ui <- dashboardPage(skin = "green",
  dashboardHeader(title = "Greener Future "),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("th")), 
      menuItem("Keywords", tabName = "keyword", icon = icon("th")),
      menuItem("Compare Keywords", tabName = "comparekeyword", icon = icon("th")),
      menuItem("Trends", tabName = "trends", icon = icon("th")),
      menuItem("Compare Trends", tabName = "comparetrend", icon = icon("th"))
    )
  ),
  dashboardBody(
    tabItems(
      #===========
      # UI Overview
      #===========
      tabItem(tabName = "overview",
                mainPanel(
                  h2("Data Overview",style="text-align: center;"), 
                  fluidRow(
                    valueBoxOutput("tweetCountBox"),
                    valueBoxOutput("favoriteCountBox"),
                    valueBoxOutput("retweetCountBox"),
                  ),
                  fluidRow(
                  tabBox(
                    title = "Insights",
                    id = "tabset1", width = '100%', height = "350px",
                    tabPanel("Hour", plotOutput("hourPlot")),
                    tabPanel("Day", plotOutput("dayPlot")),
                    tabPanel("Day of Week", plotOutput("dayofweekPlot")),
                    tabPanel("Month", plotOutput("monthPlot")), 
                    tabPanel('Keywords',DT::dataTableOutput("keywordTable")),
                    tabPanel('Trends',DT::dataTableOutput("trendoverallTable")),
                    tabPanel('Accounts',DT::dataTableOutput("accountoverallTable")),
                  )                
                )
              ) 
            ),
      #===========
      # UI Insights
      #===========     
      tabItem(tabName = "keyword",
              sidebarLayout(
                sidebarPanel(
                  selectInput("keywordInput", "Keywords", choices = keyword_info),
                  submitButton("Submit")
                ),
                mainPanel(
                  h2("Keyword Insights",style="text-align: center;"),
                  fluidRow(
                    valueBoxOutput("keywordtweetCountBox"),
                    valueBoxOutput("keywordfavoriteCountBox"),
                    valueBoxOutput("keywordretweetCountBox"),
                  ),
                  fluidRow(
                    tabBox(
                      title = "",
                      id = "tabset2", width = '100%', height = "350px",
                      tabPanel("Time", plotOutput("keywordtimePlot")),
                      tabPanel("Day", plotOutput("keyworddayPlot")),
                      tabPanel("Day of Week", plotOutput("keyworddayofweekPlot")),
                      tabPanel("Month", plotOutput("keywordmonthPlot")), 
                      tabPanel('Accounts',DT::dataTableOutput("accountTable"))
                      
                    )                
                  )
                )
              )
      ),
      #===========
      # UI Compare key words
      #===========  
      tabItem(tabName = "comparekeyword",
              sidebarLayout(
                sidebarPanel(
                  selectInput("keywordInput1", "Keyword 1",selected = 'global warming', choices = keyword_info),
                  selectInput("keywordInput2", "Keyword 2",selected = 'emissions', choices = keyword_info),
                  submitButton("Submit")
                ),
                mainPanel(
                  h2("Keyword Insights",style="text-align: center;"),
                  fluidRow(
                    h5("Keyword 1",style="text-align: left;"),
                    valueBoxOutput("keyword1tweetCountBox"),
                    valueBoxOutput("keyword1favoriteCountBox"),
                    valueBoxOutput("keyword1retweetCountBox")
                  ),
                  fluidRow(
                    h5("Keyword 2",style="text-align: left;"),
                    valueBoxOutput("keyword2tweetCountBox"),
                    valueBoxOutput("keyword2favoriteCountBox"),
                    valueBoxOutput("keyword2retweetCountBox")
                  ),
                  fluidRow(
                    tabBox(
                      title = "ReTweets",
                      id = "tabset2", width = '100%', height = "350px",
                      tabPanel("Time", plotOutput("keywordcomparetimePlot")),
                      tabPanel("Day", plotOutput("keywordcomparedayPlot")),
                      tabPanel("Day of Week", plotOutput("keywordcomparedayofweekPlot")),
                      tabPanel("Month", plotOutput("keywordcomparemonthPlot"))
                    )                
                  )
                )
              )
      ),
      #===========
      # UI Trends
      #=========== 
      tabItem(tabName = "trends",
              sidebarLayout(
                sidebarPanel(
                  selectInput("trendInput", "trends", choices = trend_info),
                  submitButton("Submit")
                ),
                mainPanel(
                  h2("Trend Insights",style="text-align: center;"),
                  fluidRow(
                    valueBoxOutput("trendtweetCountBox"),
                    valueBoxOutput("trendfavoriteCountBox"),
                    valueBoxOutput("trendretweetCountBox"),
                  ),
                  fluidRow(
                    tabBox(
                      title = "",
                      id = "tabset3", width = '100%', height = "350px",
                      tabPanel("Time", plotOutput("trendtimePlot")),
                      tabPanel("Day", plotOutput("trenddayPlot")),
                      tabPanel("Day of Week", plotOutput("trenddayofweekPlot")),
                      tabPanel("Month", plotOutput("trendmonthPlot")), 
                      tabPanel('Accounts',DT::dataTableOutput("accounttrendTable"))
                      
                    )                
                  )
                )
              )
      ),  
      #===========
      # UI Compare trends
      #=========== 
      tabItem(tabName = "comparetrend",
                     sidebarLayout(
                       sidebarPanel(
                         selectInput("trendInput1", "trend 1",selected = 'PATAGONIA', choices = trend_info),
                         selectInput("trendInput2", "trend 2",selected = 'Glasgow', choices = trend_info),
                         submitButton("Submit")
                       ),
                       mainPanel(
                         h2("trend Insights",style="text-align: center;"),
                         fluidRow(
                           h5("trend 1",style="text-align: left;"),
                           valueBoxOutput("trend1tweetCountBox"),
                           valueBoxOutput("trend1favoriteCountBox"),
                           valueBoxOutput("trend1retweetCountBox")
                         ),
                         fluidRow(
                           h5("trend 2",style="text-align: left;"),
                           valueBoxOutput("trend2tweetCountBox"),
                           valueBoxOutput("trend2favoriteCountBox"),
                           valueBoxOutput("trend2retweetCountBox")
                         ),
                         fluidRow(
                           tabBox(
                             title = "ReTweets",
                             id = "tabset2", width = '100%', height = "350px",
                             tabPanel("Time", plotOutput("trendcomparetimePlot")),
                             tabPanel("Day", plotOutput("trendcomparedayPlot")),
                             tabPanel("Day of Week", plotOutput("trendcomparedayofweekPlot")),
                             tabPanel("Month", plotOutput("trendcomparemonthPlot"))
                           )                
                         )
                       )
                     )
      )
      
          )
        )
      )

#===============
# Define server logic 
#===============
server <- function(input, output,session) {

  #======================
  # overall time trends
  #======================
  
  # overall tweets
  output$tweetCountBox <- renderValueBox({
    tweet_count_total <- df %>%
      summarize(tweet_count = n()) %>%
      select(tweet_count)
    valueBox(
      paste0(tweet_count_total, " "), "Tweets", icon = icon("list"),
      color = "green"
    )
  })

  # sum of favorites
  output$favoriteCountBox <- renderValueBox({
    favorite_count_total <- sum(df$favorite_count)
    valueBox(
      paste0(favorite_count_total, " "), "Favorites ", icon = icon("thumbs-up"),
      color = "green"
    )
  })
  
  # sum of overall retweets
  output$retweetCountBox <- renderValueBox({
    retweet_count_total <- sum(df$retweet_count)
    valueBox(
      paste0(retweet_count_total, " "), "Retweets", icon = icon("thumbs-up"),
      color = "green"
    )
  })
  
  # overall hour plot
  output$hourPlot <- renderPlot({
    df_info <- df %>%
      dplyr::group_by(time_info) %>%
      dplyr::summarize(favorite_count_total = sum(favorite_count), 
                       retweet_count_total = sum(retweet_count)) %>%
      select(time_info, favorite_count_total, retweet_count_total) %>%
      pivot_longer(-time_info, names_to = "variable", values_to = "value")
    
    ggplot(df_info, aes(time_info, value, colour = variable)) + geom_line() + theme_minimal() +
      labs(x = "Hours", y = "Count", color="Tweet Info.") + 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 15),
            axis.title = element_text(size = 15),
            axis.text = element_text(size = 15),
            axis.text.x = element_text(angle = 0, hjust = 1))
  })
  
  # overall day plot
  output$dayPlot <- renderPlot({
    df_info <- df %>%
      dplyr::group_by(date_info) %>%
      dplyr::summarize(favorite_count_total = sum(favorite_count), 
                       retweet_count_total = sum(retweet_count)) %>%
      select(date_info, favorite_count_total, retweet_count_total) %>%
      pivot_longer(-date_info, names_to = "variable", values_to = "value")
    
    ggplot(df_info, aes(date_info, value, colour = variable)) + geom_line() + theme_minimal() +
      labs(x = "Days", y = "Count", color="Tweet Info.") + 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 15),
            axis.title = element_text(size = 15),
            axis.text = element_text(size = 15),
            axis.text.x = element_text(angle = 0, hjust = 1))
  })
  
  # overall day of week plots
  output$dayofweekPlot <- renderPlot({
    df_info <- df %>%
      dplyr::group_by(day_of_week) %>%
      dplyr::summarize(favorite_count_total = sum(favorite_count), 
                       retweet_count_total = sum(retweet_count)) %>%
      select(day_of_week, favorite_count_total, retweet_count_total) %>%
      pivot_longer(-day_of_week, names_to = "variable", values_to = "value")
    

    ggplot(df_info, aes(ordered(day_of_week,levels=week_data), value, fill = variable)) + 
      geom_bar(stat="identity", width = 0.5, position="dodge") + 
      theme_minimal() + scale_y_continuous(labels = comma) +
      labs(x = "Day of Week", y = "Count", fill="Tweet Info.") + 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 15),
            axis.title = element_text(size = 15),
            axis.text = element_text(size = 15),
            axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  #overall  month plots
  output$monthPlot <- renderPlot({
    df_info <- df %>%
      dplyr::group_by(month) %>%
      dplyr::summarize(favorite_count_total = sum(favorite_count), 
                       retweet_count_total = sum(retweet_count)) %>%
      select(month, favorite_count_total, retweet_count_total) %>%
      pivot_longer(-month, names_to = "variable", values_to = "value")
    
    ggplot(df_info, aes(ordered(month,levels=month_data), value, fill = variable)) + 
      geom_bar(stat="identity", width = 0.5, position="dodge") + 
      theme_minimal() + scale_y_continuous(labels = comma) +
      labs(x = "Month", y = "Count", fill="Tweet Info.") + 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 15),
            axis.title = element_text(size = 15),
            axis.text = element_text(size = 15),
            axis.text.x = element_text(angle = 0, hjust = 1))
  })
    
  #overall  key word information
  output$keywordTable <- DT::renderDataTable({
    df_keyword <- df %>%
      group_by(keyword) %>%
      summarise(keyword_count = n(), favorite_count_total = sum(favorite_count), 
                retweet_count_total = sum(retweet_count)) %>%
      arrange(desc(keyword_count)) %>%
      select(keyword,keyword_count, favorite_count_total, retweet_count_total) 

    DT::datatable(df_keyword)
    
  })
  
  #overall  trend information
  output$trendoverallTable <- DT::renderDataTable({
    df_keyword <- df %>%
      group_by(trend) %>%
      summarise(keyword_count = n(), favorite_count_total = sum(favorite_count), 
                retweet_count_total = sum(retweet_count)) %>%
      arrange(desc(retweet_count_total)) %>%
      select(trend,keyword_count, favorite_count_total, retweet_count_total) 
    
    DT::datatable(df_keyword)
    
  })
  
  #overall  trend information
  output$accountoverallTable <- DT::renderDataTable({
    df_keyword <- df %>%
      group_by(account) %>%
      summarise(keyword_count = n(), favorite_count_total = sum(favorite_count), 
                retweet_count_total = sum(retweet_count)) %>%
      arrange(desc(retweet_count_total)) %>%
      select(account,keyword_count, favorite_count_total, retweet_count_total) 
    
    DT::datatable(df_keyword)
    
  })
  
  #======================
  # All keywords
  #======================
  # render box keyword insights
  output$keywordtweetCountBox <- renderValueBox({
    
    tweet_count_total <- df %>%
        filter(keyword == input$keywordInput) %>%
        summarize(tweet_count = n()) %>%
        select(tweet_count)
    
    valueBox(
      paste0(tweet_count_total, " "), "Tweets", icon = icon("list"),
      color = "green"
    )
  })
  
  output$keywordfavoriteCountBox <- renderValueBox({
    favorite_count_total <- df %>%
      filter(keyword == input$keywordInput) %>%
      summarize(favorite_count = sum(favorite_count))  %>%
      select(favorite_count)
    valueBox(
      paste0(favorite_count_total, " "), "Favorites ", icon = icon("thumbs-up"),
      color = "green"
    )
  })
  
  output$keywordretweetCountBox <- renderValueBox({
    retweet_count_total <- df %>%
      filter(keyword == input$keywordInput) %>%
      summarize(retweet_count = sum(retweet_count)) %>%
      select(retweet_count)  
    valueBox(
      paste0(retweet_count_total, " "), "Retweets", icon = icon("thumbs-up"),
      color = "green"
    )
  })
  
 
  # Keyword time trends
  output$keywordtimePlot <- renderPlot({
    df_info <- df %>%
      filter(keyword == input$keywordInput) %>%
      dplyr::group_by(time_info) %>%
      dplyr::summarize(favorite_count_total = sum(favorite_count), 
                       retweet_count_total = sum(retweet_count)) %>%
      select(time_info, favorite_count_total, retweet_count_total) %>%
      pivot_longer(-time_info, names_to = "variable", values_to = "value")
    
    
    ggplot(df_info, aes(reorder(time_info,value), value, fill = variable)) + 
      geom_bar(stat="identity", width = 0.5, position="dodge") + 
      theme_minimal() + coord_flip() + scale_y_continuous(labels = comma) +
      labs(x = "Time", y = "Count", fill="Tweet Info.") + 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 15),
            axis.title = element_text(size = 15),
            axis.text = element_text(size = 15),
            axis.text.x = element_text(angle = 45, hjust = 1))
  }) 
  
  
  output$keyworddayPlot <- renderPlot({
    df_info <- df %>%
      filter(keyword == input$keywordInput) %>%
      dplyr::group_by(date_info) %>%
      dplyr::summarize(favorite_count_total = sum(favorite_count), 
                       retweet_count_total = sum(retweet_count)) %>%
      arrange(desc(retweet_count_total)) %>%
      top_n(24) %>%
      select(date_info, favorite_count_total, retweet_count_total) %>%
      pivot_longer(-date_info, names_to = "variable", values_to = "value")
  
    ggplot(df_info, aes(reorder(date_info,value), value, fill = variable)) + 
      geom_bar(stat="identity", width = 0.5, position="dodge") + 
      theme_minimal() + coord_flip() + scale_y_continuous(labels = comma) +
      labs(x = "Date", y = "Count", fill="Tweet Info.") + 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 15),
            axis.title = element_text(size = 15),
            axis.text = element_text(size = 15),
            axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  # keyword day plots
  output$keyworddayofweekPlot <- renderPlot({
    df_info <- df %>%
      filter(keyword == input$keywordInput) %>%
      dplyr::group_by(day_of_week) %>%
      dplyr::summarize(favorite_count_total = sum(favorite_count), 
                       retweet_count_total = sum(retweet_count)) %>%
      select(day_of_week, favorite_count_total, retweet_count_total) %>%
      pivot_longer(-day_of_week, names_to = "variable", values_to = "value")
    
    ggplot(df_info, aes(reorder(day_of_week,value), value, fill = variable)) + 
      geom_bar(stat="identity", width = 0.5, position="dodge") + 
      theme_minimal() + coord_flip() + scale_y_continuous(labels = comma) +
      labs(x = "Day of Week", y = "Count", fill="Tweet Info.") + 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 15),
            axis.title = element_text(size = 15),
            axis.text = element_text(size = 15),
            axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  # keyword month plots
  output$keywordmonthPlot <- renderPlot({
    df_info <- df %>%
      filter(keyword == input$keywordInput) %>%
      dplyr::group_by(month) %>%
      dplyr::summarize(favorite_count_total = sum(favorite_count), 
                       retweet_count_total = sum(retweet_count)) %>%
      select(month, favorite_count_total, retweet_count_total) %>%
      pivot_longer(-month, names_to = "variable", values_to = "value")
    
    ggplot(df_info, aes(reorder(month,value), value, fill = variable)) + 
      geom_bar(stat="identity", width = 0.5, position="dodge") + 
      theme_minimal() + coord_flip() + scale_y_continuous(labels = comma) +
      labs(x = "Month", y = "Count", fill="Tweet Info.") + 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 15),
            axis.title = element_text(size = 15),
            axis.text = element_text(size = 15),
            axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  #overall  key word information for top 10 accounts
  output$accountTable <- DT::renderDataTable({
    df_keyword <- df %>%
      filter(keyword == input$keywordInput) %>%
      group_by(account) %>%
      summarise(keyword_count = n(), favorite_count_total = sum(favorite_count), 
                retweet_count_total = sum(retweet_count)) %>%
      arrange(desc(retweet_count_total)) %>%
      top_n(10) %>%
      select(account,retweet_count_total) 
    
    DT::datatable(df_keyword)
    
  })
  
  #======================
  # Keyword comparison
  #======================
  # render box keyword insights
  output$keyword1tweetCountBox <- renderValueBox({
    
    tweet_count_total <- df %>%
      filter(keyword == input$keywordInput1) %>%
      summarize(tweet_count = n()) %>%
      select(tweet_count)
    
    valueBox(
      paste0(tweet_count_total, " "), "Tweets", icon = icon("list"),
      color = "green"
    )
  })
  
  output$keyword1favoriteCountBox <- renderValueBox({
    favorite_count_total <- df %>%
      filter(keyword == input$keywordInput1) %>%
      summarize(favorite_count = sum(favorite_count))  %>%
      select(favorite_count)
    valueBox(
      paste0(favorite_count_total, " "), "Favorites ", icon = icon("thumbs-up"),
      color = "green"
    )
  })
  
  output$keyword1retweetCountBox <- renderValueBox({
    retweet_count_total <- df %>%
      filter(keyword == input$keywordInput1) %>%
      summarize(retweet_count = sum(retweet_count)) %>%
      select(retweet_count)  
    valueBox(
      paste0(retweet_count_total, " "), "Retweets", icon = icon("thumbs-up"),
      color = "green"
    )
  })
  
  output$keyword2tweetCountBox <- renderValueBox({
    tweet_count_total <- df %>%
      filter(keyword == input$keywordInput2) %>%
      summarize(tweet_count = n()) %>%
      select(tweet_count)
    
    valueBox(
      paste0(tweet_count_total, " "), "Tweets", icon = icon("list"),
      color = "blue"
    )
  })
  
  output$keyword2favoriteCountBox <- renderValueBox({
    favorite_count_total <- df %>%
      filter(keyword == input$keywordInput2) %>%
      summarize(favorite_count = sum(favorite_count))  %>%
      select(favorite_count)
    valueBox(
      paste0(favorite_count_total, " "), "Favorites ", icon = icon("thumbs-up"),
      color = "blue"
    )
  })
  
  output$keyword2retweetCountBox <- renderValueBox({
    retweet_count_total <- df %>%
      filter(keyword == input$keywordInput2) %>%
      summarize(retweet_count = sum(retweet_count)) %>%
      select(retweet_count)  
    valueBox(
      paste0(retweet_count_total, " "), "Retweets", icon = icon("thumbs-up"),
      color = "blue"
    )
  })
  # key word compare hour
  output$keywordcomparetimePlot <- renderPlot({
    df_info <- df %>%
      filter(keyword %in% c(input$keywordInput1,input$keywordInput2)) %>%
             dplyr::group_by(time_info,keyword) %>%
               dplyr::summarize(retweet_count_total = sum(retweet_count)) %>%
               select(time_info,keyword, retweet_count_total)
             
             ggplot(df_info, aes(time_info, retweet_count_total, fill  = keyword)) + 
               geom_bar(stat="identity", width = 0.5, position="dodge") + 
               theme_minimal() + scale_y_continuous(labels = comma) +
               labs(x = "Time", y = "Count", fill="Keywords") + 
               theme(legend.text = element_text(size = 12),
                     legend.title = element_text(size = 15),
                     axis.title = element_text(size = 15),
                     axis.text = element_text(size = 15),
                     axis.text.x = element_text(angle = 0, hjust = 1))
  }) 
  # keyword  comparedate 
  output$keywordcomparedayPlot <- renderPlot({
    df_info <- df %>%
      filter(keyword %in% c(input$keywordInput1,input$keywordInput2)) %>%
      dplyr::group_by(date_info,keyword) %>%
      dplyr::summarize(retweet_count_total = sum(retweet_count)) %>%
      select(date_info, keyword, retweet_count_total)
    
    ggplot(df_info, aes(date_info, retweet_count_total, fill  = keyword)) + 
      geom_bar(stat="identity", width = 0.5, position="dodge") + 
      theme_minimal() + scale_y_continuous(labels = comma) +
      labs(x = "Date", y = "Count", fill="Keywords") + 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 15),
            axis.title = element_text(size = 15),
            axis.text = element_text(size = 15),
            axis.text.x = element_text(angle = 0, hjust = 1))
  })
  
  # keyword day plots
  output$keywordcomparedayofweekPlot <- renderPlot({
    df_info <- df %>%
      filter(keyword %in% c(input$keywordInput1,input$keywordInput2)) %>%
      dplyr::group_by(day_of_week,keyword) %>%
      dplyr::summarize(retweet_count_total = sum(retweet_count)) %>%
      select(day_of_week, keyword, retweet_count_total) 
    
    ggplot(df_info, aes(ordered(day_of_week,levels=week_data), retweet_count_total, fill  = keyword)) +
      geom_bar(stat="identity", width = 0.5, position="dodge") + 
      theme_minimal() + scale_y_continuous(labels = comma) +
      labs(x = "Day of Week", y = "Count", fill="Keywords") + 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 15),
            axis.title = element_text(size = 15),
            axis.text = element_text(size = 15),
            axis.text.x = element_text(angle = 25, hjust = 1))
  })
  
  # keyword month plots
  output$keywordcomparemonthPlot <- renderPlot({
    df_info <- df %>%
      filter(keyword %in% c(input$keywordInput1,input$keywordInput2)) %>%
      dplyr::group_by(month,keyword) %>%
      dplyr::summarize(retweet_count_total = sum(retweet_count)) %>%
      select(month,keyword, retweet_count_total) 
    
    
    ggplot(df_info, aes(ordered(month,levels=month_data), retweet_count_total, fill  = keyword)) +
      geom_bar(stat="identity", width = 0.5, position="dodge") + 
      theme_minimal() + scale_y_continuous(labels = comma) +
      labs(x = "Month", y = "Count", fill="Keyword") + 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 15),
            axis.title = element_text(size = 15),
            axis.text = element_text(size = 15),
            axis.text.x = element_text(angle = 0, hjust = 1))
  })
  
  
  
  #======================
  # All Trends
  #======================
  # render box trend insights
  output$trendtweetCountBox <- renderValueBox({
    
    tweet_count_total <- df %>%
      filter(trend == input$trendInput) %>%
      summarize(tweet_count = n()) %>%
      select(tweet_count)
    
    valueBox(
      paste0(tweet_count_total, " "), "Tweets", icon = icon("list"),
      color = "green"
    )
  })
  
  output$trendfavoriteCountBox <- renderValueBox({
    favorite_count_total <- df %>%
      filter(trend == input$trendInput) %>%
      summarize(favorite_count = sum(favorite_count))  %>%
      select(favorite_count)
    valueBox(
      paste0(favorite_count_total, " "), "Favorites ", icon = icon("thumbs-up"),
      color = "green"
    )
  })
  
  output$trendretweetCountBox <- renderValueBox({
    retweet_count_total <- df %>%
      filter(trend == input$trendInput) %>%
      summarize(retweet_count = sum(retweet_count)) %>%
      select(retweet_count)  
    valueBox(
      paste0(retweet_count_total, " "), "Retweets", icon = icon("thumbs-up"),
      color = "green"
    )
  })
  
  
  # trend time trends
  output$trendtimePlot <- renderPlot({
    df_info <- df %>%
      filter(trend == input$trendInput) %>%
      dplyr::group_by(time_info) %>%
      dplyr::summarize(favorite_count_total = sum(favorite_count), 
                       retweet_count_total = sum(retweet_count)) %>%
      select(time_info, favorite_count_total, retweet_count_total) %>%
      pivot_longer(-time_info, names_to = "variable", values_to = "value")
    
    
    ggplot(df_info, aes(reorder(time_info,value), value, fill = variable)) + 
      geom_bar(stat="identity", width = 0.5, position="dodge") + 
      theme_minimal() + coord_flip() + scale_y_continuous(labels = comma) +
      labs(x = "Time", y = "Count", fill="Tweet Info.") + 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 15),
            axis.title = element_text(size = 15),
            axis.text = element_text(size = 15),
            axis.text.x = element_text(angle = 45, hjust = 1))
  }) 
  
  
  output$trenddayPlot <- renderPlot({
    df_info <- df %>%
      filter(trend == input$trendInput) %>%
      dplyr::group_by(date_info) %>%
      dplyr::summarize(favorite_count_total = sum(favorite_count), 
                       retweet_count_total = sum(retweet_count)) %>%
      arrange(desc(retweet_count_total)) %>%
      top_n(24) %>%
      select(date_info, favorite_count_total, retweet_count_total) %>%
      pivot_longer(-date_info, names_to = "variable", values_to = "value")
    
    ggplot(df_info, aes(reorder(date_info,value), value, fill = variable)) + 
      geom_bar(stat="identity", width = 0.5, position="dodge") + 
      theme_minimal() + coord_flip() + scale_y_continuous(labels = comma) +
      labs(x = "Date", y = "Count", fill="Tweet Info.") + 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 15),
            axis.title = element_text(size = 15),
            axis.text = element_text(size = 15),
            axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  # trend day plots
  output$trenddayofweekPlot <- renderPlot({
    df_info <- df %>%
      filter(trend == input$trendInput) %>%
      dplyr::group_by(day_of_week) %>%
      dplyr::summarize(favorite_count_total = sum(favorite_count), 
                       retweet_count_total = sum(retweet_count)) %>%
      select(day_of_week, favorite_count_total, retweet_count_total) %>%
      pivot_longer(-day_of_week, names_to = "variable", values_to = "value")
    
    ggplot(df_info, aes(reorder(day_of_week,value), value, fill = variable)) + 
      geom_bar(stat="identity", width = 0.5, position="dodge") + 
      theme_minimal() + coord_flip() + scale_y_continuous(labels = comma) +
      labs(x = "Day of Week", y = "Count", fill="Tweet Info.") + 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 15),
            axis.title = element_text(size = 15),
            axis.text = element_text(size = 15),
            axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  # trend month plots
  output$trendmonthPlot <- renderPlot({
    df_info <- df %>%
      filter(trend == input$trendInput) %>%
      dplyr::group_by(month) %>%
      dplyr::summarize(favorite_count_total = sum(favorite_count), 
                       retweet_count_total = sum(retweet_count)) %>%
      select(month, favorite_count_total, retweet_count_total) %>%
      pivot_longer(-month, names_to = "variable", values_to = "value")
    
    ggplot(df_info, aes(reorder(month,value), value, fill = variable)) + 
      geom_bar(stat="identity", width = 0.5, position="dodge") + 
      theme_minimal() + coord_flip() + scale_y_continuous(labels = comma) +
      labs(x = "Month", y = "Count", fill="Tweet Info.") + 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 15),
            axis.title = element_text(size = 15),
            axis.text = element_text(size = 15),
            axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  #overall  key word information for top 10 accounts
  output$accounttrendTable <- DT::renderDataTable({
    df_trend <- df %>%
      filter(trend == input$trendInput) %>%
      group_by(account) %>%
      summarise(trend_count = n(), favorite_count_total = sum(favorite_count), 
                retweet_count_total = sum(retweet_count)) %>%
      arrange(desc(retweet_count_total)) %>%
      top_n(10) %>%
      select(account,retweet_count_total) 
    
    DT::datatable(df_trend)
    
  })
  
  #==================
  # Trend comparison
  #==================
  # render box trend insights
  output$trend1tweetCountBox <- renderValueBox({
    
    tweet_count_total <- df %>%
      filter(trend == input$trendInput1) %>%
      summarize(tweet_count = n()) %>%
      select(tweet_count)
    
    valueBox(
      paste0(tweet_count_total, " "), "Tweets", icon = icon("list"),
      color = "green"
    )
  })
  
  output$trend1favoriteCountBox <- renderValueBox({
    favorite_count_total <- df %>%
      filter(trend == input$trendInput1) %>%
      summarize(favorite_count = sum(favorite_count))  %>%
      select(favorite_count)
    valueBox(
      paste0(favorite_count_total, " "), "Favorites ", icon = icon("thumbs-up"),
      color = "green"
    )
  })
  
  output$trend1retweetCountBox <- renderValueBox({
    retweet_count_total <- df %>%
      filter(trend == input$trendInput1) %>%
      summarize(retweet_count = sum(retweet_count)) %>%
      select(retweet_count)  
    valueBox(
      paste0(retweet_count_total, " "), "Retweets", icon = icon("thumbs-up"),
      color = "green"
    )
  })
  
  output$trend2tweetCountBox <- renderValueBox({
    tweet_count_total <- df %>%
      filter(trend == input$trendInput2) %>%
      summarize(tweet_count = n()) %>%
      select(tweet_count)
    
    valueBox(
      paste0(tweet_count_total, " "), "Tweets", icon = icon("list"),
      color = "blue"
    )
  })
  
  output$trend2favoriteCountBox <- renderValueBox({
    favorite_count_total <- df %>%
      filter(trend == input$trendInput2) %>%
      summarize(favorite_count = sum(favorite_count))  %>%
      select(favorite_count)
    valueBox(
      paste0(favorite_count_total, " "), "Favorites ", icon = icon("thumbs-up"),
      color = "blue"
    )
  })
  
  output$trend2retweetCountBox <- renderValueBox({
    retweet_count_total <- df %>%
      filter(trend == input$trendInput2) %>%
      summarize(retweet_count = sum(retweet_count)) %>%
      select(retweet_count)  
    valueBox(
      paste0(retweet_count_total, " "), "Retweets", icon = icon("thumbs-up"),
      color = "blue"
    )
  })
  # trend compare hour
  output$trendcomparetimePlot <- renderPlot({
    df_info <- df %>%
      filter(trend %in% c(input$trendInput1,input$trendInput2)) %>%
      dplyr::group_by(time_info,trend) %>%
      dplyr::summarize(retweet_count_total = sum(retweet_count)) %>%
      select(time_info,trend, retweet_count_total)
    
    ggplot(df_info, aes(time_info, retweet_count_total, fill  = trend)) + 
      geom_bar(stat="identity", width = 0.5, position="dodge") + 
      theme_minimal() + scale_y_continuous(labels = comma) +
      labs(x = "Time", y = "Count", fill="trends") + 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 15),
            axis.title = element_text(size = 15),
            axis.text = element_text(size = 15),
            axis.text.x = element_text(angle = 0, hjust = 1))
  }) 
  # trend  comparedate 
  output$trendcomparedayPlot <- renderPlot({
    df_info <- df %>%
      filter(trend %in% c(input$trendInput1,input$trendInput2)) %>%
      dplyr::group_by(date_info,trend) %>%
      dplyr::summarize(retweet_count_total = sum(retweet_count)) %>%
      select(date_info, trend, retweet_count_total)
    
    ggplot(df_info, aes(date_info, retweet_count_total, fill  = trend)) + 
      geom_bar(stat="identity", width = 0.5, position="dodge") + 
      theme_minimal() + scale_y_continuous(labels = comma) +
      labs(x = "Date", y = "Count", fill="trends") + 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 15),
            axis.title = element_text(size = 15),
            axis.text = element_text(size = 15),
            axis.text.x = element_text(angle = 0, hjust = 1))
  })
  
  # trend day plots
  output$trendcomparedayofweekPlot <- renderPlot({
    df_info <- df %>%
      filter(trend %in% c(input$trendInput1,input$trendInput2)) %>%
      dplyr::group_by(day_of_week,trend) %>%
      dplyr::summarize(retweet_count_total = sum(retweet_count)) %>%
      select(day_of_week, trend, retweet_count_total) 
    
    ggplot(df_info, aes(ordered(day_of_week,levels=week_data), retweet_count_total, fill  = trend)) +
      geom_bar(stat="identity", width = 0.5, position="dodge") + 
      theme_minimal() + scale_y_continuous(labels = comma) +
      labs(x = "Day of Week", y = "Count", fill="trends") + 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 15),
            axis.title = element_text(size = 15),
            axis.text = element_text(size = 15),
            axis.text.x = element_text(angle = 25, hjust = 1))
  })
  
  # trend month plots
  output$trendcomparemonthPlot <- renderPlot({
    df_info <- df %>%
      filter(trend %in% c(input$trendInput1,input$trendInput2)) %>%
      dplyr::group_by(month,trend) %>%
      dplyr::summarize(retweet_count_total = sum(retweet_count)) %>%
      select(month,trend, retweet_count_total) 
    
    
    ggplot(df_info, aes(ordered(month,levels=month_data), retweet_count_total, fill  = trend)) +
      geom_bar(stat="identity", width = 0.5, position="dodge") + 
      theme_minimal() + scale_y_continuous(labels = comma) +
      labs(x = "Month", y = "Count", fill="trend") + 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 15),
            axis.title = element_text(size = 15),
            axis.text = element_text(size = 15),
            axis.text.x = element_text(angle = 0, hjust = 1))
  })
  #======================
  # Trend Comparison
  #======================
  
  
  }

shinyApp(ui, server)
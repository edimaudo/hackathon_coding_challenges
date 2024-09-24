rm(list = ls()) #clear environment
#=============
# Packages
#=============
packages <- c('ggplot2', 'corrplot','tidyverse',"caret",'readxl','tidyr',
              'scales','dplyr','wordcloud2','gridExtra','stopwords',
              'tidytext','stringr','reshape2', 'textdata',
              'textmineR','topicmodels','textclean','pals','lubridate')
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
df.backup <- df
other <- read.csv("greener_tweets.csv")

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
#=============
# Text visualization
#=============

# Account frequency
account_count <- df %>%
  group_by(account) %>%
  summarise(num_words = n()) %>%
  arrange(desc(num_words)) %>%
  top_n(10, nu)


# Key word frequency
keyword_count <- df %>%
  group_by(keyword) %>%
  summarise(num_words = n()) %>%
  top_n(10)
  arrange(desc(num_words))

  ggplot(data=keyword_count, aes(reorder(keyword,num_words), y=num_words),fill = keyword) +
  geom_bar(stat="identity", width = 0.4) + theme_classic() +
  labs(x = "keyword", y = "Count") +
  scale_y_continuous(labels = comma) + coord_flip() + 
  scale_x_discrete() +
  theme(legend.text = element_text(size = 10),
        legend.title = element_text(size = 10),
        axis.title = element_text(size = 15),
        axis.text = element_text(size = 10),
        axis.text.x = element_text(angle = 45, hjust = 1))  

  df_keyword <- df %>%
    group_by(keyword) %>%
    summarise(keyword_count = n()) %>%
    arrange(desc(keyword_count)) %>%
    top_n(10) %>%
    select(keyword,keyword_count) %>%
    
    



    # overall hour plot
   
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
    
  
  # overall day plot

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
  
  
  # overall day of week plots

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
  
  
  #overall  month plots

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

rm(list = ls())
#packages 
packages <- c('ggplot2', 'corrplot','tidyverse','shiny','shinydashboard',
              'SnowballC','wordcloud','dplyr','tidytext','readxl','scales','rfm',
              'lubridate')
#load packages
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}

#load data
df <- read_excel("Constituents_Donations_Cleaned_joined.xlsx")

#gender information
#library(gender)
#install.packages("genderdata", type = "source",
#                 repos = "http://packages.ropensci.org")
#name_info<- gender(df$lower_ignore_check, years = c(1930, 2012), method = "ssa")

##nellies




#==============
#organization
#==============
df_org <- df %>%
  filter(Org_Flag == "Organization") %>%
  select(Constituent_ID,Gift_Date,Gift_Amount)

#update date
df_org$Gift_Date <- as.Date(df_org$Gift_Date)

#rfm model
analysis_date <- lubridate::as_date("2020-07-07", tz = "UTC")
report <- rfm_table_order(df_org, Constituent_ID,Gift_Date,Gift_Amount, analysis_date)
#segment
segment_titles <- c("First Grade", "Loyal", "Likely to be Loyal",
                    "New Ones", "Could be Promising", "Require Assistance", "Getting Less Frequent",
                    "Almost Out", "Can't Lose Them", "Don’t Show Up at All")
#numerical thresholds
 r_low <- c(4, 2, 3, 4, 3, 2, 2, 1, 1, 1)
 r_high <- c(5, 5, 5, 5, 4, 3, 3, 2, 1, 2)
 f_low <- c(4, 3, 1, 1, 1, 2, 1, 2, 4, 1)
 f_high <- c(5, 5, 3, 1, 1, 3, 2, 5, 5, 2)
 m_low <- c(4, 3, 1, 1, 1, 2, 1, 2, 4, 1)
 m_high  <- c(5, 5, 3, 1, 1, 3, 2, 5, 5, 2)

divisions<-rfm_segment(report, segment_titles, r_low, r_high, f_low, f_high, m_low, m_high)

division_count <- divisions %>% count(segment) %>% arrange(desc(n)) %>% rename(Segment = segment, Count = n)

#org rfm analysis
write.csv(divisions,"divisions.csv")


#=========
#individuals
#==========
df_ind <- df %>%
  filter(Org_Flag != "Organization") %>%
  select(Constituent_ID,Gift_Date,Gift_Amount)

#update date
df_ind$Gift_Date <- as.Date(df_ind$Gift_Date)

#rfm model
#rfm model
analysis_date <- lubridate::as_date("2020-07-07", tz = "UTC")
report <- rfm_table_order(df_ind, Constituent_ID,Gift_Date,Gift_Amount, analysis_date)
#segment
segment_titles <- c("First Grade", "Loyal", "Likely to be Loyal",
                    "New Ones", "Could be Promising", "Require Assistance", "Getting Less Frequent",
                    "Almost Out", "Can't Lose Them", "Don’t Show Up at All")
#numerical thresholds
r_low <- c(4, 2, 3, 4, 3, 2, 2, 1, 1, 1)
r_high <- c(5, 5, 5, 5, 4, 3, 3, 2, 1, 2)
f_low <- c(4, 3, 1, 1, 1, 2, 1, 2, 4, 1)
f_high <- c(5, 5, 3, 1, 1, 3, 2, 5, 5, 2)
m_low <- c(4, 3, 1, 1, 1, 2, 1, 2, 4, 1)
m_high  <- c(5, 5, 3, 1, 1, 3, 2, 5, 5, 2)

divisions<-rfm_segment(report, segment_titles, r_low, r_high, f_low, f_high, m_low, m_high)

division_count <- divisions %>% count(segment) %>% arrange(desc(n)) %>% rename(Segment = segment, Count = n)


write.csv(divisions,"ind_divisions.csv")






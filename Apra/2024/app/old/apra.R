packages <- c(
  'ggplot2', 'corrplot','tidyverse','shiny','shinydashboard','DT','readxl',
  'mlbench','caTools','gridExtra','doParallel','grid','forecast','reshape2',
  'caret','dummies','tidyr','Matrix','lubridate','plotly','RColorBrewer',
  'data.table','scales','rfm','Metrics','forecast','TTR','xts'
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


# defining start date 
start_date <- as.Date("2010-01-01") 

# defining end date 
end_date <- as.Date(today()) 

# generating range of dates 
date_range <- data.frame(seq(start_date, end_date,"days")) 
gift_data <- data.frame(data=c(1:nrow(date_range)))


colnames(date_range) <- "GIFT_DATE"

date_range <- cbind(date_range,gift_data)



transaction_f <- transaction %>%
  filter(GIFT_DATE >= '2010-01-01',GIFT_DATE <= today()) %>%
  group_by(GIFT_DATE) %>%
  summarise(Total = sum(GIFT_AMOUNT)) %>%
  right_join(date_range,by='GIFT_DATE') %>%
  replace(is.na(.), 0) %>%
  select(GIFT_DATE,Total)

  
gift_xts <- xts(x = transaction_f$Total, order.by = transaction_f$GIFT_DATE) 
gift_daily <- apply.daily(gift_xts,mean)
gift_weekly <- apply.weekly(gift_xts, mean) 
gift_monthly <- apply.monthly(gift_xts, mean)
gift_yearly<- apply.yearly(gift_xts, mean)

autoplot(gift_daily, main = "Daily Gift amount from 2010 onwards") +  
  scale_y_continuous(labels = scales::comma) + labs(x ="Gift Date", y = "Gift Amount")
autoplot(gift_weekly, main = "Weekly Gift amount from 2010 onwards")  + 
  scale_y_continuous(labels = scales::comma) + labs(x ="Gift Date", y = "Gift Amount")
g <- autoplot(gift_monthly, main = "Monthly Gift amount from 2010 onwards") +   
  scale_y_continuous(labels = scales::comma) + labs(x ="Gift Date", y = "Gift Amount")

ggplotly(g)

gift_amt <- ts(transaction_f$Total)
gift_amt <- ts(transaction_f$Total, frequency = 365.25, start = 2010)
gift_amt
autoplot(gift_amt, main = "Gift amount from 2010 onwards")

decomposed_gift_additive <- decompose(gift_amt, type = "additive")
autoplot(decomposed_gift_additive)

decomposed_gift_multiplicative <- decompose(gift_amt, type = "multiplicative")
autoplot(decomposed_gift_multiplicative)

# forecasting plot

# simple exponential smoothing
autoplot(ses(gift_amt), PI = FALSE)

# dampened holt
autoplot(holt(gift_amt, damped = TRUE, h = 36), PI = FALSE)


# holt linear
autoplot(holt(gift_amt), PI = FALSE)

# holt winter
autoplot(gift_amt) + autolayer(hw(gift_amt, seasonal = "multiplicative", PI=FALSE)) + autolayer(hw(gift_amt, seasonal = "additive", PI=FALSE), col="Red")

# ETS
autoplot(forecast(ets(gift_amt), h = 12, PI=FALSE))
autoplot(ets(gift_amt))
summary(ets(gift_amt))

# auto regression
autoregression_gift <- ar(gift_amt)
autoregression_gift

autoplot(forecast(autoregression_gift, level = 0, h = 12))

# arima
autoplot(forecast(Arima(gift_amt, order=c(1,1,1)), h = 12), PI = FALSE)
autoplot(forecast(auto.arima(gift_amt), h = 12), PI = FALSE)

# forecasting
#take 10 years of data (2010 to 2020, test - 2021-2022, validate 2023, app (2024 till today()))
# gift amt vs gift date

# #gift amount forecasting
# 
# df_forecast <- transaction %>%
#   group_by(GIFT_DATE) %>%
#   summarise(Total = sum(GIFT_AMOUNT)) %>%
#   select(GIFT_DATE,Total)
# 
# #=============
# # Forecast Inputs
# #=============
# horizon_info <- c(1:50) #default 14
# frequency_info <- c(7, 12, 52, 365)
# difference_info <- c("Yes","No")
# log_info <- c("Yes","No")
# model_info <- c('auto-arima','auto-exponential','simple-exponential',
#                 'double-exponential','triple-exponential', 'tbat')
# #=============
# 
# 
# #========  
# # forecasting
# #======== 
tabItem(tabName = "forecast",
        sidebarLayout(
          sidebarPanel(width = 3,
                       selectInput("aggregateInput", "Aggregate",
                                   choices = aggregate_info, selected = 'daily'),
                       selectInput("horizonInput", "Horizon",
                                   choices = horizon_info, selected = 14),
                       selectInput("frequencyInput", "Frequency",
                                   choices = frequency_info, selected = 7),
                       sliderInput("traintestInput", "Train/Test Split",
                                   min = 0, max = 1,value = 0.8),
                       selectInput("modelInput", "Models",choices = model_info,
                                   selected = model_info, multiple = TRUE),
                       sliderInput("autoInput", "Auto-regression",
                                   min = 0, max = 100,value = 0),
                       sliderInput("difference2Input", "Difference",
                                   min = 0, max = 52,value = 0),
                       sliderInput("maInput", "Moving Average",
                                   min = 0, max = 100,value = 0),
                       submitButton("Submit")
          ),
          mainPanel(
            h1("Forecasting",style="text-align: center;"),
            tabsetPanel(type = "tabs",
                        tabPanel(h4("Forecast Visualization",style="text-align: center;"),
                                 plotOutput("forecastPlot")),
                        tabPanel(h4("Forecast Results",style="text-align: center;"),
                                 DT::dataTableOutput("forecastOutput")),
                        tabPanel(h4("Forecast Accuracy",style="text-align: center;"),
                                 DT::dataTableOutput("accuracyOutput"))
            )

          )
        )
# ),
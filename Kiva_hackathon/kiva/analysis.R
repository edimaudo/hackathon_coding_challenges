# Clear environment
rm(list = ls())

#=============
# Package Information
#=============
packages <- c('ggplot2', 'corrplot','tidyverse','readxl',
              'shiny','shinydashboard','scales','dplyr','mlbench','caTools',
              'forecast','TTR','xts','lubridate','data.table','timetk',
              'stopwords','tidytext','stringr','reshape2', 
              'textmineR','topicmodels','textclean', 'memoise','qs')
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}
# ==============
# load data
# ==============


loans <- read.csv("loans2.csv")


loans$DISBURSE_TIME <- as.Date(loans$DISBURSE_TIME)
#=============
# fund distribution
#=============

funds_df2 <- loans %>% 
  filter(STATUS %in% c('funded','fundRaising'),COUNTRY_NAME == "Afghanistan") %>%
  group_by(SECTOR_NAME, DISBURSE_TIME) %>%
  dplyr::summarise(TOTAL_FUNDED_AMOUNT = sum(FUNDED_AMOUNT)) %>%
  na.omit() %>%
  select(SECTOR_NAME, DISBURSE_TIME,TOTAL_FUNDED_AMOUNT) 

column_info <- c(sort(unique(funds_df2$SECTOR_NAME)))

funds_df_xts <- funds_df2 %>%
  spread(SECTOR_NAME, value = TOTAL_FUNDED_AMOUNT) %>%
  tk_xts()
funds_df_xts[is.na(funds_df_xts)] <- 0
funds_df2 <- NULL

# mean daily loans
mean_ret <- colMeans(funds_df_xts)

# covariance matrix with annualization
cov_mat <- cov(funds_df_xts) * 252

#simulation of 10000 portfolios
num_port <- 10000
# Creating a matrix to store the weights
all_wts <- matrix(nrow = num_port,ncol = length(column_info))
# Portfolio returns
port_returns <- vector('numeric', length = num_port)
# Portfolio Standard deviation
port_risk <- vector('numeric', length = num_port)
# Portfolio Sharpe Ratio
sharpe_ratio <- vector('numeric', length = num_port)

set.seed(1)
# simulation
for (i in seq_along(port_returns)) {

  wts <- runif(length(column_info))
  wts <- wts/sum(wts)

  # Storing weight in the matrix
  all_wts[i,] <- wts

  # Portfolio returns
  port_ret <- sum(wts * mean_ret)
  port_ret <- ((port_ret + 1)^252) - 1

  # Storing Portfolio Returns values
  port_returns[i] <- port_ret

  # Creating and storing portfolio risk
  port_sd <- sqrt(t(wts) %*% (cov_mat  %*% wts))
  port_risk[i] <- port_sd

  # Creating and storing Portfolio Sharpe Ratios
  # Assuming 0% Risk free rate
  sr <- port_ret/port_sd
  sharpe_ratio[i] <- sr

}

# Storing the values in the table
portfolio_values <- tibble(Return = port_returns,
                           Risk = port_risk,
                           SharpeRatio = sharpe_ratio)

# Converting matrix to a tibble and changing column names
all_wts <- tk_tbl(all_wts)
column_info <- unique(column_info)
colnames(all_wts) <- column_info

# Combing all the values together
portfolio_values <- tk_tbl(cbind(all_wts, portfolio_values))

# Next lets look at the portfolios that matter the most.
# - The minimum variance portfolio
# - The tangency portfolio (the portfolio with highest sharpe ratio)
min_var <- portfolio_values[which.min(portfolio_values$Risk),]
max_sr <- portfolio_values[which.max(portfolio_values$SharpeRatio),]

length_info <- ncol(min_var)-3

p <- min_var %>%
  gather(colnames(min_var)[1:length_info], key = Asset,
         value = Weights) %>%
  mutate(Asset = as.factor(Asset)) %>%
  ggplot(aes(x = fct_reorder(Asset,Weights), y = Weights, fill = Asset)) +
  geom_bar(stat = 'identity') +
  theme_minimal() + coord_flip() + 
  labs(x = 'Assets', y = 'Weights', title = "Minimum Variance Portfolio Weights") +
  scale_y_continuous(labels = scales::percent) 
p

length_info <- ncol(max_sr)-3
p <- max_sr %>%
  gather(colnames(max_sr)[1:length_info], key = Asset,
         value = Weights) %>%
  mutate(Asset = as.factor(Asset)) %>%
  ggplot(aes(x = fct_reorder(Asset,Weights), y = Weights, fill = Asset)) +
  geom_bar(stat = 'identity') + 
  theme_minimal() + coord_flip() + 
  labs(x = 'Assets', y = 'Weights', title = "Tangency Portfolio Weights") +
  scale_y_continuous(labels = scales::percent) 
  p

# p <- portfolio_values %>%
#   ggplot(aes(x = Risk, y = Return, color = SharpeRatio)) +
#   geom_point() +
#   theme_classic() +
#   scale_y_continuous(labels = scales::percent) +
#   scale_x_continuous(labels = scales::percent) +
#   labs(x = 'Annualized Risk',
#        y = 'Annualized Returns',
#        title = "Portfolio Optimization & Efficient Frontier") +
#   geom_point(aes(x = Risk,
#                  y = Return), data = min_var, color = 'red') +
#   geom_point(aes(x = Risk,
#                  y = Return), data = max_sr, color = 'red') +
#   annotate('text', x = 0.20, y = 0.42, label = "Tangency Portfolio") +
#   annotate('text', x = 0.18, y = 0.01, label = "Minimum variance portfolio") +
#   annotate(geom = 'segment', x = 0.14, xend = 0.135,  y = 0.01, 
#            yend = 0.06, color = 'red', arrow = arrow(type = "open")) +
#   annotate(geom = 'segment', x = 0.22, xend = 0.2275,  y = 0.405, 
#            yend = 0.365, color = 'red', arrow = arrow(type = "open"))
# 
# p


#=============
# borrower dashboard
#=============


  # SECTOR COUNT
sector_df <- loans %>%
    filter(STATUS %in% c('funded','fundRaising')) %>%
    dplyr::group_by(SECTOR_NAME) %>%
    dplyr::summarise(count = n()) %>%
    select(SECTOR_NAME, count)
ggplot(sector_df,aes(x=reorder(SECTOR_NAME, count),y=count, fill = SECTOR_NAME)) +
  geom_bar(stat = "identity") + theme_minimal() + scale_y_continuous(labels = comma) +
  coord_flip() + xlab("Sectors") + 
  ylab("Count") + guides(fill = FALSE)
  
# AVG NUM OF LENDERS BY SECTOR
sectors_lender_df <- loans %>%
  filter(STATUS %in% c('funded','fundRaising')) %>%
  dplyr::group_by(SECTOR_NAME) %>%
  dplyr::summarise(AVG_NUM_LENDERS = mean(NUM_LENDERS_TOTAL)) %>%
  select(SECTOR_NAME, AVG_NUM_LENDERS)
  ggplot(data = sectors_lender_df,aes(x=SECTOR_NAME, y=AVG_NUM_LENDERS, fill = SECTOR_NAME)) +
  geom_bar(stat = "identity") + theme_minimal()  + scale_y_continuous(labels = comma) 
  coord_flip() + xlab("Sector Name") + 
    ylab("Average No. of Lenders") + guides(fill = FALSE)

  # AVG LENDER TERM BY SECTOR
  loans$LENDER_TERM[is.na(loans$LENDER_TERM)] <- 0
  sectors_lender_term_df <- loans %>%
    filter(STATUS %in% c('funded','fundRaising')) %>%
    dplyr::group_by(SECTOR_NAME) %>%
    dplyr::summarise(AVG_NUM_LENDERS_TERM = mean(LENDER_TERM)) %>%
    select(SECTOR_NAME, AVG_NUM_LENDERS_TERM)
  ggplot(data = sectors_lender_term_df,aes(x=reorder(SECTOR_NAME,AVG_NUM_LENDERS_TERM), 
                                           y=AVG_NUM_LENDERS_TERM, fill = SECTOR_NAME)) +
    geom_bar(stat = "identity") + theme_minimal() + scale_y_continuous(labels = comma) + 
    coord_flip() + xlab("Sectors") + 
    ylab("Average Lender Term") + guides(fill = FALSE)

  # FUNDED AMOUNT
  sector_funded_amount_df <- loans %>%
    filter(STATUS %in% c('funded','fundRaising')) %>%
    dplyr::group_by(SECTOR_NAME) %>%
    dplyr::summarise(AVG_FUNDED_AMOUNT = mean(FUNDED_AMOUNT)) %>%
    select(SECTOR_NAME, TOTAL_FUNDED_AMOUNT)
  ggplot(sector_funded_amount_df,aes(x=reorder(SECTOR_NAME, TOTAL_FUNDED_AMOUNT),y=TOTAL_FUNDED_AMOUNT, 
                                     fill = SECTOR_NAME)) +
    geom_bar(stat = "identity", width = 0.3) + theme_minimal() + scale_y_continuous(labels = comma) +
    coord_flip() + xlab("Top 5 Sectors") + 
    ylab("AVERAGE FUNDED AMOUNT") + guides(scale = "none")
 
  # Distribution model mix
  distribution_df <- loans %>%
    filter(STATUS %in% c('funded','fundRaising')) %>%
    dplyr::group_by(SECTOR_NAME,DISTRIBUTION_MODEL) %>%
    dplyr::summarise(count = n()) %>%
    select(SECTOR_NAME,DISTRIBUTION_MODEL, count)
  ggplot(distribution_df,aes(x=reorder(SECTOR_NAME, count),y=count, fill = DISTRIBUTION_MODEL)) +
    geom_bar(stat = "identity") + theme_minimal() + scale_y_continuous(labels = comma) +
    coord_flip() + xlab("Sectors") + 
    ylab("Count") + guides(fill=guide_legend(title="Distribution Model"))
  
  # Repayment interval mix 
  repayment_df <- loans %>%
    filter(STATUS %in% c('funded','fundRaising')) %>%
    dplyr::group_by(SECTOR_NAME,REPAYMENT_INTERVAL) %>%
    dplyr::summarise(count = n()) %>%
    select(SECTOR_NAME,REPAYMENT_INTERVAL, count)
  ggplot(repayment_df,aes(x=reorder(SECTOR_NAME, count),y=count, fill = REPAYMENT_INTERVAL)) +
    geom_bar(stat = "identity") + theme_minimal() + scale_y_continuous(labels = comma) +
    coord_flip() + xlab("Sectors") + 
    ylab("Count") + guides(fill=guide_legend(title="Repayment Interval"))
   
  
  
  # Average loan time frame (POSTED_TIME  vs DISBURSE_TIME) by sector
  loans$POSTED_DISBURSED_TIME = as.Date(loans$DISBURSE_TIME) - as.Date(loans$POSTED_TIME)
  loans$POSTED_DISBURSED_TIME[is.na(loans$POSTED_DISBURSED_TIME )] <- 0
  sectors_loan_time_df <- loans %>%
    filter(STATUS %in% c('funded','fundRaising')) %>%
    dplyr::group_by(SECTOR_NAME) %>%
    dplyr::summarise(AVG_POSTED_DISBURSED_TIME = mean(POSTED_DISBURSED_TIME)) %>% 
    select(SECTOR_NAME,AVG_POSTED_DISBURSED_TIME)
  sectors_loan_time_df$AVG_POSTED_DISBURSED_TIME <- -(sectors_loan_time_df$AVG_POSTED_DISBURSED_TIME)

  ggplot(sectors_loan_time_df,aes(x=reorder(SECTOR_NAME, AVG_POSTED_DISBURSED_TIME),
                                  y=AVG_POSTED_DISBURSED_TIME, 
                                  fill = SECTOR_NAME)) +
    geom_bar(stat = "identity") + theme_minimal() + scale_y_continuous(labels = comma) +
    coord_flip() + xlab("Sectors") + 
    ylab("Average Loan disbursment time in days") + guides(scale = "none")
  
  # Funded loans by year heatmap 
  funded_loan_time_df <- loans2 %>%
    filter(STATUS %in% c('funded','fundRaising')) %>%
    mutate(DISBURSED_TIME = lubridate::year(as.Date(DISBURSE_TIME))) %>%
    dplyr::group_by(SECTOR_NAME,DISBURSED_TIME) %>%
    dplyr::summarise(AVG_FUNDED_AMOUNT = mean(FUNDED_AMOUNT)) %>%
    select(SECTOR_NAME,DISBURSED_TIME,AVG_FUNDED_AMOUNT )
  funded_loan_time_df <- na.omit(funded_loan_time_df)
  options(scipen=10000)
  #overall summary
  col1 = "#d8e1cf" 
  col2 = "#438484"
  ggplot(funded_loan_time_df, aes(DISBURSED_TIME, SECTOR_NAME, fill= AVG_FUNDED_AMOUNT)) + 
    geom_tile() + 
    scale_fill_gradient(low = col1, high = col2) +
    guides(fill=guide_legend(title="Avg Funded Amount")) +
    labs(title = "Total Funded Amount",x = "Year", y = "Sector") +
    theme_minimal() + guides(fill=guide_legend(title="Average Funded Amount")) + 
    theme(axis.text.x = element_text(size = 12),
          axis.text.y = element_text(size = 12),
          axis.title.x = element_text(size = 14, face = "bold"),
          axis.title.y = element_text(size = 14, face = "bold"))


#=============
# loan impact
#=============

glimpse(loans)

time_period <- 5
dropoff <- 0.1
discount_rate <- 0.035
reduction_rate <- 0.1

loan_df2 <- loans2 %>%
   filter(STATUS %in%c('funded','fundRaising'), COUNTRY_NAME == "Belize") %>%
   na.omit() %>%
   dplyr::group_by(ACTIVITY_NAME) %>%
   dplyr::summarise(TOTAL_FUNDED_AMOUNT = sum(FUNDED_AMOUNT),
             TOTAL_NUMBER_LENDERS = sum(NUM_LENDERS_TOTAL),
             TOTAL_LENDER_TERM = sum(LENDER_TERM)) %>%
   dplyr::mutate(TOTAL_LENDER_TERM = TOTAL_LENDER_TERM/12) %>%
   select(ACTIVITY_NAME,TOTAL_FUNDED_AMOUNT,TOTAL_NUMBER_LENDERS, TOTAL_LENDER_TERM)

dim(loan_df2)[1] == 0

# calculate reduction per year
# create matrix that is m x n where m is the number of activities and n is the number of years
reduction_data <- matrix(nrow = length(loan_df2$ACTIVITY_NAME),ncol = time_period + 1)
reduction_info <- vector('numeric', length = time_period)

for (i in 1:length(loan_df2$ACTIVITY_NAME)) {
  temp <- c()
  activity_info <- loan_df2$ACTIVITY_NAME[i]
  reduction_info <- c()
  loan_info <- loan_df2$TOTAL_FUNDED_AMOUNT[i]
  
  for (j in 1:time_period){
    if (j != 1) {
      reduction_info[j] <- reduction_info[j-1] * (1 - reduction_rate)
    } else {
      reduction_info[1] <- loan_info
    }
  }
  
  temp <-  c(activity_info,reduction_info)
  reduction_data[i,] <- temp
  
}


# calculate npv
npv_data <- c()

for (i in 2:ncol(reduction_data)){
  temp <- sum(as.numeric(reduction_data[,i]))
  npv_data[i-1] <- temp / ((1 + discount_rate) ^ i)
}

# get total npv - sum of all npv
total_npv <- sum(npv_data)

# investment value is  is average of total funds
investment_value = mean(loan_df2$TOTAL_FUNDED_AMOUNT)

# Social Impact value = total npv - investment value
social_impact_value = total_npv - investment_value 

# SROI = Social Impact Value/Investment value
sroi = social_impact_value / investment_value


# --------------------


## clean up code
## convert to tabsets

## Final test

## Create video and other ancilliary stuff

ggplot(funded_loan_time_df, aes(DISBURSED_TIME, SECTOR_NAME, fill= AVG_FUNDED_AMOUNT)) +
  geom_tile() +
  scale_fill_gradient(col1, col2) +
  guides(fill=guide_legend(title="Average Funded Amount")) +
  labs(x = "Year", y = "Sectors") +
  theme_minimal() + guides(fill=guide_legend(title="Average Funded Amount")) + 
  theme(axis.text.x = element_text(face = "bold", size = 12),
        axis.text.y = element_text(face = "bold", size = 12))
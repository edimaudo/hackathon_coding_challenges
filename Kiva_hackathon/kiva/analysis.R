# Clear environment
rm(list = ls())

#=============
# Package Information
#=============
packages <- c('ggplot2', 'corrplot','tidyverse','readxl',
              'shiny','shinydashboard','scales','dplyr','mlbench','caTools',
              'forecast','TTR','xts','lubridate','data.table','timetk')
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}

loans <- data.table::fread("loans.csv")

column_info <- unique(loans$SECTOR_NAME)

loans %>%
  filter(STATUS == 'funded') %>%
  dplyr::group_by(COUNTRY_NAME) %>%
  dplyr::summarise(count=n()) %>%
  select(COUNTRY_NAME, count) %>%
  arrange(count)
  filter(COUNTRY_NAME=='CANADA') 



#=============
# fund distribution
#=============
funds_df <- loans %>%
  filter(STATUS == 'funded') %>%
  select(FUNDED_AMOUNT, SECTOR_NAME, COUNTRY_NAME,DISBURSE_TIME,LENDER_TERM,REPAYMENT_INTERVAL) %>%
  na.omit()
funds_df$DISBURSE_DATE <- as.Date(funds_df$DISBURSE_TIME)
funds_df$DISBURSE_TIME <- NULL

funds_df2 <- funds_df %>% 
  group_by(SECTOR_NAME, DISBURSE_DATE) %>%
  dplyr::summarise(TOTAL_FUNDED_AMOUNT = sum(FUNDED_AMOUNT)) %>%
  select(SECTOR_NAME, DISBURSE_DATE, TOTAL_FUNDED_AMOUNT)
funds_df <- NULL

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

p <- min_var %>%
  gather(Agriculture:Wholesale, key = Asset,
         value = Weights) %>%
  mutate(Asset = as.factor(Asset)) %>%
  ggplot(aes(x = fct_reorder(Asset,Weights), y = Weights, fill = Asset)) +
  geom_bar(stat = 'identity') +
  theme_minimal() + coord_flip() + 
  labs(x = 'Assets', y = 'Weights', title = "Minimum Variance Portfolio Weights") +
  scale_y_continuous(labels = scales::percent) 
p
p <- max_sr %>%
  gather(column_info, key = Asset,
         value = Weights) %>%
  mutate(Asset = as.factor(Asset)) %>%
  ggplot(aes(x = fct_reorder(Asset,Weights), y = Weights, fill = Asset)) +
  geom_bar(stat = 'identity') + 
  theme_minimal() + coord_flip() + 
  labs(x = 'Assets', y = 'Weights', title = "Tangency Portfolio Weights") +
  scale_y_continuous(labels = scales::percent) 
  

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
# overview of the borrower
#drop down by country
Distribution model mix (pie chart)
Repayment interval mix (pie chart)
gender mix
Average number of NUM_LENDERS_TOTAL 
Average LENDER_TERM 
top 5 and bottom 5 sectors
top 5 and bottom 5 activities
word cloud of LOAN_USE 
word cloud tags
Avergae loan time frame (POSTED_TIME  vs DISBURSE_TIME)


#=============
# loan impact
#=============

glimpse(loans)

# values that will be used
# FUNDED_AMOUNT 
# STATUS
# SECTOR_NAME
# ACTIVITY_NAME 
# LENDER_TERM 
# NUM_LENDERS_TOTAL 
# COUNTRY_NAME
# LOAN_ID 
# time_period<- c(1:25)
# inputs - loan amount
# dropdown will be by sector
# stakeholders - number of lenders
# outcomes - activity names
# generate outcomes for the different activities
# discount rate values

time_period <- 5
dropoff <- 0.1
discount_rate = 0.035



loan_df2 <- loans %>%
  filter(STATUS %in%c('funded','fundRaising')) %>%
  na.omit() %>%
  dplyr::group_by(ACTIVITY_NAME) %>%
  dplyr::summarise(TOTAL_FUNDED_AMOUNT = sum(FUNDED_AMOUNT),
            TOTAL_NUMBER_LENDERS = sum(NUM_LENDERS_TOTAL),
            TOTAL_LENDER_TERM = sum(LENDER_TERM)) %>%
  dplyr::mutate(TOTAL_LENDER_TERM = TOTAL_LENDER_TERM/12) %>%
  select(ACTIVITY_NAME,TOTAL_FUNDED_AMOUNT,TOTAL_NUMBER_LENDERS, TOTAL_LENDER_TERM)

loan_df2$IMPACT <- loan_df2$TOTAL_FUNDED_AMOUNT * loan_df2$TOTAL_NUMBER_LENDERS

# CALCULATE DROP OFF TO GET BENEFITS

# CALCLATE DISCOUNTED VALUES

#GENERATE PRESENT VALUE

# GENERATE NPV

# total input = total present value - net present value

# total present value - total inputs
# SROI total present value / total inputs

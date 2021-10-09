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

# fund distribution
loans_df <- loans %>%
  select(FUNDED_AMOUNT, LOAN_AMOUNT, STATUS, SECTOR_NAME, COUNTRY_NAME, POSTED_TIME, PLANNED_EXPIRATION_TIME,
         DISBURSE_TIME, RAISED_TIME, LENDER_TERM, NUM_LENDERS_TOTAL, REPAYMENT_INTERVAL)
loans_df <- na.omit(loans_df)

funds_df <- loans_df %>%
  filter(STATUS == 'funded') %>%
  select(FUNDED_AMOUNT, SECTOR_NAME, COUNTRY_NAME,DISBURSE_TIME,LENDER_TERM, 
         NUM_LENDERS_TOTAL, REPAYMENT_INTERVAL) 

funds_df$DISBURSE_DATE <- as.Date(funds_df$DISBURSE_TIME)
funds_df$DISBURSE_TIME <- NULL


funds_df2 <- funds_df %>% 
  group_by(SECTOR_NAME, DISBURSE_DATE) %>%
  dplyr::summarise(TOTAL_FUNDED_AMOUNT = sum(FUNDED_AMOUNT)) %>%
  select(SECTOR_NAME, DISBURSE_DATE, TOTAL_FUNDED_AMOUNT)

sector <- c("All",c(sort(unique(funds_df2 $SECTOR_NAME)))) 

#funds_df2$TOTAL_FUNDED_AMOUNT = log(funds_df2$TOTAL_FUNDED_AMOUNT) # convert to log

funds_df_xts <- funds_df2 %>%
  spread(SECTOR_NAME, value = TOTAL_FUNDED_AMOUNT) %>%
  tk_xts()

funds_df_xts[is.na(funds_df_xts)] <- 0

# mean daily loans
mean_ret <- colMeans(funds_df_xts)
print(round(mean_ret, 5))

# covariance matrix with annualization
cov_mat <- cov(funds_df_xts) * 252
print(round(cov_mat,4))


#simulation of 5000 portfolios
num_port <- 5000

# Creating a matrix to store the weights
all_wts <- matrix(nrow = num_port,
                  ncol = length(unique(funds_df$SECTOR_NAME)))

# Creating an empty vector to store
# Portfolio returns
port_returns <- vector('numeric', length = num_port)

# Creating an empty vector to store
# Portfolio Standard deviation

port_risk <- vector('numeric', length = num_port)

# Creating an empty vector to store
# Portfolio Sharpe Ratio
sharpe_ratio <- vector('numeric', length = num_port)

# simulation
for (i in seq_along(port_returns)) {
  
  wts <- runif(length(unique(funds_df$SECTOR_NAME)))
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
column_info <- unique(funds_df2$SECTOR_NAME)
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
  theme_minimal() +
  labs(x = 'Assets', y = 'Weights', title = "Minimum Variance Portfolio Weights") +
  scale_y_continuous(labels = scales::percent) 

p <- max_sr %>%
  gather(column_info, key = Asset,
         value = Weights) %>%
  mutate(Asset = as.factor(Asset)) %>%
  ggplot(aes(x = fct_reorder(Asset,Weights), y = Weights, fill = Asset)) +
  geom_bar(stat = 'identity') + 
  theme_minimal() +
  labs(x = 'Assets', y = 'Weights', title = "Tangency Portfolio Weights") +
  scale_y_continuous(labels = scales::percent) 

p <- portfolio_values %>%
  ggplot(aes(x = Risk, y = Return, color = SharpeRatio)) +
  geom_point() +
  theme_classic() +
  scale_y_continuous(labels = scales::percent) +
  scale_x_continuous(labels = scales::percent) +
  labs(x = 'Annualized Risk',
       y = 'Annualized Returns',
       title = "Portfolio Optimization & Efficient Frontier") +
  geom_point(aes(x = Risk,
                 y = Return), data = min_var, color = 'red') +
  geom_point(aes(x = Risk,
                 y = Return), data = max_sr, color = 'red') +
  annotate('text', x = 0.20, y = 0.42, label = "Tangency Portfolio") +
  annotate('text', x = 0.18, y = 0.01, label = "Minimum variance portfolio") +
  annotate(geom = 'segment', x = 0.14, xend = 0.135,  y = 0.01, 
           yend = 0.06, color = 'red', arrow = arrow(type = "open")) +
  annotate(geom = 'segment', x = 0.22, xend = 0.2275,  y = 0.405, 
           yend = 0.365, color = 'red', arrow = arrow(type = "open"))

p

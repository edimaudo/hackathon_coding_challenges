## Environment cleanup
rm(list = ls())

#####Load Libraries###### 
packages <- c(
  'ggplot2','tidyverse','plotly','leaflet',
  'xts','forecast','TTR','plotly','Metrics',
  'DT','lubridate','prophet'
)
for (package in packages) { 
  if (!require(package, character.only = T, quietly = T)) {
    install.packages(package)
    library(package, character.only = T)
  }
}

# Set working directory to the location of the datasets
setwd("path_to_datasets")  # Replace with your actual path

# Load datasets
actual_consumption <- read.table("Actual_consumption_202301010000_202503050000_Quarterhour.csv",sep=";", header = 1)
actual_generation <- read.table("Actual_generation_202301010000_202503050000_Quarterhour.csv",sep=";",header = 1)
forecasted_consumption <- read.table("Forecasted_consumption_202301010000_202503050000_Quarterhour.csv",sep=";",header = 1)
forecasted_generation <- read.table("Forecasted_generation_Day-Ahead_202301010000_202503050000_Hour_Quarterhour.csv",sep=";",header = 1)
day_ahead_prices <- read.table("Day-ahead_prices_202301010000_202503050000_Hour.csv",sep=";", header = 1)

# Data preprocessing
# Convert time columns to datetime format
actual_consumption <- actual_consumption %>%
  mutate(datetime = lubridate::ymd_hms(Start.date))  # Replace 'datetime_column' with actual column name

actual_generation <- actual_generation %>%
  mutate(datetime = ymd_hms(Start.date))  # Replace 'datetime_column' with actual column name

# Aggregate data to hourly level if necessary
actual_consumption_hourly <- actual_consumption %>%
  mutate(hour = floor_date(datetime, unit = "hour")) %>%
  group_by(hour) %>%
  summarise(consumption = mean(consumption_value))  # Replace 'consumption_value' with actual column name

actual_generation_hourly <- actual_generation %>%
  mutate(hour = floor_date(datetime, unit = "hour")) %>%
  group_by(hour) %>%
  summarise(generation = mean(generation_value))  # Replace 'generation_value' with actual column name

# Merge datasets
data_merged <- actual_consumption_hourly %>%
  inner_join(actual_generation_hourly, by = "hour") %>%
  inner_join(day_ahead_prices %>% rename(hour = datetime_column), by = "hour")  # Replace 'datetime_column' with actual column name

# Feature engineering
data_merged <- data_merged %>%
  mutate(
    net_load = consumption - generation,
    hour_of_day = hour(hour),
    day_of_week = wday(hour, label = TRUE)
  )

# Split data into training and testing sets
train_data <- data_merged %>% filter(hour < as.POSIXct("2024-12-31"))
test_data <- data_merged %>% filter(hour >= as.POSIXct("2025-01-01"))

# Time series forecasting using Prophet
# Prepare data for Prophet
prophet_data <- train_data %>%
  select(ds = hour, y = net_load)

m <- prophet(prophet_data)

# Create future dataframe
future <- make_future_dataframe(m, periods = nrow(test_data), freq = "hour")

# Forecast
forecast <- predict(m, future)

# Merge forecast with actuals
forecast_results <- forecast %>%
  select(ds, yhat) %>%
  inner_join(test_data %>% select(hour, net_load), by = c("ds" = "hour"))

# Evaluation
rmse_value <- rmse(forecast_results$net_load, forecast_results$yhat)
mae_value <- mae(forecast_results$net_load, forecast_results$yhat)

# Print evaluation metrics
print(paste("RMSE:", round(rmse_value, 2)))
print(paste("MAE:", round(mae_value, 2)))

# Visualization
ggplot(forecast_results, aes(x = ds)) +
  geom_line(aes(y = net_load, color = "Actual")) +
  geom_line(aes(y = yhat, color = "Forecast")) +
  labs(title = "Net Load Forecast vs Actual",
       x = "Datetime",
       y = "Net Load (MW)",
       color = "Legend") +
  theme_minimal()
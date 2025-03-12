# Load necessary libraries
library(tidyverse)
library(lubridate)
library(tibbletime)
library(anomalize)
library(ggplot2)
#library(isolationForest) #install.packages("isolationForest")
library(e1071)
library(keras)
library(tensorflow)

# Load the dataset
data <- read.csv("cpu-full-a.csv")

# Convert datetime column to POSIXct
data$datetime <- as.POSIXct(data$datetime, format="%Y-%m-%d %H:%M")

# Visualize the raw time series
ggplot(data, aes(x = datetime, y = cpu)) +
  geom_line() +
  ggtitle("CPU Utilization Over Time") +
  xlab("Datetime") +
  ylab("CPU Usage")

# Anomaly Detection
# Convert data to tibbletime object
data_tbl <- as_tbl_time(data, index = datetime)

# Perform anomaly detection with decomposition
anomalized <- data_tbl %>%
  time_decompose(cpu, method = "stl", frequency = "auto", trend = "auto") %>%
  anomalize(remainder, method = "iqr") %>%
  time_recompose()

# Visualize anomalies
ggplot(anomalized, aes(x = datetime, y = observed)) +
  geom_line(color = "blue") +
  geom_point(aes(y = anomaly, color = ifelse(anomaly == 1, "Anomaly", "Normal")), size = 2) +
  scale_color_manual(values = c("Normal" = "black", "Anomaly" = "red")) +
  ggtitle("Anomaly Detection in CPU Utilization") +
  xlab("Datetime") +
  ylab("CPU Usage")

# Summary of anomalies
anomaly_summary <- anomalized %>% filter(anomaly == 1)
anomaly_summary

# Alternative Anomaly Detection using Isolation Forest
iso_forest <- isolationForest::iForest(data$cpu, ntree = 100)
data$anomaly_score <- predict(iso_forest, data$cpu)

# Define anomaly threshold
data$anomaly_if <- ifelse(data$anomaly_score > quantile(data$anomaly_score, 0.95), "Anomaly", "Normal")

# Visualize Isolation Forest anomalies
ggplot(data, aes(x = datetime, y = cpu, color = anomaly_if)) +
  geom_line() +
  geom_point(size = 2) +
  scale_color_manual(values = c("Normal" = "black", "Anomaly" = "red")) +
  ggtitle("Isolation Forest Anomaly Detection") +
  xlab("Datetime") +
  ylab("CPU Usage")

# Machine Learning-based Anomaly Detection using One-Class SVM
svm_model <- svm(cpu ~ ., data = data, type = "one-classification", kernel = "radial", nu = 0.05)
data$anomaly_svm <- predict(svm_model)
data$anomaly_svm <- ifelse(data$anomaly_svm == -1, "Anomaly", "Normal")

# Visualize SVM Anomalies
ggplot(data, aes(x = datetime, y = cpu, color = anomaly_svm)) +
  geom_line() +
  geom_point(size = 2) +
  scale_color_manual(values = c("Normal" = "black", "Anomaly" = "red")) +
  ggtitle("One-Class SVM Anomaly Detection") +
  xlab("Datetime") +
  ylab("CPU Usage")

# Deep Learning-based Anomaly Detection using Autoencoder
# Normalize data
cpu_values <- as.matrix(data$cpu)
cpu_values <- scale(cpu_values)

# Define Autoencoder model
model <- keras_model_sequential() %>%
  layer_dense(units = 16, activation = "relu", input_shape = ncol(cpu_values)) %>%
  layer_dense(units = 8, activation = "relu") %>%
  layer_dense(units = 16, activation = "relu") %>%
  layer_dense(units = ncol(cpu_values), activation = "linear")

# Compile model
model %>% compile(loss = "mse", optimizer = "adam")

# Train the autoencoder
history <- model %>% fit(cpu_values, cpu_values, epochs = 50, batch_size = 16, validation_split = 0.1, verbose = 0)

# Compute reconstruction error
reconstructed <- model %>% predict(cpu_values)
errors <- rowSums((cpu_values - reconstructed)^2)

# Define anomaly threshold
data$anomaly_ae <- ifelse(errors > quantile(errors, 0.95), "Anomaly", "Normal")

# Visualize Autoencoder anomalies
ggplot(data, aes(x = datetime, y = cpu, color = anomaly_ae)) +
  geom_line() +
  geom_point(size = 2) +
  scale_color_manual(values = c("Normal" = "black", "Anomaly" = "red")) +
  ggtitle("Autoencoder-based Anomaly Detection") +
  xlab("Datetime") +
  ylab("CPU Usage")

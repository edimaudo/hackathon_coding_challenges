# File 2: exploratory_analysis.R

# Load libraries
library(tidyverse)
library(plotly)
library(janitor)

# Community Immunity at Risk
us_coverage <- read_csv("https://raw.githubusercontent.com/fbranda/measles/main/USA/data/all/measles-USA-by-mmr-coverage.csv") %>% clean_names()

below_threshold <- us_coverage %>%
  filter(coverage < 95)

plot_ly(below_threshold, x = ~year, y = ~coverage, color = ~state,
        type = 'scatter', mode = 'lines+markers') %>%
  layout(title = "US States Below 95% MMR Coverage")

# Temporal Trends of Measles Incidence
onset_data <- read_csv("https://raw.githubusercontent.com/fbranda/measles/main/USA/data/all/measles-USA-by-onset-date.csv") %>% clean_names() %>% 
  mutate(date_onset = lubridate::ymd(date_onset))

daily_cases <- onset_data %>% group_by(date_onset) %>% summarise(cases = sum(cases, na.rm = TRUE))

plot_ly(daily_cases, x = ~date_onset, y = ~cases, type = 'scatter', mode = 'lines') %>%
  layout(title = "Daily Measles Cases in the US")

# Vaccination vs. Outcome Correlation
state_timeline <- read_csv("https://raw.githubusercontent.com/fbranda/measles/main/USA/data/2025/measles-USA-by-state-timeline.csv") %>% clean_names()

correlation_data <- us_coverage %>%
  inner_join(state_timeline, by = c("state", "year")) %>%
  select(state, year, coverage, cases)

plot_ly(correlation_data, x = ~coverage, y = ~cases, type = 'scatter', mode = 'markers', color = ~state) %>%
  layout(title = "Coverage vs. Measles Cases by State-Year")

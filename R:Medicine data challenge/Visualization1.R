# Data Visualization

## Environment setup
rm(list = ls())

# Load libraries
library(tidyverse)
library(plotly)
library(janitor)
library(lubridate)

# 1. Global MMR Coverage Line Chart
coverage_global <- read_csv("https://raw.githubusercontent.com/fbranda/measles/main/Measles_vaccination_coverage_Global.csv") %>%
  clean_names()

plot_ly(coverage_global, x = ~year, y = ~coverage, color = ~country,
        type = 'scatter', mode = 'lines') %>%
  layout(title = "Global MMR Coverage Over Time")

# 2. Heatmap of Country-Level MMR by Year
coverage_heatmap <- coverage_global %>%
  filter(!is.na(coverage))

plot_ly(coverage_heatmap, x = ~year, y = ~country, z = ~coverage, 
        type = 'heatmap', colors = 'Blues') %>%
  layout(title = "MMR Coverage Heatmap by Country and Year")

# 3. US State-Level MMR Choropleth
us_coverage <- read_csv("https://raw.githubusercontent.com/fbranda/measles/main/USA/data/all/measles-USA-by-mmr-coverage.csv") %>%
  clean_names()

latest_us_coverage <- us_coverage %>% filter(year == max(year))

plot_ly(latest_us_coverage, locations = ~state, locationmode = 'USA-states',
        z = ~coverage, type = 'choropleth', colorscale = 'Viridis') %>%
  layout(title = "Latest MMR Coverage by US State", geo = list(scope = 'usa'))

# 4. US Measles Onset Timeline
onset_data <- read_csv("https://raw.githubusercontent.com/fbranda/measles/main/USA/data/all/measles-USA-by-onset-date.csv") %>%
  clean_names() %>% mutate(date_onset = ymd(date_onset))

grouped_onset <- onset_data %>% group_by(date_onset) %>% summarise(cases = sum(cases, na.rm = TRUE))

plot_ly(grouped_onset, x = ~date_onset, y = ~cases, type = 'scatter', mode = 'lines') %>%
  layout(title = "US Measles Onset Timeline")

# 5. US Measles by Age
age_data <- read_csv("https://raw.githubusercontent.com/fbranda/measles/main/USA/data/2025/measles-USA-by-age.csv") %>%
  clean_names()

plot_ly(age_data, x = ~age_group, y = ~case_count, type = 'bar') %>%
  layout(title = "Measles Cases by Age Group (2025)")

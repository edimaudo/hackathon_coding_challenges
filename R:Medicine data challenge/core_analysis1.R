# File 3: core_analysis.R

# Load libraries
library(tidyverse)
library(plotly)
library(janitor)
library(lubridate)

# 1. Global and US MMR Coverage Trends
global <- read_csv("https://raw.githubusercontent.com/fbranda/measles/main/Measles_vaccination_coverage_Global.csv") %>% clean_names()
us <- read_csv("https://raw.githubusercontent.com/fbranda/measles/main/USA/data/all/measles-USA-by-mmr-coverage.csv") %>% clean_names()



# 2. Spatiotemporal Spread in US (2025)
state_timeline <- read_csv("https://raw.githubusercontent.com/fbranda/measles/main/USA/data/2025/measles-USA-by-state-timeline.csv") %>% clean_names()

spread_by_state <- state_timeline %>% group_by(state, week) %>% summarise(cases = sum(cases))

plot_ly(spread_by_state, x = ~week, y = ~cases, color = ~state, type = 'scatter', mode = 'lines') %>%
  layout(title = "Weekly Measles Cases by State (2025)")

# 3. Coverage vs. Cases Correlation
joined <- inner_join(us, state_timeline, by = c("state", "year"))

plot_ly(joined, x = ~coverage, y = ~cases, color = ~state, type = 'scatter', mode = 'markers') %>%
  layout(title = "MMR Coverage vs. Measles Cases")

# 4. Outcome Severity by Age
age_data <- read_csv("https://raw.githubusercontent.com/fbranda/measles/main/USA/data/2025/measles-USA-by-age.csv") %>% clean_names()

plot_ly(age_data, x = ~age_group, y = ~cases, type = 'bar') %>%
  layout(title = "Measles Cases by Age Group (2025)")

# 5. Complications and Fatality Trends
yearly <- read_csv("https://raw.githubusercontent.com/fbranda/measles/main/USA/data/all/measles-USA-by-year.csv") %>% clean_names()

plot_ly(yearly, x = ~year, y = ~cases, name = "Cases", type = 'scatter', mode = 'lines') %>%
  add_trace(y = ~complications, name = "Complications") %>%
  add_trace(y = ~deaths, name = "Deaths") %>%
  layout(title = "Measles Burden Over Time")

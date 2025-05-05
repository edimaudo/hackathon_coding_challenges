# 03_core_analysis.R
# Purpose: Synthesize findings to address the core analysis objectives

# --- Load Libraries ---
library(plotly)
library(dplyr)
library(readr)
library(lubridate)
library(tidyr)
library(janitor)
library(scales)

# --- Helper Function & Data Loading (Same as previous scripts) ---
load_data <- function(url) {
  tryCatch(
    {
      df <- read_csv(url, show_col_types = FALSE) %>% janitor::clean_names()
      message("Successfully loaded and cleaned data from: ", basename(url))
      return(df)
    }, error = function(e) {
      message("Failed to load data from: ", url); message("Error: ", e$message); return(NULL)
    })
}
base_url <- "https://raw.githubusercontent.com/fbranda/measles/main/"
urls <- list(
  global_coverage = paste0(base_url, "Measles_vaccination_coverage_Global.csv"),
  global_cases = paste0(base_url, "Measles_Global.csv"),
  # europe_cases = paste0(base_url, "Measles_Europe.csv"), # Load if needed for comparison
  us_coverage_cases = paste0(base_url, "USA/data/all/measles-USA-by-mmr-coverage.csv"),
  # us_onset = paste0(base_url, "USA/data/all/measles-USA-by-onset-date.csv"), # Load if needed
  us_year = paste0(base_url, "USA/data/all/measles-USA-by-year.csv"),
  us_age_2025 = paste0(base_url, "USA/data/2025/measles-USA-by-age.csv"),
  # us_county_2025 = paste0(base_url, "USA/data/2025/measles-USA-by-county-timeline.csv"), # Load if needed
  us_state_2025 = paste0(base_url, "USA/data/2025/measles-USA-by-state-timeline.csv"),
  us_confirmed_2025 = paste0(base_url, "USA/data/2025/measles-USA-confirmed-cases.csv") # Load if needed
)
data <- lapply(urls, load_data)


# =============================================================================
# Core Analysis Objectives
# =============================================================================
# Combine visualizations and analyses to answer key questions.

# --- Core Analysis 1: The Weakening Shield ---
# Link declining US coverage to rising incidence.
message("\n--- Core Analysis 1: The Weakening Shield ---")
if (!is.null(data$us_coverage_cases) && !is.null(data$us_year)) {
  
  # Plot 1: Long-term US Cases (Highlighting resurgence)
  if (all(c("year", "cases") %in% names(data$us_year))) {
    p_us_trend <- plot_ly(data$us_year, x = ~year, y = ~cases, type = 'scatter', mode = 'lines+markers') %>%
      layout(title = "US Measles Cases Over Time")
    print(p_us_trend)
  }
  
  # Plot 2: Coverage vs Incidence Scatter Plot (Highlighting <95% and recent years)
  if (all(c("state", "year", "mmr", "cases", "population") %in% names(data$us_coverage_cases))) {
    us_plot_data <- data$us_coverage_cases %>%
      filter(!is.na(mmr) & !is.na(cases) & !is.na(population) & population > 0) %>%
      mutate(
        mmr_coverage_pct = ifelse(mmr <= 1, mmr * 100, mmr),
        cases_per_100k = (cases / population) * 100000,
        period = ifelse(year >= 2010, "2010-Present", "Pre-2010") # Example periods
      )
    
    p_scatter_core <- plot_ly(us_plot_data, x = ~mmr_coverage_pct, y = ~cases_per_100k,
                              type = 'scatter', mode = 'markers',
                              color = ~period, # Color by time period
                              text = ~paste("State:", state, "<br>Year:", year, "<br>MMR:", round(mmr_coverage_pct,1),"%<br>Cases/100k:", round(cases_per_100k,2)),
                              hoverinfo = 'text') %>%
      layout(title = "US Cases/100k vs MMR Coverage (Highlighting Recent Years)",
             xaxis = list(title="MMR Coverage (%)"), yaxis=list(title="Cases per 100k")) %>%
      add_segments(x = 95, xend = 95, y = 0, yend = ~max(us_plot_data$cases_per_100k, na.rm = TRUE),
                   inherit = FALSE, line = list(color = 'red', dash = 'dash'), name = "95% Threshold")
    print(p_scatter_core)
    
    # Correlation for recent period
    correlation_recent <- cor(us_plot_data$mmr_coverage_pct[us_plot_data$period == "2010-Present"],
                              us_plot_data$cases_per_100k[us_plot_data$period == "2010-Present"],
                              use = "complete.obs")
    message(paste("Correlation (Coverage vs Cases/100k) for 2010-Present:", round(correlation_recent, 3)))
  }
} else { message("Skipping Core Analysis 1: Missing required US data.")}


# --- Core Analysis 2: The 2025 US Measles Landscape ---
# Snapshot of 2025 geography, demographics, timeline.
message("\n--- Core Analysis 2: The 2025 US Measles Landscape ---")
if (!is.null(data$us_state_2025) && !is.null(data$us_age_2025)) {
  
  # Plot 1: State Timelines for 2025 (from viz script)
  if (all(c("state", "date", "cumulative_cases") %in% names(data$us_state_2025))) {
    # Regenerate or reuse p9_1 from viz script
    state_data_2025 <- data$us_state_2025 %>% mutate(date = as.Date(date))
    top_states_2025 <- state_data_2025 %>% group_by(state) %>% filter(date == max(date)) %>% ungroup() %>% arrange(desc(cumulative_cases)) %>% slice_head(n = 10) %>% pull(state)
    p_state_2025 <- plot_ly(state_data_2025 %>% filter(state %in% top_states_2025),
                            x = ~date, y = ~cumulative_cases, color = ~state,
                            type = 'scatter', mode = 'lines') %>%
      layout(title = "2025 Cumulative Measles Cases by State (Top 10)")
    print(p_state_2025)
  }
  
  # Plot 2: Age Distribution 2025 (from viz script)
  if (all(c("age_group", "cases") %in% names(data$us_age_2025))) {
    # Regenerate or reuse p7_1 from viz script
    p_age_2025 <- plot_ly(data$us_age_2025, x = ~age_group, y = ~cases, type = 'bar') %>%
      layout(title = "2025 Age Distribution of US Measles Cases")
    print(p_age_2025)
  }
  
  # Summary stats for 2025
  if (!is.null(data$us_confirmed_2025)) {
    total_cases_2025 <- sum(data$us_age_2025$cases, na.rm = TRUE) # Assuming us_age sums correctly
    message(paste("\nTotal confirmed cases reported in 2025 (via age dataset):", total_cases_2025))
    # Add more detailed summary from us_confirmed_2025 if needed and available
    # print(summary(data$us_confirmed_2025))
  }
  
  # County Map outline - requires significant geospatial work
  message("County-level map visualization requires FIPS codes and geospatial data integration.")
  
} else
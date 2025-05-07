# 02_exploratory_analysis.R
# Purpose: Conduct exploratory data analysis (EDA) using visualizations and summaries

# --- Load Libraries ---
library(plotly)
library(dplyr)
library(readr)
library(lubridate)
library(tidyr)
library(janitor)
library(scales)
# library(DT) # Keep if you want tables in this script too

# --- Helper Function & Data Loading (Same as 01_data_visualization.R) ---
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
  europe_cases = paste0(base_url, "Measles_Europe.csv"),
  us_coverage_cases = paste0(base_url, "USA/data/all/measles-USA-by-mmr-coverage.csv"),
  us_onset = paste0(base_url, "USA/data/all/measles-USA-by-onset-date.csv"),
  us_year = paste0(base_url, "USA/data/all/measles-USA-by-year.csv"),
  us_age_2025 = paste0(base_url, "USA/data/2025/measles-USA-by-age.csv"),
  us_county_2025 = paste0(base_url, "USA/data/2025/measles-USA-by-county-timeline.csv"),
  us_state_2025 = paste0(base_url, "USA/data/2025/measles-USA-by-state-timeline.csv"),
  us_confirmed_2025 = paste0(base_url, "USA/data/2025/measles-USA-confirmed-cases.csv")
)
data <- lapply(urls, load_data)


# =============================================================================
# Exploratory Analysis Sections
# =============================================================================
# Combining visualizations with summary statistics or specific filtering

# --- EDA 1: Global and Regional Coverage Trends ---
message("\n--- EDA 1: Summary Coverage Trends ---")


  
  # Add summary stats
  latest_year_global_cov <- max(coverage_summary$year, na.rm = TRUE)
  coverage_stats <- coverage_summary %>%
    filter(year == latest_year_global_cov) %>%
    summarise(Min = min(avg_coverage), Mean = mean(avg_coverage), Max = max(avg_coverage))
  message(paste("Summary Coverage Stats for", latest_year_global_cov, ":"))
  print(coverage_stats)
  
  # Regions below a threshold (e.g., 90%) in the latest year
  regions_below_90 <- coverage_summary %>%
    filter(year == latest_year_global_cov & avg_coverage < 90) %>%
    arrange(avg_coverage)
  message(paste("\nRegions with <90% Avg MCV1 Coverage in", latest_year_global_cov, ":"))
  print(regions_below_90)
  



# --- EDA 2: Global Measles Incidence Trends & Hotspots ---
message("\n--- EDA 2: Global Incidence Trends ---")
if (!is.null(data$global_cases) && all(c("country", "year", "cases") %in% names(data$global_cases))) {
  # Reuse global cases line plot
  global_cases_summary <- data$global_cases %>%
    group_by(year) %>%
    summarise(total_cases = sum(cases, na.rm = TRUE), .groups = 'drop')
  p2_1 <- plot_ly(global_cases_summary, x = ~year, y = ~total_cases, type = 'scatter', mode = 'lines+markers') %>%
    layout(title = "Total Reported Global Measles Cases")
  print(p2_1)
  
  # Reuse top N countries bar chart
  latest_year_global_cases <- max(data$global_cases$year, na.rm = TRUE)
  top_countries <- data$global_cases %>%
    filter(year == latest_year_global_cases, !is.na(cases)) %>%
    arrange(desc(cases)) %>%
    slice_head(n = 15)
  p2_2 <- plot_ly(top_countries, x = ~cases, y = ~reorder(country, cases), type = 'bar', orientation = 'h') %>%
    layout(title = paste("Top 15 Countries by Measles Cases", latest_year_global_cases))
  print(p2_2)
  
  # Identify countries with recent large increases (requires population data for rates)
  message("Further hotspot analysis would ideally use cases per capita.")
  
} else { message("Skipping EDA 2: Missing data or columns.")}


# --- EDA 3: European Measles Outbreak Patterns ---
message("\n--- EDA 3: European Patterns ---")
# Reuse plots from visualization script (e.g., heatmap)
if (!is.null(data$europe_cases) && all(c("country", "year", "cases") %in% names(data$europe_cases))) {
  # european_heatmap_plot (from viz script)
  # print(european_heatmap_plot)
  message("European analysis: Look for specific years/countries with high cases in the heatmap.")
} else { message("Skipping EDA 3: Missing data or columns.")}


# --- EDA 4: Correlation between US MMR Coverage and Incidence ---
message("\n--- EDA 4: US Coverage vs Incidence Correlation ---")
if (!is.null(data$us_coverage_cases) && all(c("state", "year", "mmr", "cases", "population") %in% names(data$us_coverage_cases))) {
  # Reuse scatter plot
  us_plot_data <- data$us_coverage_cases %>%
    filter(!is.na(mmr) & !is.na(cases) & !is.na(population) & population > 0) %>%
    mutate(
      mmr_coverage_pct = ifelse(mmr <= 1, mmr * 100, mmr),
      cases_per_100k = (cases / population) * 100000
    )
  # p4_1 (scatter plot from viz script)
  # print(p4_1)
  message("Visual correlation check: Observe the trend in the scatter plot (fig-us-coverage-vs-cases).")
  
  # Calculate overall correlation (use with caution - ecological fallacy)
  correlation <- cor(us_plot_data$mmr_coverage_pct, us_plot_data$cases_per_100k, use = "complete.obs", method = "pearson") # Or spearman
  message(paste("Overall Pearson correlation between MMR Coverage (%) and Cases/100k:", round(correlation, 3)))
  
  # Analyze states frequently below 95% threshold
  states_below_95 <- us_plot_data %>%
    filter(mmr_coverage_pct < 95) %>%
    group_by(state) %>%
    summarise(years_below_95 = n(), avg_cases_when_below = mean(cases_per_100k, na.rm = TRUE)) %>%
    arrange(desc(years_below_95))
  message("\nStates with most years below 95% MMR Coverage:")
  print(head(states_below_95))
  
} else { message("Skipping EDA 4: Missing data or columns.")}


# --- EDA 5: Temporal Clustering / US Outbreak Dynamics ---
message("\n--- EDA 5: US Temporal Clustering ---")
if (!is.null(data$us_onset) && "onset_date" %in% names(data$us_onset)) {
  # Reuse histogram/density plot for specific years
  # p5_1 (histogram from viz script)
  # print(p5_1)
  message("Temporal clustering: Look for peaks in the histogram of onset dates for outbreak years.")
} else { message("Skipping EDA 5: Missing data or columns.")}


# --- EDA 6: Long-Term US Measles Incidence Trend Analysis ---
message("\n--- EDA 6: Long-Term US Trend ---")
if (!is.null(data$us_year) && all(c("year", "cases") %in% names(data$us_year))) {
  # Reuse line plot
  # p6_2 (line plot from viz script)
  # print(p6_2)
  message("Long term trend: Note the sharp decline post-vaccine, elimination period (~2000), and recent resurgence years.")
  # Highlight specific years
  elimination_year <- 2000
  recent_outbreak_years <- c(2014, 2019) # Example
  # Add annotations or segments to the plot if desired
} else { message("Skipping EDA 6: Missing data or columns.")}


# --- EDA 7: Age Distribution of 2025 US Measles Cases ---
message("\n--- EDA 7: 2025 US Age Distribution ---")
if (!is.null(data$us_age_2025) && all(c("age_group", "cases") %in% names(data$us_age_2025))) {
  # Reuse bar chart
  # p7_1 (age bar chart from viz script)
  # print(p7_1)
  message("2025 Age Distribution: Identify the most affected age groups.")
  # Calculate summary statistics if age is numeric or can be estimated
  # e.g. median age group, proportion unvaccinated (if status available)
} else { message("Skipping EDA 7: Missing data or columns.")}


# --- EDA 8: Geospatial Spread Analysis at County Level (2025) ---
message("\n--- EDA 8: 2025 US County Spread ---")
if (!is.null(data$us_county_2025)) {
  # Reuse small multiples plot
  # p8_1 (small multiples from viz script)
  # print(p8_1)
  message("County Spread: Identify counties with highest cumulative counts and fastest growth rates.")
  # Add map outlines here if feasible
} else { message("Skipping EDA 8: Missing data.")}


# --- EDA 9: State-Level Comparison of 2025 Measles Activity ---
message("\n--- EDA 9: 2025 US State Comparison ---")
if (!is.null(data$us_state_2025)) {
  # Reuse state comparison line plot
  # p9_1 (state line plot from viz script)
  # print(p9_1)
  message("State comparison: Compare slopes and final cumulative numbers for different states.")
  # Add state choropleth outline if feasible
} else { message("Skipping EDA 9: Missing data.")}


# --- EDA 10: Descriptive Epidemiology of 2025 US Cases ---
message("\n--- EDA 10: 2025 US Case Description ---")
if (!is.null(data$us_confirmed_2025)) {
  # Reuse DT table
  # print(p10_1) # DT table from viz script
  # Reuse summary stats
  message("Summary Statistics for 2025 confirmed cases:")
  print(summary(data$us_confirmed_2025))
  # Add more specific summaries if columns permit (e.g., case fatality rate if deaths recorded)
} else { message("Skipping EDA 10: Missing data.")}


message("\n--- Exploratory Analysis Script Finished ---")
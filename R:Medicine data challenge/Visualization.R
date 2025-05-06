# Data Visualization

## Environment setup
rm(list = ls())

###### Libraries ######
# Ensure these are installed: install.packages(c("plotly", "dplyr", "readr", "lubridate", "tidyr", "janitor", "scales", "DT"))
packages <- c("plotly", "dplyr", "readr", "lubridate", "tidyr", "janitor", "scales", "DT")
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}

###### Data ######

## Data load helper
load_data <- function(url) {
  tryCatch(
    {
      df <- read_csv(url, show_col_types = FALSE) %>%
        janitor::clean_names() # Standardize column names
      message("Successfully loaded and cleaned data from: ", basename(url))
      return(df)
    },
    error = function(e) {
      message("Failed to load data from: ", url)
      message("Error: ", e$message)
      return(NULL)
    }
  )
}

# --- Data URLs ---
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

#----Load Data----
data <- lapply(urls, load_data)

###### Visualization #####
#----Global Measles Vaccination Coverage----
if (!is.null(data$global_coverage)) {
  
  if (all(c("region", "year", "antigen") %in% names(data$global_coverage))) {
    coverage_summary <- data$global_coverage %>%
      filter(!is.na(antigen) & !is.na(region)) %>%
      group_by(region, year) %>%
      summarise(avg_coverage = mean(coverage, na.rm = TRUE), .groups = 'drop')
    
    p1_1 <- plot_ly(coverage_summary, x = ~year, y = ~avg_coverage, color = ~region,
                    type = 'scatter', mode = 'lines+markers',
                    text = ~paste("Region:", region, "<br>Year:", year, "<br>Coverage:", round(avg_coverage, 1), "%"),
                    hoverinfo = 'text') %>%
      layout(title = "Avg Coverage by WHO Region", yaxis = list(range = c(0,100), title="Avg Coverage (%)"))
    print(p1_1)
  } else { message("Required columns (region, year, antigen) not found in global_coverage.")}
  
}

#----- Global Measles Cases ----
# Pivot data
data$global_cases_update <- data$global_cases %>% 
  pivot_longer(
    cols = !c(region,iso3,country, year), 
    names_to = "month", 
    values_to = "cases"
  )

if (!is.null(data$global_cases_update)) {
  
  # Example: Line plot of total global cases
  # Assumes columns: year, cases
  if (all(c("year", "cases") %in% names(data$global_cases_update))) {
    global_cases_summary <- data$global_cases_update %>%
      group_by(year) %>%
      summarise(total_cases = sum(cases, na.rm = TRUE), .groups = 'drop')
    
    p2_1 <- plot_ly(global_cases_summary, x = ~year, y = ~total_cases,
                    type = 'scatter', mode = 'lines+markers',
                    text = ~paste("Year:", year, "<br>Total Cases:", scales::comma(total_cases)),
                    hoverinfo = 'text') %>%
      layout(title = "Total Reported Global Measles Cases", yaxis = list(title="Total Cases")) # Consider type='log' for yaxis if range is huge
    print(p2_1)
  } else { message("Required columns (year, cases) not found in global_cases.")}
  
  # Example: Bar chart of top N countries by cases in the latest year
  # Assumes columns: country, year, cases
  # if (all(c("country", "year", "cases") %in% names(data$global_cases_update))) {
  #   latest_year <- max(data$global_cases_update$year, na.rm = TRUE)-1 # no data in 2024
  #   top_countries <- data$global_cases_update %>%
  #     filter(year == latest_year , !is.na(cases)) %>%
  #     arrange(desc(cases)) %>%
  #     slice_head(n = 15)
  #   
  #   p2_2 <- plot_ly(top_countries, x = ~cases, y = ~reorder(country, cases), type = 'bar', orientation = 'h',
  #                   text = ~paste(country, "<br>Cases:"),
  #                   hoverinfo = 'text') %>%
  #     layout(title = paste("Top 15 Countries by Measles Cases", latest_year),
  #            yaxis = list(title = ""), xaxis = list(title = "Reported Cases"))
  #   print(p2_2)
  # } else { message("Required columns (country, year, cases) not found in global_cases.")}
  
}

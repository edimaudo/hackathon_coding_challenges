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

#-----Global Measles Cases----
# Pivot data
data$global_cases_update <- data$global_cases %>% 
  pivot_longer(
    cols = !c(region,iso3,country, year), 
    names_to = "month", 
    values_to = "cases"
  )

if (!is.null(data$global_cases_update)) {
  
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
  
}


#-----European Measles cases----
if (!is.null(data$europe_cases)) {
  if (all(c("region_name", "time", "num_value") %in% names(data$europe_cases))) {
    europe_heatmap_data <- data$europe_cases %>% filter (indicator == 'Reported confirmed cases', 
                                                         !region_name %in% c('EU/EEA (without UK)','EU/EEA (with UK until 2019)'))
      
    
    p3_1 <- plot_ly(europe_heatmap_data, x = ~time, y = ~region_name, z = ~num_value,
                    type = "heatmap", colorscale = "Viridis", # Choose a colorscale
                    hoverinfo = 'text',
                    text = ~paste("Country:", region_name, "<br>Year:", time, "<br>Cases:", num_value)) %>%
      layout(title = "Measles Cases Heatmap in Europe",
             xaxis = list(title = "Year", type = "category"), # Treat year as category for heatmap
             yaxis = list(title = "Country", type = "category"))
    print(p3_1)
  } else { message("Required columns (country, year, cases) not found in europe_cases.")}
}

#-----US Measles Cases by year-----
if (!is.null(data$us_year)) {
  
  if (all(c("year", "cases") %in% names(data$us_year))) {
    p6_2 <- plot_ly(data$us_year, x = ~year, y = ~cases, type = 'scatter', mode = 'lines+markers',
                    text = ~paste("Year:", year, "<br>Cases:", scales::comma(cases)),
                    hoverinfo = 'text') %>%
      layout(title = "Total Reported US Measles Cases by Year",
             xaxis = list(title = "Year"), yaxis = list(title = "Number of Cases"))
    print(p6_2)
  } else { message("Required columns (year, cases) not found in us_year.")}
}

#-----2025 measles cases by age group----
if (!is.null(data$us_age_2025)) {
  
  if (all(c("age_group", "cases") %in% names(data$us_age_2025))) {
    age_levels <- c("< 5", "5_19", "> 20", "Unknown") # Adjust as per data
    data$us_age_2025$age_group <- factor(data$us_age_2025$age_group, levels = age_levels)
    
    p7_1 <- plot_ly(data$us_age_2025, x = ~age_group, y = ~case_count, type = 'bar',
                    text = ~paste("Age Group:", age_group, "<br>Cases:", case_count),
                    hoverinfo = 'text') %>%
      layout(title = "Age Distribution of US Measles Cases, 2025",
             xaxis = list(title = "Age Group" , categoryorder = "array", categoryarray = ~levels(age_group) # Use if factor
             ),
             yaxis = list(title = "Number of Cases"))
    print(p7_1)
    
  } else { message("Required columns (age_group, cases) not found in us_age_2025.")}
}

#-----2025 Measles Cases by US Counties top 10-----
if (!is.null(data$us_county_2025)) {
  if (all(c("county_name", "state_name", "report_date", "cases_count") %in% names(data$us_county_2025))) {
    county_data <- data$us_county_2025 %>%
      mutate(date = as.Date(report_date),
             county_state = paste(county_name, state_name, sep=", ")) # Unique identifier
    
    # Find top N counties by cases
    top_counties <- county_data %>%
      group_by(county_name) %>%
      filter(date == max(date)) %>%
      ungroup() %>%
      arrange(desc(cases_count)) %>%
      slice_head(n = 10) %>%
      pull(county_name)
    
    
    p8_1 <- plot_ly(county_data %>% filter(county_name %in% top_counties),
                    x = ~date, y = ~cases_count, color = ~county_name,
                    type = 'scatter', mode = 'lines',
                    text = ~paste("County:", county_name, "<br>Date:", date, "<br>Cases:", cases_count),
                    hoverinfo = 'text') %>%
      layout(title = "Measles Cases by County, 2025 (Top 10 Counties)",
             xaxis = list(title = "Date"), yaxis = list(title = "Cases"))
    print(p8_1)
    
  } else { message("Required columns (county, state, date, cumulative_cases) not found in us_county_2025.")}
}

#-----2025 Measles cases by state top 10-----
if (!is.null(data$us_state_2025)) {
  
  if (all(c("state", "report_date", "cases_count") %in% names(data$us_state_2025))) {
    state_data <- data$us_state_2025 %>% mutate(date = as.Date(report_date))
    
    # Identify states with significant cases
    top_states <- state_data %>%
      group_by(state_name) %>%
      filter(date == max(date)) %>%
      ungroup() %>%
      arrange(desc(cases_count)) %>%
      slice_head(n = 10) %>% # Adjust N
      pull(state_name)
    
    p9_1 <- plot_ly(state_data %>% filter(state_name %in% top_states),
                    x = ~date, y = ~cases_count, color = ~state_name,
                    type = 'scatter', mode = 'lines',
                    text = ~paste("State:", state_name, "<br>Date:", date, "<br>Cases:", cases_count),
                    hoverinfo = 'text') %>%
      layout(title = "Measles Cases by State, 2025 (Top 10 States)",
             xaxis = list(title = "Date"), yaxis = list(title = "Cases"))
    print(p9_1)
  } else { message("Required columns (state, date, case count) not found in us_state_2025.")}
  
  
}
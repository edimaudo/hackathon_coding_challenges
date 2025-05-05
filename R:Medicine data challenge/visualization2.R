# 01_data_visualization.R
# Purpose: Generate individual visualizations for each dataset using plotly

# --- Load Libraries ---
# Ensure these are installed: install.packages(c("plotly", "dplyr", "readr", "lubridate", "tidyr", "janitor", "scales", "DT"))
library(plotly)
library(dplyr)
library(readr)
library(lubridate)
library(tidyr)
library(janitor)
library(scales)
library(DT)       # For interactive tables

# --- Helper Function for Data Loading ---
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

# --- Load Data ---
# Replace with local paths if needed. Check names(data) after loading.
data <- lapply(urls, load_data)

# =============================================================================
# Data Visualization Examples (Using Plotly)
# =============================================================================
# IMPORTANT: Check column names in `names(data$dataset_name)` and adjust code below!

# --- 1. Measles_vaccination_coverage_Global.csv ---
if (!is.null(data$global_coverage)) {
  
  # Example: Line plot of MCV1 coverage by WHO region
  # Assumes columns: who_region, year, mcv1
  if (all(c("who_region", "year", "mcv1") %in% names(data$global_coverage))) {
    coverage_summary <- data$global_coverage %>%
      filter(!is.na(mcv1) & !is.na(who_region)) %>%
      group_by(who_region, year) %>%
      summarise(avg_coverage = mean(mcv1, na.rm = TRUE), .groups = 'drop')
    
    p1_1 <- plot_ly(coverage_summary, x = ~year, y = ~avg_coverage, color = ~who_region,
                    type = 'scatter', mode = 'lines+markers',
                    text = ~paste("Region:", who_region, "<br>Year:", year, "<br>Coverage:", round(avg_coverage, 1), "%"),
                    hoverinfo = 'text') %>%
      layout(title = "Avg MCV1 Coverage by WHO Region", yaxis = list(range = c(0,100), title="Avg Coverage (%)"))
    print(p1_1)
  } else { message("Required columns (who_region, year, mcv1) not found in global_coverage.")}
  
  # Example: Choropleth map outline (requires country codes like ISO3)
  # Assumes columns: country, iso_code, year, mcv1
  # message("Choropleth requires geospatial data/codes (e.g., ISO3) linked to countries.")
  # if (all(c("iso_code", "year", "mcv1") %in% names(data$global_coverage))) {
  #   latest_year_coverage <- data$global_coverage %>% filter(year == max(year, na.rm=TRUE))
  #   # p_map <- plot_ly(latest_year_coverage, type='choropleth', locations=~iso_code, z=~mcv1, ...)
  #   # print(p_map)
  # }
}

# --- 2. Measles_Global.csv ---
if (!is.null(data$global_cases)) {
  
  # Example: Line plot of total global cases
  # Assumes columns: year, cases
  if (all(c("year", "cases") %in% names(data$global_cases))) {
    global_cases_summary <- data$global_cases %>%
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
  if (all(c("country", "year", "cases") %in% names(data$global_cases))) {
    latest_year <- max(data$global_cases$year, na.rm = TRUE)
    top_countries <- data$global_cases %>%
      filter(year == latest_year, !is.na(cases)) %>%
      arrange(desc(cases)) %>%
      slice_head(n = 15)
    
    p2_2 <- plot_ly(top_countries, x = ~cases, y = ~reorder(country, cases), type = 'bar', orientation = 'h',
                    text = ~paste(country, "<br>Cases:", scales::comma(cases)),
                    hoverinfo = 'text') %>%
      layout(title = paste("Top 15 Countries by Measles Cases", latest_year),
             yaxis = list(title = ""), xaxis = list(title = "Reported Cases"))
    print(p2_2)
  } else { message("Required columns (country, year, cases) not found in global_cases.")}
  
  # Choropleth outline similar to coverage map
  # message("Choropleth map for cases per capita requires population data linkage.")
}

# --- 3. Measles_Europe.csv ---
# Similar plots as Global, but filtered for European countries if dataset is specific
if (!is.null(data$europe_cases)) {
  # Example: Heatmap of cases by country and year (if data structure allows)
  # Assumes columns: country, year, cases
  if (all(c("country", "year", "cases") %in% names(data$europe_cases))) {
    # Optional: Filter for specific countries if needed
    # europe_heatmap_data <- data$europe_cases %>% filter(country %in% c("Germany", "France", "UK", ...))
    europe_heatmap_data <- data$europe_cases # Use all countries in the dataset
    
    p3_1 <- plot_ly(europe_heatmap_data, x = ~year, y = ~country, z = ~cases,
                    type = "heatmap", colorscale = "Viridis", # Choose a colorscale
                    hoverinfo = 'text',
                    text = ~paste("Country:", country, "<br>Year:", year, "<br>Cases:", cases)) %>%
      layout(title = "Measles Cases Heatmap in Europe",
             xaxis = list(title = "Year", type = "category"), # Treat year as category for heatmap
             yaxis = list(title = "Country", type = "category"))
    print(p3_1)
  } else { message("Required columns (country, year, cases) not found in europe_cases.")}
}


# --- 4. measles-USA-by-mmr-coverage.csv ---
if (!is.null(data$us_coverage_cases)) {
  
  # Example: Scatter plot of cases/100k vs MMR coverage
  # Assumes columns: state, year, mmr (as fraction or %), cases, population
  # Check if 'mmr' is percentage or fraction and adjust calculation if needed
  if (all(c("state", "year", "mmr", "cases", "population") %in% names(data$us_coverage_cases))) {
    us_plot_data <- data$us_coverage_cases %>%
      filter(!is.na(mmr) & !is.na(cases) & !is.na(population) & population > 0) %>%
      mutate(
        mmr_coverage_pct = ifelse(mmr <= 1, mmr * 100, mmr), # Assuming mmr might be fraction or percent
        cases_per_100k = (cases / population) * 100000
      )
    
    p4_1 <- plot_ly(us_plot_data, x = ~mmr_coverage_pct, y = ~cases_per_100k,
                    type = 'scatter', mode = 'markers',
                    color = ~year, # Color by year
                    size = ~population, # Optional sizing
                    text = ~paste("State:", state, "<br>Year:", year,
                                  "<br>MMR Cov:", round(mmr_coverage_pct, 1), "%",
                                  "<br>Cases/100k:", round(cases_per_100k, 2)),
                    hoverinfo = 'text') %>%
      layout(title = "US Measles Incidence vs. MMR Coverage by State",
             xaxis = list(title = "MMR Coverage (%)", range=c(70, 100)),
             yaxis = list(title = "Measles Cases per 100k Pop.")) %>%
      add_segments(x = 95, xend = 95, y = 0, yend = ~max(us_plot_data$cases_per_100k, na.rm = TRUE),
                   inherit = FALSE, # Important!
                   line = list(color = 'red', dash = 'dash'),
                   name = "95% Threshold", showlegend = TRUE)
    print(p4_1)
    
    # Example: Connected scatter plot (State trajectories)
    # Choose a few states to avoid overplotting
    states_to_plot <- c("California", "Texas", "New York", "Ohio", "Washington") # Example
    p4_2 <- plot_ly(us_plot_data %>% filter(state %in% states_to_plot),
                    x = ~mmr_coverage_pct, y = ~cases_per_100k,
                    type = 'scatter', mode = 'lines+markers',
                    color = ~state,
                    text = ~paste("State:", state, "<br>Year:", year,
                                  "<br>MMR Cov:", round(mmr_coverage_pct, 1), "%",
                                  "<br>Cases/100k:", round(cases_per_100k, 2)),
                    hoverinfo = 'text') %>%
      layout(title = "State Trajectories: Cases vs. Coverage Over Time",
             xaxis = list(title = "MMR Coverage (%)", range=c(70, 100)),
             yaxis = list(title = "Measles Cases per 100k Pop."),
             showlegend = TRUE) %>%
      add_segments(x = 95, xend = 95, y = 0, yend = ~max(us_plot_data$cases_per_100k[us_plot_data$state %in% states_to_plot], na.rm = TRUE),
                   inherit = FALSE, line = list(color = 'red', dash = 'dash'),
                   name = "95% Threshold", showlegend = FALSE) # Hide redundant legend
    print(p4_2)
    
  } else { message("Required columns (state, year, mmr, cases, population) not found in us_coverage_cases.")}
  
  # Dual Axis plot is complex and often discouraged for clarity. Consider two separate plots or faceting.
}

# --- 5. measles-USA-by-onset-date.csv ---
if (!is.null(data$us_onset)) {
  
  # Example: Histogram of cases by onset date for a specific period/outbreak
  # Assumes columns: onset_date, potentially state/county
  if ("onset_date" %in% names(data$us_onset)) {
    onset_data <- data$us_onset %>%
      mutate(onset_date = as.Date(onset_date)) %>% # Ensure date format
      filter(year(onset_date) == 2019) # Example: Filter for a specific outbreak year
    
    p5_1 <- plot_ly(onset_data, x = ~onset_date, type = 'histogram',
                    xbins = list(size = "D1")) %>% # Bin by day
      layout(title = "Distribution of US Measles Cases by Onset Date (Example Year 2019)",
             xaxis = list(title = "Onset Date"),
             yaxis = list(title = "Number of Cases"))
    print(p5_1)
    
    # Detailed timeline plot (Plotly alone is tricky, often better with ggplot+geom_point/segment then ggplotly)
    message("Detailed timeline plot is often better generated with ggplot2 and converted with ggplotly().")
    
    # Calendar Heatmap (requires specific libraries like calendR or custom ggplot + plotly)
    message("Calendar Heatmap requires specific packages (e.g., calendR) or advanced ggplot2 techniques.")
    
  } else { message("Required column (onset_date) not found in us_onset.")}
}

# --- 6. measles-USA-by-year.csv ---
if (!is.null(data$us_year)) {
  
  # Example: Bar chart of total US cases per year
  # Assumes columns: year, cases
  if (all(c("year", "cases") %in% names(data$us_year))) {
    p6_1 <- plot_ly(data$us_year, x = ~year, y = ~cases, type = 'bar',
                    text = ~paste("Year:", year, "<br>Cases:", scales::comma(cases)),
                    hoverinfo = 'text') %>%
      layout(title = "Total Reported US Measles Cases by Year",
             xaxis = list(title = "Year"), yaxis = list(title = "Number of Cases"))
    print(p6_1)
    
    # Example: Line plot version
    p6_2 <- plot_ly(data$us_year, x = ~year, y = ~cases, type = 'scatter', mode = 'lines+markers',
                    text = ~paste("Year:", year, "<br>Cases:", scales::comma(cases)),
                    hoverinfo = 'text') %>%
      layout(title = "Total Reported US Measles Cases by Year (Trend)",
             xaxis = list(title = "Year"), yaxis = list(title = "Number of Cases"))
    print(p6_2)
  } else { message("Required columns (year, cases) not found in us_year.")}
}

# --- 7. measles-USA-by-age.csv (2025 data) ---
if (!is.null(data$us_age_2025)) {
  
  # Example: Bar chart of age distribution
  # Assumes columns: age_group, cases (or count)
  if (all(c("age_group", "cases") %in% names(data$us_age_2025))) {
    # Optional: Define logical order for age groups if needed
    # age_levels <- c("<1yr", "1-4yr", "5-17yr", "18-49yr", "50+yr") # Adjust as per data
    # data$us_age_2025$age_group <- factor(data$us_age_2025$age_group, levels = age_levels)
    
    p7_1 <- plot_ly(data$us_age_2025, x = ~age_group, y = ~cases, type = 'bar',
                    text = ~paste("Age Group:", age_group, "<br>Cases:", cases),
                    hoverinfo = 'text') %>%
      layout(title = "Age Distribution of US Measles Cases, 2025",
             xaxis = list(title = "Age Group" #, categoryorder = "array", categoryarray = ~levels(age_group) # Use if factor
             ),
             yaxis = list(title = "Number of Cases"))
    print(p7_1)
    
    # Example: Stacked bar chart (if vaccination status per age group is available)
    # Assumes columns: age_group, vaccination_status, cases
    # if (all(c("age_group", "vaccination_status", "cases") %in% names(data$us_age_2025))) {
    #   p7_2 <- plot_ly(data$us_age_2025, x = ~age_group, y = ~cases, color = ~vaccination_status, type = 'bar') %>%
    #     layout(title = "Cases by Age Group and Vaccination Status, 2025", barmode = 'stack')
    #   print(p7_2)
    # }
  } else { message("Required columns (age_group, cases) not found in us_age_2025.")}
}

# --- 8. measles-USA-by-county-timeline.csv (2025 data) ---
if (!is.null(data$us_county_2025)) {
  # Choropleth maps require county FIPS codes or similar IDs linked to GeoJSON/shapefiles.
  message("County Choropleth maps require FIPS codes and geospatial data.")
  # Example: Small multiples line plot for top N counties
  # Assumes columns: county, state, date, cumulative_cases
  if (all(c("county", "state", "date", "cumulative_cases") %in% names(data$us_county_2025))) {
    county_data <- data$us_county_2025 %>%
      mutate(date = as.Date(date),
             county_state = paste(county, state, sep=", ")) # Unique identifier
    
    # Find top N counties by latest cumulative cases
    top_counties <- county_data %>%
      group_by(county_state) %>%
      filter(date == max(date)) %>%
      ungroup() %>%
      arrange(desc(cumulative_cases)) %>%
      slice_head(n = 9) %>% # Example: top 9 for a 3x3 grid
      pull(county_state)
    
    county_plot_data <- county_data %>% filter(county_state %in% top_counties)
    
    # Create individual plots and combine with subplot
    plot_list <- lapply(top_counties, function(cs) {
      df_sub <- county_plot_data %>% filter(county_state == cs)
      plot_ly(df_sub, x = ~date, y = ~cumulative_cases, type='scatter', mode='lines', name = cs) %>%
        layout(title = cs, showlegend = FALSE,
               xaxis=list(title=""), yaxis=list(title="Cumul. Cases"))
    })
    # Need to handle potential empty plots if a county had no data after filter
    plot_list <- Filter(Negate(is.null), plot_list) 
    if (length(plot_list) > 0) {
      p8_1 <- subplot(plot_list, nrows = ceiling(length(plot_list)/3), shareX=TRUE, shareY=TRUE, titleX=FALSE, titleY=TRUE) %>%
        layout(title = "Cumulative Cases Timeline for Top Counties, 2025")
      print(p8_1)
    }
    
  } else { message("Required columns (county, state, date, cumulative_cases) not found in us_county_2025.")}
}


# --- 9. measles-USA-by-state-timeline.csv (2025 data) ---
if (!is.null(data$us_state_2025)) {
  
  # Example: Line plot comparing state cumulative cases
  # Assumes columns: state, date, cumulative_cases
  if (all(c("state", "date", "cumulative_cases") %in% names(data$us_state_2025))) {
    state_data <- data$us_state_2025 %>% mutate(date = as.Date(date))
    
    # Identify states with significant cases
    top_states <- state_data %>%
      group_by(state) %>%
      filter(date == max(date)) %>%
      ungroup() %>%
      arrange(desc(cumulative_cases)) %>%
      slice_head(n = 10) %>% # Adjust N
      pull(state)
    
    p9_1 <- plot_ly(state_data %>% filter(state %in% top_states),
                    x = ~date, y = ~cumulative_cases, color = ~state,
                    type = 'scatter', mode = 'lines',
                    text = ~paste("State:", state, "<br>Date:", date, "<br>Cases:", cumulative_cases),
                    hoverinfo = 'text') %>%
      layout(title = "Cumulative Measles Cases by State, 2025 (Top 10 States)",
             xaxis = list(title = "Date"), yaxis = list(title = "Cumulative Cases"))
    print(p9_1)
  } else { message("Required columns (state, date, cumulative_cases) not found in us_state_2025.")}
  
  # State choropleth outline (requires state names/abbreviations matching plotly's expectations or FIPS codes)
  message("State choropleth map requires state identifiers matching Plotly's locationmode or geospatial data.")
  # Example using 'USA-states' locationmode
  # if ("state" %in% names(state_data)) {
  #   state_latest <- state_data %>% group_by(state) %>% filter(date == max(date)) %>% ungroup()
  #   p_map_state <- plot_ly(state_latest, type = 'choropleth', locationmode = 'USA-states',
  #                        locations = ~state, z = ~cumulative_cases, colorbar = list(title = "Cases")) %>%
  #                    layout(geo = list(scope = 'usa'), title = "Cumulative Cases by State - Latest Date")
  #   # print(p_map_state) # Uncomment to try
  # }
}


# --- 10. measles-USA-confirmed-cases.csv (2025 data) ---
if (!is.null(data$us_confirmed_2025)) {
  
  # Example: Interactive Table using DT
  # Select relevant columns, assumes case_id, onset_date, age_group, state, county etc. exist
  if(nrow(data$us_confirmed_2025) > 0) {
    # Select a subset of columns for display
    cols_to_display <- intersect(names(data$us_confirmed_2025),
                                 c("case_id", "onset_date", "report_date", "age_group", "state", "county")) # Adjust column names
    if (length(cols_to_display) > 0) {
      p10_1 <- DT::datatable(data$us_confirmed_2025[, cols_to_display, drop = FALSE],
                             options = list(pageLength = 5, scrollX = TRUE),
                             caption = "Table: Details of Confirmed US Measles Cases, 2025 (Sample)")
      print(p10_1) # In RStudio Viewer or rendered document
    } else { message("No suitable columns found for the confirmed cases table.")}
  }
  
  # Example: Summary Statistics Table (printed to console)
  # Requires columns like age (numeric), potentially hospitalization status etc.
  message("Summary Statistics for confirmed cases:")
  print(summary(data$us_confirmed_2025)) # Basic summary
  
  # Advanced summary requires specific columns (e.g., numeric age, hospitalization)
  # Example: if ("age" %in% names(data$us_confirmed_2025)) {
  #   print(data$us_confirmed_2025 %>% summarise( N = n(), MedianAge = median(age, na.rm=TRUE), ...) )
  # }
  
  # Map (requires detailed location like county/zip + geocoding or lat/lon)
  message("Mapping individual cases requires geocoded locations (lat/lon) or joinable county/zip data.")
  
}

message("--- Data Visualization Script Finished ---")
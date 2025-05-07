



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
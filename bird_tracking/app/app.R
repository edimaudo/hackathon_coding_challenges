library(shiny)
library(bslib)
library(plotly)
library(readr)
library(dplyr)
library(lubridate)
library(ggplot2)
library(leaflet) # Add leaflet library
library(tidyr)

# Define UI for the application
ui <- page_navbar(
  title = "Park Bird Tracker",
  theme = bslib::bs_theme(bootswatch = "cerulean"),
  # Add custom CSS for improved spacing and centering
  tags$head(
    tags$style(HTML("
      h2 {
        margin-top: 3rem;
        margin-bottom: 1rem;
      }
      h3 {
        text-align: center;
        margin-top: 3rem;
        margin-bottom: 1rem;
      }
      .container-lg {
        margin-top: 2rem;
        margin-bottom: 2rem;
      }
    "))
  ),
  nav_panel("About",
            div(class = "container-lg",
                h1("About This App"),
                p("This interactive Shiny application visualizes bird tracking data from the National Park Service (NPS) Ermen Streamside Bird Protocol. It is designed to tell a data-driven story across three main themes: the temporal patterns of the morning chorus, the spatial relationships of bird detections, and the taxonomic diversity of the community."),
                p("The app is based on a comprehensive data analysis of the NPS_ERMN_StreamsideBirdProtocol.csv file, combining insights from a narrative outline and a visualization script. Each section contains detailed visualizations with accompanying explanations, allowing users to explore the data and understand the key findings.")
            )
  ),
  nav_panel("The May Symphony",
            div(class = "container-lg",
                h2("The May Symphony - Tracking Bird Songs Through the Morning"),
                p("This part explores the dynamic patterns of bird vocalizations throughout the morning, highlighting how different species create a coordinated 'symphony' at different times. The visualizations show how morning chorus patterns provide insights into species behavior and ecosystem health."),
                
                selectizeInput("park_selector", "Filter by Park:", choices = NULL, options = list(placeholder = 'All Parks', onInitialize = I('function() { this.setValue(""); }'))),
                
                h3("Bird Activity Timeline"),
                p("An interactive timeline showing bird detection frequency by minute."),
                plotlyOutput("timeline_plot"),
                
                h3("Species Vocal Pattern Analysis"),
                p("A heat map of bird activity by minute across species, highlighting species that sing continuously vs. intermittently."),
                plotlyOutput("heatmap_plot"),
                
                h3("Cumulative Species Richness Over Time"),
                p("This visualization shows how the number of unique bird species detected increases over the 10-minute observation period."),
                plotlyOutput("species_richness_plot")
            )
  ),
  nav_panel("Proximity Patterns",
            div(class = "container-lg",
                h2("Proximity Patterns - Detecting Birds Across Distances"),
                p("This story examines how environmental factors and species-specific traits influence the distance at which birds are detected, providing insights into the observation methodology and species' habits."),
                
                h3("Distance Proportions Visualizations"),
                p("A stacked bar chart that shows the proportion of detections within each distance band for different species."),
                plotlyOutput("stacked_bar_plot"),
                
                h3("Species Range Analysis"),
                p("A scatter plot showing species richness versus average detection distance."),
                plotlyOutput("species_range_plot"),
                
                h3("Road Noise and Bird Presence"),
                p("This box plot shows the relationship between detection distance and road noise, an important narrative element."),
                plotlyOutput("noise_distance_plot")
            )
  ),
  nav_panel("Taxonomic Tales",
            div(class = "container-lg",
                h2("Taxonomic Tales - Diversity and Ecological Relationships"),
                p("This section delves into the taxonomic diversity of the bird community, showcasing the relationships between different bird families and their ecological roles within the national parks."),
                
                h3("Taxonomic Hierarchy Explorer"),
                p("An interactive sunburst chart showing the Order → Family → Genus → Species relationships."),
                plotlyOutput("sunburst_plot"),
                
                h3("Bird Family Composition Dashboard"),
                p("A bar chart showing the proportional representation of bird families."),
                plotlyOutput("family_abundance_plot"),
                
                h3("Habitat Suitability and Predictive Hotspots"),
                p("This map visualizes hotspots of bird activity and incorporates the Hemlock Condition Score to show habitat conditions."),
                p("Click on a marker to see more details about the site."),
                leafletOutput("hotspot_map_plot") # Change to leafletOutput
            )
  )
)

# Define server logic
server <- function(input, output, session) {
  # Load the dataset
  # Assuming the CSV is located in a 'data' folder
  df <- read_csv("NPS_ERMN_StreamsideBirdProtocol.csv")
  
  # Clean column names and data types as needed
  names(df) <- make.names(names(df))
  df$Start_Time <- parse_date_time(df$Start_Time, "HMSp")
  df$Year <- as.factor(df$Year)
  df$Distance_Band <- factor(df$Distance_Band, levels = c("≤ 50 m", "51-75 m", "> 75 m"))
  
  # Clean the Minute columns from character to logical
  for(i in 1:10) {
    col_name <- paste0("Minute_", i)
    df[[col_name]] <- as.logical(df[[col_name]])
  }
  
  # Populate the park dropdown with unique park names
  observe({
    park_names <- unique(df$Park_Name)
    updateSelectizeInput(session, "park_selector", choices = c("All Parks" = "", sort(park_names)))
  })
  
  # Reactive expression for filtered data
  filtered_df <- reactive({
    if (is.null(input$park_selector) || input$park_selector == "") {
      df
    } else {
      df %>% filter(Park_Name == input$park_selector)
    }
  })
  
  # --- Story 1 Visualizations ---
  output$timeline_plot <- renderPlotly({
    req(filtered_df())
    local_df <- filtered_df()
    
    minute_cols <- paste0("Minute_", 1:10)
    minute_data <- lapply(1:10, function(i) {
      col <- minute_cols[i]
      detections <- sum(local_df[[col]] == TRUE, na.rm = TRUE)
      songs <- sum(local_df[[col]] == TRUE & local_df$Detection_Type == 'S', na.rm = TRUE)
      calls <- sum(local_df[[col]] == TRUE & local_df$Detection_Type == 'C', na.rm = TRUE)
      data.frame(Minute = i, Detections = detections, Songs = songs, Calls = calls)
    })
    minute_df <- bind_rows(minute_data)
    
    plot_ly(minute_df, x = ~Minute, y = ~Detections, type = 'scatter', mode = 'lines+markers',
            hoverinfo = 'text',
            text = ~paste('Minute', Minute, ': ', Detections, ' Detections<br>Songs: ', Songs, '<br>Calls: ', Calls),
            line = list(color = 'rgb(31, 119, 180)', width = 2)) %>%
      layout(title = "Bird Detection Frequency by Minute",
             xaxis = list(title = "Minute of Observation"),
             yaxis = list(title = "Number of Detections"))
  })
  
  output$heatmap_plot <- renderPlotly({
    req(filtered_df())
    local_df <- filtered_df()
    
    top_species <- local_df %>% 
      count(Common_Name) %>% 
      arrange(desc(n)) %>% 
      slice_head(n = 15) %>% 
      pull(Common_Name)
    
    df_top_species <- local_df %>% filter(Common_Name %in% top_species)
    
    heatmap_data <- data.frame()
    for(species in top_species) {
      species_row <- df_top_species %>%
        filter(Common_Name == species) %>%
        select(starts_with("Minute")) %>%
        mutate(across(everything(), ~ as.numeric(.))) %>%
        summarise(across(everything(), sum, na.rm = TRUE))
      
      names(species_row) <- paste("Minute", 1:10)
      species_row$Species <- species
      heatmap_data <- bind_rows(heatmap_data, species_row)
    }
    
    heatmap_data_long <- heatmap_data %>%
      tidyr::pivot_longer(cols = starts_with("Minute"), names_to = "Minute", values_to = "Detections") %>%
      mutate(Minute = as.numeric(gsub("Minute ", "", Minute))) %>%
      mutate(Species = factor(Species, levels = rev(top_species)))
    
    plot_ly(data = heatmap_data_long, 
            x = ~Minute, 
            y = ~Species, 
            z = ~Detections, 
            type = "heatmap") %>%
      layout(title = "Bird Vocal Activity Heatmap by Minute and Species",
             xaxis = list(title = "Minute of Observation"),
             yaxis = list(title = "Species", categoryorder = "trace"))
  })
  
  output$species_richness_plot <- renderPlotly({
    req(filtered_df())
    local_df <- filtered_df()
    
    # Calculate cumulative species richness over the 10-minute period
    species_richness <- data.frame(Minute = 1:10, Cumulative_Species = NA)
    unique_species <- character()
    
    for (i in 1:10) {
      minute_col <- paste0("Minute_", i)
      new_detections <- local_df %>% filter(.data[[minute_col]] == TRUE)
      new_species <- unique(new_detections$Common_Name)
      
      unique_species <- unique(c(unique_species, new_species))
      species_richness$Cumulative_Species[i] <- length(unique_species)
    }
    
    # Create the line plot
    plot_ly(species_richness, x = ~Minute, y = ~Cumulative_Species, type = 'scatter', mode = 'lines+markers',
            hoverinfo = 'text',
            text = ~paste('Minute:', Minute, '<br>Cumulative Species:', Cumulative_Species)) %>%
      layout(title = "Cumulative Species Richness Over Time",
             xaxis = list(title = "Minute of Observation"),
             yaxis = list(title = "Cumulative Number of Unique Species"))
  })
  
  # --- Story 2 Visualizations ---
  output$stacked_bar_plot <- renderPlotly({
    if(all(c("Distance_Band", "Common_Name") %in% names(df))) {
      distance_species_counts <- df %>% count(Distance_Band, Common_Name)
      plot_ly(distance_species_counts, x = ~Common_Name, y = ~n, color = ~Distance_Band, type = 'bar') %>%
        layout(title = 'Detections by Species and Distance Band',
               xaxis = list(title = 'Species'),
               yaxis = list(title = 'Number of Detections', barmode = 'stack'),
               legend = list(title = list(text = "Distance Band")))
    }
  })
  
  output$species_range_plot <- renderPlotly({
    if(all(c("Distance_Band", "Common_Name") %in% names(df))) {
      distance_map <- c('≤ 50 m' = 1, '51-75 m' = 2, '> 75 m' = 3)
      df$Distance_Numerical <- distance_map[df$Distance_Band]
      avg_distance <- df %>%
        group_by(Common_Name) %>%
        summarise(Avg_Distance = mean(Distance_Numerical, na.rm = TRUE))
      species_richness <- df %>%
        group_by(Common_Name) %>%
        summarise(Richness = n())
      scatter_data <- left_join(avg_distance, species_richness, by = "Common_Name")
      
      plot_ly(scatter_data, x = ~Avg_Distance, y = ~Richness, type = 'scatter', mode = 'markers',
              text = ~Common_Name,
              hoverinfo = 'text',
              marker = list(size = 10)) %>%
        layout(title = 'Species Richness vs. Average Detection Distance',
               xaxis = list(title = 'Average Detection Distance (Numerical)'),
               yaxis = list(title = 'Number of Detections'))
    }
  })
  
  output$noise_distance_plot <- renderPlotly({
    if(all(c("Distance_Band", "Road_Noise") %in% names(df))) {
      plot_ly(df, x = ~Distance_Band, y = ~Road_Noise, type = 'box',
              color = ~Distance_Band) %>%
        layout(title = 'Road Noise Levels by Detection Distance Band',
               xaxis = list(title = 'Detection Distance Band'),
               yaxis = list(title = 'Road Noise Level (dB)'))
    }
  })
  
  # --- Story 3 Visualizations ---
  output$sunburst_plot <- renderPlotly({
    if(all(c("Order", "Family", "Genus", "Species_Code") %in% names(df))) {
      taxonomic_df <- df %>%
        group_by(Order, Family, Genus, Species_Code) %>%
        count() %>%
        ungroup() %>%
        rename(Count = n)
      
      plot_ly(
        taxonomic_df, 
        ids = ~Species_Code,
        labels = ~Species_Code,
        parents = ~Genus,
        values = ~Count,
        type = "sunburst"
      ) %>%
        layout(title = 'Taxonomic Hierarchy of Detected Birds')
    }
  })
  
  output$family_abundance_plot <- renderPlotly({
    if("Family" %in% names(df)) {
      family_counts <- df %>% count(Family)
      plot_ly(family_counts, x = ~Family, y = ~n, type = 'bar',
              marker = list(color = toRGB("steelblue"))) %>%
        layout(title = 'Bird Family Abundance',
               xaxis = list(title = 'Family'),
               yaxis = list(title = 'Detections'))
    }
  })
  
  output$hotspot_map_plot <- renderLeaflet({
    if(all(c("Latitude", "Longitude", "Hemlock_Condition_Score", "Site_Name") %in% names(df))) {
      site_summary <- df %>%
        group_by(Latitude, Longitude, Hemlock_Condition_Score, Site_Name) %>%
        count() %>%
        rename(Total_Detections = n)
      
      pal <- colorNumeric(palette = "YlOrRd", domain = site_summary$Hemlock_Condition_Score)
      
      leaflet(data = site_summary) %>%
        addTiles() %>%
        addCircleMarkers(
          lng = ~Longitude,
          lat = ~Latitude,
          radius = ~log(Total_Detections) * 5,
          color = ~pal(Hemlock_Condition_Score),
          stroke = FALSE,
          fillOpacity = 0.8,
          popup = ~paste(
            "<b>Site:</b>", Site_Name, "<br>",
            "<b>Total Detections:</b>", Total_Detections, "<br>",
            "<b>Hemlock Condition Score:</b>", Hemlock_Condition_Score
          )
        ) %>%
        addLegend(pal = pal, values = ~Hemlock_Condition_Score, title = "Hemlock Score")
    }
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

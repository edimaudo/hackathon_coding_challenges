##### Feedback
# - update the mapping the 
# - can change the color scheme for the different charts
# - make numbers bigger for valuebox
# add ability to compare
# add better chart spacing
# help icon about the chart

################################


# Shiny web app for 
# 2025 City of Rochester Open Data Challenge
################################
rm(list = ls())
################  Packages ################
library(ggplot2)
library(corrplot)
library(tidyverse)
library(shiny)
library(shinydashboard)
library(mlbench)
library(caTools)
library(gridExtra)
library(doParallel)
library(grid)
library(reshape2)
library(caret)
library(tidyr)
library(Matrix)
library(lubridate)
library(plotly)
library(RColorBrewer)
library(data.table)
library(scales)
library(rfm)
library(forecast)
library(TTR)
library(xts)
library(dplyr)
library(treemapify)
library(shinycssloaders)
library(bslib)
library(readxl)
library(htmltools)
library(markdown)
library(scales)
library(leaflet)
library(stringr)

# packages <- c(
#   'ggplot2', 'corrplot','tidyverse','shiny','shinydashboard','shinycssloaders',
#   'bslib','readxl','DT','mlbench','caTools','gridExtra','doParallel','grid',
#   'reshape2','caret','tidyr','Matrix','lubridate','plotly','RColorBrewer','stringr',
#   'data.table','scales','rfm','forecast','TTR','xts','dplyr', 'treemapify','leaflet'
# )
# for (package in packages) {
#   if (!require(package, character.only=T, quietly=T)) {
#     install.packages(package)
#     library(package, character.only=T)
#   }
# }
################ Load Data ################
parks <- read_csv("Parks_and_Playgrounds.csv")
tree <- read_csv("Trees.csv")
tree_address <- read_csv("Trees_address.csv")

################ Data Setup ################
tree$new_inv_date <- lubridate::year(as.Date(tree$INV_DATE, format =  "%Y/%m/%d"))
tree$DBH_VAL_update <- as.numeric(str_remove_all(tree$DBH_VAL, "[\"']"))

tree_temp <- inner_join(tree, tree_address,by="PARKS_VAL") %>%
  select(FULLADDR,GENUS,SPECIES,TREE_NAME_VAL,THEME_VAL,MAINT_VAL,AREA_VAL,
         DBH_VAL_update,NSC_AREA_VAL,new_inv_date) %>%
  na.omit() %>%
  unique()

tree_df <- inner_join(tree_temp,parks,by="FULLADDR",relationship = "many-to-many") %>%
  select(FULLADDR,NAME,PHONE,AGENCYURL,EMAIL,Longitude,Latitude,
         GENUS,SPECIES,TREE_NAME_VAL,THEME_VAL,MAINT_VAL,AREA_VAL,DBH_VAL_update,NSC_AREA_VAL,new_inv_date) %>%
  na.omit() %>%
  unique()

park_list <- c(sort(unique(tree_df$NAME)))

################ UI ################
ui <- dashboardPage(
  dashboardHeader(title = "Open Data Challenge 2025",
                  tags$li(a(href = 'https://data.cityofrochester.gov',
                  img(src = 'https://www.arcgis.com/sharing/rest/content/items/273dc226904e43f0a83baecf54a31397/resources/logo.png?v=1754582471296',
                                title = "Home", height = "30px"),
                            style = "padding-top:10px; padding-bottom:10px;"),
                          class = "dropdown")),
  dashboardSidebar(
    sidebarMenu(
      menuItem("About", tabName = "about", icon = icon("house")),
      menuItem("Park Overview", tabName = "park_overview", icon = icon("th")),
      menuItem("Park Insights", tabName = "park_insight", icon = icon("thumbs-up"))
      
    )
  ),
  dashboardBody(
    tabItems(
      ######### About #########
      tabItem(tabName = "about",includeMarkdown("about.md"),hr()), 
      ######### Overview ######### 
       tabItem(tabName = "park_overview",
                 mainPanel(width = 12,
                           fluidRow(
                             column(width = 12,
                                    valueBoxOutput("parkValueBox"),
                                    valueBoxOutput("speciesValueBox"),
                                    valueBoxOutput("genusValueBox"),
                                    valueBoxOutput("treeNameValueBox"),
                                    valueBoxOutput("treeSizeValueBox"),
                                    valueBoxOutput("treeMaintenanceValueBox")
                             )
                           ),
                          br(),br(),
                          tabsetPanel(type = "tabs",
                                      tabPanel(h4("City of Rochester Park Map",style="text-align: center;"),
                                               leafletOutput("parkOverviewMap", width = 'auto',height="300px")
                                      ),
                                      tabPanel(h4("Tree Characteristics",style="text-align: center;"),
                                               layout_column_wrap(width = 1/2,
                                                  plotlyOutput("genusOverviewPlot") %>% withSpinner(),
                                                  plotlyOutput("speciesOverviewPlot") %>% withSpinner()
                                                  
                                               ),br(),
                                               layout_column_wrap(width = 1/2,
                                                 plotlyOutput("dbhgenusOverviewPlot") %>% withSpinner(),
                                                 plotlyOutput("treeNameOverviewPlot") %>% withSpinner()
                                               ), br(),
                                               layout_column_wrap(width = 1/2,
                                                  plotlyOutput("dbhAgeProfileOverviewPlot") %>% withSpinner(),
                                                  plotlyOutput("dbhOverviewHistogramPlot") %>% withSpinner()
                                               )
                                      ),
                                      tabPanel(h4("Inventory",style="text-align: center;"),
                                               plotlyOutput("inventoryOverviewPlot") %>% withSpinner()
                                      ),
                                      tabPanel(h4("Maintenance",style="text-align: center;"),
                                               layout_column_wrap(width = 1/2,
                                               plotlyOutput("maintenanceOverviewPlot") %>% withSpinner(),
                                               plotlyOutput("maintenanceNSCOverviewPlot") %>% withSpinner()
                                               )
                                      ),
                          ),
                          
                 )
               ),
      ######### Insights ######### 
      tabItem(tabName = "park_insight",
              sidebarLayout(
                sidebarPanel(width = 2,
                             selectInput("parkInput", "Parks", 
                                         choices = park_list, selected = park_list[0], multiple = FALSE),
                             submitButton("Submit")
                ),
                mainPanel(width = 10,
                  fluidRow(
                    column(width = 12,
                           valueBoxOutput("parkValueInsightValueBox"),
                           valueBoxOutput("speciesInsightValueBox"),
                           valueBoxOutput("genusInsightValueBox"),
                           valueBoxOutput("treeNameInsightValueBox"),
                           valueBoxOutput("treeSizeInsightValueBox"),
                           valueBoxOutput("treeMaintenanceInsightValueBox")
                  
                    )
                  ),
                  br(),br(),
                  tabsetPanel(type = "tabs",
                              tabPanel(h4("Park Map",style="text-align: center;"),
                                       leafletOutput("parkInsightMap", width = 'auto',height="300px")
                              ),
                              tabPanel(h4("Tree Characteristics",style="text-align: center;"),
                                       layout_column_wrap(width = 1/2,
                                                          plotlyOutput("genusInsightPlot"),
                                                          plotlyOutput("speciesInsightPlot")
                                                          
                                       ),
                                       layout_column_wrap(width = 1/2,
                                                          plotlyOutput("dbhgenusInsightPlot"),
                                                          plotlyOutput("treeNameInsightPlot")
                                       ), 
                                       layout_column_wrap(width = 1/2,
                                                          plotlyOutput("dbhAgeProfileInsightPlot"),
                                                          plotlyOutput("dbhOverviewHistogramInsightPlot")
                                       )
                                       
                              ),
                              
                              tabPanel(h4("Inventory",style="text-align: center;"),
                                       plotlyOutput("inventoryInsightPlot")
                              ),
                              tabPanel(h4("Maintenance",style="text-align: center;"),
                                       layout_column_wrap(width = 1/2,
                                                          plotlyOutput("maintenanceInsightPlot"),
                                                          plotlyOutput("maintenanceNSCInsightPlot")
                                       )
                              ),
                  ),
              
       
       )
     )
   ) 
  )
 )

)

################  Server ################
server <- function(input, output,session) {
  
########## Overview #######
#==== Overview Value Boxes =======
output$parkValueBox <- renderValueBox({
    valueBox(  tags$p("# of Parks", style = "font-size: 80%;"), paste0(length(parks$NAME)), 
               icon = icon("list"),color = "aqua")
  }) 
  
output$speciesValueBox <- renderValueBox({
    valueBox(  tags$p("Species Type", style = "font-size: 80%;"), paste0(length(unique(tree$SPECIES))), 
               icon = icon("list"),color = "aqua")
}) 

output$genusValueBox <- renderValueBox({
  valueBox(  tags$p("Genus Type", style = "font-size: 80%;"), paste0(length(unique(tree$GENUS))), 
             icon = icon("list"),color = "aqua")
}) 

output$treeNameValueBox <- renderValueBox({
  valueBox(  tags$p("Tree Type", style = "font-size: 80%;"), paste0(length(unique(tree$TREE_NAME_VAL))), 
             icon = icon("list"),color = "aqua")
}) 

output$treeSizeValueBox <- renderValueBox({
  valueBox(  tags$p("Avg. Tree Diameter", style = "font-size: 80%;"), 
             paste0(format(round(tree_diameter<- mean(tree$DBH_VAL_update, na.rm = TRUE), 2), nsmall = 2)), 
           icon = icon("list"),color = "aqua")
})

output$treeMaintenanceValueBox <- renderValueBox({
  valueBox(  tags$p("Maintenance Actions", style = "font-size: 80%;"), 
             paste0(length(unique(tree$MAINT_VAL))), icon = icon("list"),color = "aqua")
})


#========= Overview Tabs =======
output$parkOverviewMap <- renderLeaflet({
  
  parkMap <- leaflet() %>%
    addTiles() %>% 
    setView(lng=parks$Longitude[1],
            lat=parks$Latitude[1],zoom=13) %>%
    addMarkers(lng=parks$Longitude,
               lat = parks$Latitude,
               label = parks$NAME,
               popup = parks$FULLADDR)
  parkMap
  
})

output$genusOverviewPlot <- renderPlotly({
  g <- tree %>%
    group_by(GENUS) %>%
    summarise(Total = n()) %>%
    select(GENUS, Total) %>% 
    arrange(desc(Total)) %>%
    top_n(n = 10) %>%
    ggplot(aes(x = reorder(GENUS,Total) ,y = Total, text = paste0(
      "GENUS: ", GENUS,
      "<br>Count: ", Total
    )))  +
    geom_bar(stat = "identity",width = 0.5, fill='black') + coord_flip() +
    labs(x ="Genus", y = "Total", title="Top Genus") + 
    theme_minimal(base_size = 12) + 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          plot.title = element_text(size = 12, hjust = 0.5),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 0, hjust = 1))
  ggplotly(g, tooltip = "text")
  
  
  
})

output$speciesOverviewPlot <- renderPlotly({
  g <- tree %>%
    group_by(SPECIES) %>%
    summarise(Total = n()) %>%
    select(SPECIES, Total) %>% 
    arrange(desc(Total)) %>%
    top_n(n = 10) %>%
    ggplot(aes(x = reorder(SPECIES,Total) ,y = Total,text = paste0(
      "Species: ", SPECIES,
      "<br>Count: ", Total
    )))  +
    geom_bar(stat = "identity",width = 0.5, fill='black') + coord_flip() +
    labs(x ="Species", y = "Total", title="Top Species") +
  theme_minimal(base_size = 12) + 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          plot.title = element_text(size = 12, hjust = 0.5),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 0, hjust = 1))
  ggplotly(g, tooltip = "text")
  
  
})

output$treeNameOverviewPlot <- renderPlotly({
  g <- tree %>%
    group_by(TREE_NAME_VAL) %>%
    summarise(Total = n()) %>%
    select(TREE_NAME_VAL, Total) %>% 
    arrange(desc(Total)) %>%
    top_n(n = 10) %>%
    ggplot(aes(x = reorder(TREE_NAME_VAL,Total) ,y = Total,text = paste0(
      "Tree Name: ", TREE_NAME_VAL,
      "<br>Count: ", Total
    )))  +
    geom_bar(stat = "identity",width = 0.5, fill='black') + coord_flip() +
    labs(x ="Tree Name", y = "Total", title="Top Trees") +
    theme_minimal(base_size = 12) + 
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            plot.title = element_text(size = 12, hjust = 0.5),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10),
            axis.text.x = element_text(angle = 0, hjust = 1))
    ggplotly(g, tooltip = "text")
  
  
})


output$dbhgenusOverviewPlot <- renderPlotly({
  g_df <- tree %>%
    group_by(GENUS) %>%
    summarise(Total = n()) %>%
    select(GENUS, Total) %>% 
    arrange(desc(Total)) %>%
    top_n(n = 10)
  
  g <- tree %>%
    filter(GENUS %in% c(g_df$GENUS)) %>%
    group_by(GENUS) %>%
    summarise(Total = round(mean(DBH_VAL_update)),2) %>%
    select(GENUS, Total) %>% 
    arrange(desc(Total)) %>%
    ggplot(aes(x = reorder(GENUS,Total) ,y = Total,text = paste0(
      "GENUS: ", GENUS,
      "<br>Average Breast Height Diameter: ", Total
    )))  +
    geom_bar(stat = "identity",width = 0.5, fill='black') + coord_flip() +
    labs(x ="Genus", y = "Total", title="Top Genus & Avg. Breast Height Diameter") +
    theme_minimal(base_size = 12) + 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          plot.title = element_text(size = 12, hjust = 0.5),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 0, hjust = 1))
  ggplotly(g, tooltip = "text")
  
})


output$dbhAgeProfileOverviewPlot <- renderPlotly({
  
  tree_df <- tree %>%
    mutate(DBH_Category = case_when(
      DBH_VAL_update < 11  ~ "Young",
      DBH_VAL_update < 20  ~ "Mature",
      DBH_VAL_update >= 20 ~ "Old",
      TRUE ~ NA_character_
    ))
  
  g <- tree_df %>%
    group_by(DBH_Category) %>%
    summarise(Total = n()) %>%
    select(DBH_Category, Total) %>% 
    arrange(desc(Total)) %>%
    ggplot(aes(x = reorder(DBH_Category,Total) ,y = Total,text = paste0(
      "Breast Height Diameter Category: ", DBH_Category,
      "<br>Count: ", Total
    )))  +
    geom_bar(stat = "identity",width = 0.5, fill='black') + coord_flip() +
    labs(x ="Breast Height Diameter Category", y = "Total", title="Breast Height Diameter Category") +
  theme_minimal(base_size = 12) + 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          plot.title = element_text(size = 12, hjust = 0.5),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 0, hjust = 1))
  ggplotly(g, tooltip = "text")
  
    
  
  
})

output$dbhOverviewHistogramPlot <- renderPlotly({
  g <- tree %>%
    ggplot(aes(x = DBH_VAL_update,text = paste0(
      "Breast Height Diameter: ", round(after_stat(x),2),
      "<br>Count: ", after_stat(count)
    )))  +
    geom_histogram(fill='black') + 
    labs(x ="Breast Height Diameter", y = "Total", title="Breast Height Diameter Histogram") +
  theme_minimal(base_size = 12) + 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          plot.title = element_text(size = 12, hjust = 0.5),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 0, hjust = 1))
  ggplotly(g, tooltip = "text")
})

output$inventoryOverviewPlot <- renderPlotly({
  g <- tree %>%
    group_by(new_inv_date) %>%
    summarise(Total = n()) %>%
    filter(new_inv_date >= '2008') %>%
    select(new_inv_date, Total) %>% 
    ggplot(aes(x =new_inv_date ,y = Total,text = paste0(
      "Inventory Year: ", new_inv_date,
      "<br>Count: ", Total
    )))  +
    geom_bar(stat = "identity",width = 0.5, fill='black') +
    labs(x ="Inventory Year", y = "Total", title="Annual Tree Inventory") +
  theme_minimal(base_size = 12) + 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          plot.title = element_text(size = 12, hjust = 0.5),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 0, hjust = 1))
  ggplotly(g, tooltip = "text")
})

output$maintenanceOverviewPlot <- renderPlotly({
  g <- tree %>%
    group_by(MAINT_VAL) %>%
    summarise(Total = n()) %>%
    select(MAINT_VAL, Total) %>% 
    arrange(desc(Total)) %>%
    top_n(n = 10) %>%
    ggplot(aes(x = reorder(MAINT_VAL,Total) ,y = Total,text = paste0(
      "Maintenance Activities: ", MAINT_VAL,
      "<br>Count: ", Total
    )))  +
    geom_bar(stat = "identity",width = 0.5, fill='black') + coord_flip() +
    labs(x ="Maintenance Activities", y = "Total", title="Top Maintenance Activities") +
  theme_minimal(base_size = 12) + 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          plot.title = element_text(size = 12, hjust = 0.5),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 0, hjust = 1))
  ggplotly(g, tooltip = "text")
})
  
output$maintenanceNSCOverviewPlot <- renderPlotly({
  g_df <- tree %>%
    group_by(MAINT_VAL) %>%
    summarise(Total = n()) %>%
    select(MAINT_VAL, Total) %>% 
    arrange(desc(Total)) %>%
    top_n(n = 10)
  
  g <- tree %>%
    filter(MAINT_VAL %in% c(g_df$MAINT_VAL)) %>%
    group_by(MAINT_VAL,NSC_AREA_VAL) %>%
    summarise(Total = n()) %>%
    select(MAINT_VAL, NSC_AREA_VAL,Total) %>% 
    top_n(n = 10) %>%
    ggplot(aes(NSC_AREA_VAL,MAINT_VAL, fill= Total,text = paste0(
      "Maintenance Activities: ", MAINT_VAL,
      "<br>NSC Area: ", NSC_AREA_VAL,
      "<br>Count: ", Total
    ))) + 
    geom_tile() + 
    labs(x = "NSC Area", y ="Maintenance Activities", title=" Top Maintenance Activities & NSC Area Heatmap") +
  theme_minimal(base_size = 12) + 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          plot.title = element_text(size = 12, hjust = 0.5),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 0, hjust = 1))
  ggplotly(g, tooltip = "text")
    
})
  
  


########## Insights #######
#======== Insight Value Box ========
tree_info <- reactive({
  tree_df %>%
    filter(NAME == input$parkInput)
})

output$parkValueInsightValueBox <- renderValueBox({
  valueBox( tags$p("Park Address", style = "font-size: 80%;"), tags$p(paste0(unique(tree_info()$FULLADDR)), 
                                  style = "font-size: 100%;"), icon = icon("book"), color = "aqua")
  
 
}) 

output$speciesInsightValueBox <- renderValueBox({
  valueBox(tags$p("Species Type", style = "font-size: 80%;"), tags$p(paste0(length(unique(tree_info()$SPECIES))), 
                                         style = "font-size: 100%;"), icon = icon("list"),color = "aqua")
}) 

output$genusInsightValueBox <- renderValueBox({
  valueBox(tags$p("Genus Type", style = "font-size: 80%;"), tags$p(paste0(length(unique(tree_info()$GENUS))), 
                                       style = "font-size: 100%;"), icon = icon("list"),color = "aqua")
}) 

output$treeNameInsightValueBox <- renderValueBox({
  valueBox(tags$p("Tree Types", style = "font-size: 80%;"), tags$p(paste0(length(unique(tree_info()$TREE_NAME_VAL))), 
                                       style = "font-size: 100%;"), icon = icon("list"),color = "aqua")
}) 

output$treeSizeInsightValueBox <- renderValueBox({
  valueBox(tags$p("Breast Height Diameter", style = "font-size: 70%;"), 
           tags$p(paste0(format(round(tree_diameter<- mean(tree_info()$DBH_VAL_update, na.rm = TRUE), 2), nsmall = 2)), 
                                           style = "font-size: 100%;"), 
           icon = icon("book"),color = "aqua")
})

output$treeMaintenanceInsightValueBox <- renderValueBox({
  valueBox(tags$p("Maintenance Actions", style = "font-size: 70%;"), tags$p(paste0(length(unique(tree_info()$MAINT_VAL))), 
                                                style = "font-size: 100%;"), icon = icon("list"),color = "aqua")
})

output$parkInsightMap <- renderLeaflet({
  
  parkMap <- leaflet() %>%
    addTiles() %>% 
    setView(lng=tree_info()$Longitude[1],
            lat=tree_info()$Latitude[1],zoom=13) %>%
    addMarkers(lng=tree_info()$Longitude[1],
               lat = tree_info()$Latitude[1],
               label = tree_info()$NAME,
               popup = tree_info()$FULLADDR )
  
  parkMap
  
})

output$genusInsightPlot <- renderPlotly({
  g <- tree_info() %>%
    group_by(GENUS) %>%
    summarise(Total = n()) %>%
    select(GENUS, Total) %>% 
    arrange(desc(Total)) %>%
    top_n(n = 10) %>%
    ggplot(aes(x = reorder(GENUS,Total) ,y = Total,text = paste0(
      "GENUS: ", GENUS,
      "<br>Count: ", Total
    )))  +
    geom_bar(stat = "identity",width = 0.5, fill='black') + coord_flip() +
    labs(x ="Genus", y = "Total", title="Top Genus") +
  theme_minimal(base_size = 12) + 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          plot.title = element_text(size = 12, hjust = 0.5),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 0, hjust = 1))
  ggplotly(g, tooltip = "text")
  
  
})

output$speciesInsightPlot <- renderPlotly({
  g <- tree_info() %>%
    group_by(SPECIES) %>%
    summarise(Total = n()) %>%
    select(SPECIES, Total) %>% 
    arrange(desc(Total)) %>%
    top_n(n = 10) %>%
    ggplot(aes(x = reorder(SPECIES,Total) ,y = Total,text = paste0(
      "Species: ", SPECIES,
      "<br>Count: ", Total
    )))  +
    geom_bar(stat = "identity",width = 0.5, fill='black') + coord_flip() +
    labs(x ="Species", y = "Total", title="Top Species") +
  theme_minimal(base_size = 12) + 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          plot.title = element_text(size = 12, hjust = 0.5),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 0, hjust = 1))
  ggplotly(g, tooltip = "text")
  
  
})



output$treeNameInsightPlot <- renderPlotly({
  g <- tree_info() %>%
    group_by(TREE_NAME_VAL) %>%
    summarise(Total = n()) %>%
    select(TREE_NAME_VAL, Total) %>% 
    arrange(desc(Total)) %>%
    top_n(n = 10) %>%
    ggplot(aes(x = reorder(TREE_NAME_VAL,Total) ,y = Total,text = paste0(
      "Tree Name: ", TREE_NAME_VAL,
      "<br>Count: ", Total
    )))  +
    geom_bar(stat = "identity",width = 0.5, fill='black') + coord_flip() +
    labs(x ="Tree Name", y = "Total", title="Top Trees") +
  theme_minimal(base_size = 12) + 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          plot.title = element_text(size = 12, hjust = 0.5),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 0, hjust = 1))
  ggplotly(g, tooltip = "text")
  
  
  
})


output$dbhgenusInsightPlot <- renderPlotly({
  g_df <- tree_info() %>%
    group_by(GENUS) %>%
    summarise(Total = n()) %>%
    select(GENUS, Total) %>% 
    arrange(desc(Total)) %>%
    top_n(n = 10)
  
  g <- tree_info() %>%
    filter(GENUS %in% c(g_df$GENUS)) %>%
    group_by(GENUS) %>%
    summarise(Total = round(mean(DBH_VAL_update)),2) %>%
    select(GENUS, Total) %>% 
    arrange(desc(Total)) %>%
    ggplot(aes(x = reorder(GENUS,Total) ,y = Total,text = paste0(
      "Tree Name: ", GENUS,
      "<br>Average Breast Height Diameter: ", Total
    )))  +
    geom_bar(stat = "identity",width = 0.5, fill='black') + coord_flip() +
    labs(x ="Genus", y = "Total", title="Top Genus & Avg. Breast Height Diameter") +
  theme_minimal(base_size = 12) + 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          plot.title = element_text(size = 12, hjust = 0.5),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 0, hjust = 1))
  ggplotly(g, tooltip = "text")
  
})


output$dbhAgeProfileInsightPlot <- renderPlotly({
  
  tree_df <- tree_info()
  
  tree_df <- tree_df %>%
    mutate(DBH_Category = case_when(
      DBH_VAL_update < 11  ~ "Young",
      DBH_VAL_update < 20  ~ "Mature",
      DBH_VAL_update >= 20 ~ "Old",
      TRUE ~ NA_character_
    ))
  
  g <- tree_df %>%
    group_by(DBH_Category) %>%
    summarise(Total = n()) %>%
    select(DBH_Category, Total) %>% 
    arrange(desc(Total)) %>%
    ggplot(aes(x = reorder(DBH_Category,Total) ,y = Total,text = paste0(
      "Breast Height Diameter Category: ", DBH_Category,
      "<br>Count: ", Total
    )))  +
    geom_bar(stat = "identity",width = 0.5, fill='black') + coord_flip() +
    labs(x ="Breast Height Diameter Category", y = "Total", title="Breast Height Diameter Categories") +
  theme_minimal(base_size = 12) + 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          plot.title = element_text(size = 12, hjust = 0.5),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 0, hjust = 1))
  ggplotly(g, tooltip = "text")
  
  
  
  
})

output$dbhOverviewHistogramInsightPlot <- renderPlotly({
  g <- tree_info() %>%
    ggplot(aes(x = DBH_VAL_update,text = paste0(
      "Breast Height Diameter: ", round(after_stat(x),2),
      "<br>Count: ", after_stat(count)
    )))  +
    geom_histogram(fill='black') + 
    labs(x ="Breast Height Diameter", y= "Total", title="Breast Height Diameter Histogram") +
  theme_minimal(base_size = 12) + 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          plot.title = element_text(size = 12, hjust = 0.5),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 0, hjust = 1))
  ggplotly(g, tooltip = "text")
})

output$inventoryInsightPlot <- renderPlotly({
  g <- tree_info() %>%
    group_by(new_inv_date) %>%
    summarise(Total = n()) %>%
    filter(new_inv_date >= '2008') %>%
    select(new_inv_date, Total) %>% 
    ggplot(aes(x =factor(new_inv_date) ,y = Total,text = paste0(
      "Inventory Year: ", new_inv_date,
      "<br>Count: ", Total
    )))  +
    geom_bar(stat = "identity",width = 0.5, fill='black') +
    labs(x ="Inventory Year", y = "Total", title="Annual Tree Inventory") +
  theme_minimal(base_size = 12) + 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          plot.title = element_text(size = 12, hjust = 0.5),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 0, hjust = 1))
  ggplotly(g, tooltip = "text")
})

output$maintenanceInsightPlot <- renderPlotly({
  g <- tree_info() %>%
    group_by(MAINT_VAL) %>%
    summarise(Total = n()) %>%
    select(MAINT_VAL, Total) %>% 
    arrange(desc(Total)) %>%
    top_n(n = 10) %>%
    ggplot(aes(x = reorder(MAINT_VAL,Total) ,y = Total,text = paste0(
      "Maintenance Activities: ", MAINT_VAL,
      "<br>Count: ", Total
    )))  +
    geom_bar(stat = "identity",width = 0.5, fill='black') + coord_flip() +
    labs(x ="Maintenance Activities", y = "Total", title="Top Maintenance Activities") +
  theme_minimal(base_size = 12) + 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          plot.title = element_text(size = 12, hjust = 0.5),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 0, hjust = 1))
  ggplotly(g, tooltip = "text")
})

output$maintenanceNSCInsightPlot <- renderPlotly({
  g_df <- tree_info() %>%
    group_by(MAINT_VAL) %>%
    summarise(Total = n()) %>%
    select(MAINT_VAL, Total) %>% 
    arrange(desc(Total)) %>%
    top_n(n = 10)
  
  g <- tree_info() %>%
    filter(MAINT_VAL %in% c(g_df$MAINT_VAL)) %>%
    group_by(MAINT_VAL,NSC_AREA_VAL) %>%
    summarise(Total = n()) %>%
    select(MAINT_VAL, NSC_AREA_VAL,Total) %>% 
    top_n(n = 10) %>%
    ggplot(aes(NSC_AREA_VAL,MAINT_VAL, fill= Total,text = paste0(
      "Maintenance Activities: ", MAINT_VAL,
      "<br>NSC Area: ", NSC_AREA_VAL,
      "<br>Count: ", Total
    ))) + 
    geom_tile() + 
    labs(x = "NSC Area", y ="Maintenance Activities", title=" Top Maintenance Activities & NSC Area Heatmap") +
  theme_minimal(base_size = 12) + 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          plot.title = element_text(size = 12, hjust = 0.5),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 0, hjust = 1))
  ggplotly(g, tooltip = "text")
  
})


  
}

shinyApp(ui, server)
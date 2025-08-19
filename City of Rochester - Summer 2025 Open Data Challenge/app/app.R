#========================================
# Shiny web app leveraging City of Rochester Open Data
#=========================================
rm(list = ls())
################  Packages ################
# library(ggplot2)
# library(corrplot)
# library(tidyverse)
# library(shiny)
# library(shinydashboard)
# library(mlbench)
# library(caTools)
# library(gridExtra)
# library(doParallel)
# library(grid)
# library(reshape2)
# library(caret)
# library(tidyr)
# library(Matrix)
# library(lubridate)
# library(plotly)
# library(RColorBrewer)
# library(data.table)
# library(scales)
# library(rfm)
# library(forecast)
# library(TTR)
# library(xts)
# library(dplyr)
# library(treemapify)
# library(shinycssloaders)
# library(bslib)
# library(readxl)
# library(htmltools)
# library(markdown)
# library(scales)
# library(leaflet)

packages <- c(
  'ggplot2', 'corrplot','tidyverse','shiny','shinydashboard','shinycssloaders',
  'bslib','readxl','DT','mlbench','caTools','gridExtra','doParallel','grid',
  'reshape2','caret','tidyr','Matrix','lubridate','plotly','RColorBrewer',
  'data.table','scales','rfm','forecast','TTR','xts','dplyr', 'treemapify','leaflet'
)
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}
################ Load Data ################
parks <- read_csv("Parks_and_Playgrounds.csv")
tree <- read_csv("Trees.csv")
tree_address <- read_csv("Trees_address.csv")


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
      menuItem("Park Overview", tabName = "park_overview", icon = icon("th"))#,
      #menuItem("Park Insights", tabName = "park_insight", icon = icon("thumbs-up")),
      
    )
  ),
  dashboardBody(
    tabItems(
      ######### About #########
      tabItem(tabName = "about",includeMarkdown("about.md"),hr()), 
      
      ######### Overview ######### 
       tabItem(tabName = "park_overview",

                 mainPanel(width = 10,
                           fluidRow(
                             column(width = 12,
                                    valueBoxOutput("speciesValueBox"),
                                    valueBoxOutput("genusValueBox"),
                                    valueBoxOutput("treeNameValueBox")
                             )
                           ),
                           br(),br(),
                          fluidRow(
                            h4("Park Map",style="text-align: center;"),
                            leafletOutput("parkOverviewMap", width = 'auto',height="600px")
                          ), 
                          br(),br(),
                          fluidRow(
                            layout_column_wrap(width = 1/2,
                                               plotlyOutput("genusOverviewPlot"),
                                               plotlyOutput("speciesOverviewPlot")
                            )
                          ),
                           
                           br(),br(),
                           layout_columns(width = 1/2,
                             plotlyOutput("treeNameOverviewPlot"),
                             plotlyOutput("maintenanceOverviewPlot")
                           )
                 )
               )
      ######### Insights ######### 
    )
  ) 
)



################  Server ################
server <- function(input, output,session) {
  
########## Overview #######
output$speciesValueBox <- renderValueBox({
    valueBox("Species Type", paste0(length(unique(tree$SPECIES))), icon = icon("list"),color = "aqua")
}) 

output$genusValueBox <- renderValueBox({
  valueBox("Genus Type", paste0(length(unique(tree$GENUS))), icon = icon("list"),color = "aqua")
}) 

output$treeNameValueBox <- renderValueBox({
  valueBox("Tree Types", paste0(length(unique(tree$TREE_NAME_VAL))), icon = icon("list"),color = "aqua")
}) 

output$parkOverviewMap <- renderLeaflet({
  
  parkMap <- leaflet() %>%
    addTiles() %>% 
    setView(lng=parks$Longitude[1],
            lat=parks$Latitude[1],zoom=13) %>%
    addMarkers(lng=parks$Longitude,
               lat = parks$Latitude,
               label = parks$Name,
               popup = parks$FULLADDR )
  
  parkMap
  
})

output$genusOverviewPlot <- renderPlotly({
  g <- tree %>%
    group_by(GENUS) %>%
    summarise(Total = n()) %>%
    select(GENUS, Total) %>% 
    arrange(desc(Total)) %>%
    top_n(n = 10) %>%
    ggplot(aes(x = reorder(GENUS,Total) ,y = Total))  +
    geom_bar(stat = "identity",width = 0.5, fill='black') + coord_flip() +
    labs(x ="GENUS", y = "Total", title="Top 10 Genus across all Parks") 
  theme(legend.text = element_text(size = 10),
        legend.title = element_text(size = 10),
        axis.title = element_text(size = 12),
        axis.text = element_text(size = 10))
  
  ggplotly(g)
  
  
})

output$speciesOverviewPlot <- renderPlotly({
  g <- tree %>%
    group_by(SPECIES) %>%
    summarise(Total = n()) %>%
    select(SPECIES, Total) %>% 
    arrange(desc(Total)) %>%
    top_n(n = 10) %>%
    ggplot(aes(x = reorder(SPECIES,Total) ,y = Total))  +
    geom_bar(stat = "identity",width = 0.5, fill='black') + coord_flip() +
    labs(x ="Species", y = "Total", title="Top 10 Species across all Parks") 
  theme(legend.text = element_text(size = 10),
        legend.title = element_text(size = 10),
        axis.title = element_text(size = 12),
        axis.text = element_text(size = 10))
  
  ggplotly(g)
  
  
})

output$treeNameOverviewPlot <- renderPlotly({
  g <- tree %>%
    group_by(TREE_NAME_VAL) %>%
    summarise(Total = n()) %>%
    select(TREE_NAME_VAL, Total) %>% 
    arrange(desc(Total)) %>%
    top_n(n = 10) %>%
    ggplot(aes(x = reorder(TREE_NAME_VAL,Total) ,y = Total))  +
    geom_bar(stat = "identity",width = 0.5, fill='black') + coord_flip() +
    labs(x ="Tree Name", y = "Total", title="Top 10 Trees across all Parks") 
  theme(legend.text = element_text(size = 10),
        legend.title = element_text(size = 10),
        axis.title = element_text(size = 12),
        axis.text = element_text(size = 10))
  
  ggplotly(g)
  
  
})

output$maintenanceOverviewPlot <- renderPlotly({
  g <- tree %>%
    group_by(MAINT_VAL) %>%
    summarise(Total = n()) %>%
    select(MAINT_VAL, Total) %>% 
    arrange(desc(Total)) %>%
    top_n(n = 10) %>%
    ggplot(aes(x = reorder(MAINT_VAL,Total) ,y = Total))  +
    geom_bar(stat = "identity",width = 0.5, fill='black') + coord_flip() +
    labs(x ="Maintenance Activities", y = "Total", title="Top 10 Tree Maintenance actions across all Parks") 
  theme(legend.text = element_text(size = 10),
        legend.title = element_text(size = 10),
        axis.title = element_text(size = 12),
        axis.text = element_text(size = 10))
  
  ggplotly(g)
  
  
})


  
}

shinyApp(ui, server)
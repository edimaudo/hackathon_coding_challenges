#========================================
# Shiny web app leveraging City of Rochester Open Data
#=========================================

################  Packages ################
rm(list = ls())
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

packages <- c(
  'ggplot2', 'corrplot','tidyverse','shiny','shinydashboard','shinycssloaders',
  'bslib','readxl','DT','mlbench','caTools','gridExtra','doParallel','grid',
  'reshape2','caret','tidyr','Matrix','lubridate','plotly','RColorBrewer','stringr',
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

################ Data Setup ################
tree$new_inv_date <- lubridate::year(as.Date(tree$INV_DATE, format =  "%Y/%m/%d"))
tree$DBH_VAL_update <- as.numeric(str_remove_all(tree$DBH_VAL, "[\"']"))

tree_temp <- inner_join(tree, tree_address,by="PARKS_VAL") %>%
  select(FULLADDR,GENUS,SPECIES,TREE_NAME_VAL,THEME_VAL,MAINT_VAL,AREA_VAL) %>%
  na.omit() %>%
  unique()

tree_df <- inner_join(tree_temp,parks,by="FULLADDR",relationship = "many-to-many") %>%
  select(FULLADDR,NAME,PHONE,AGENCYURL,EMAIL,Longitude,Latitude,GENUS,SPECIES,TREE_NAME_VAL,THEME_VAL,MAINT_VAL,AREA_VAL) %>%
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
                          fluidRow(
                            h4("City of Rochester Park Map",style="text-align: center;"),
                            leafletOutput("parkOverviewMap", width = 'auto',height="300px")
                          ), 
                          br(),br(),
                          tabsetPanel(type = "tabs",
                                      tabPanel(h4("Tree Characteristics",style="text-align: center;"),
                                               plotlyOutput("genusOverviewPlot"),
                                               plotlyOutput("speciesOverviewPlot"),
                                               plotlyOutput("treeNameOverviewPlot")
                                      ),

                                      tabPanel(h4("Inventory",style="text-align: center;"),
                                               plotlyOutput("inventoryOverviewPlot")
                                      ),
                                      tabPanel(h4("Maintenance",style="text-align: center;"),
                                               plotlyOutput("maintenanceOverviewPlot")
                                      ),
                          ),
                          
                 )
               ),
      ######### Insights ######### 
      tabItem(tabName = "park_insight",
              sidebarLayout(
                sidebarPanel(width = 4,
                             selectInput("parkInput", "Parks", 
                                         choices = park_list, selected = park_list[0], multiple = FALSE),
                             submitButton("Submit")
                ),
                mainPanel(width = 12,
                  fluidRow(
                    column(width = 12,
                           valueBoxOutput("speciesInsightBox"),
                           valueBoxOutput("genusInsighteBox"),
                           valueBoxOutput("treeNameInsightBox")
                    )
                  ),
                  br(),br(),
                  fluidRow(
                    h4("Park Map",style="text-align: center;"),
                    leafletOutput("parkInsightMap", width = 'auto',height="300px")
                  ), 
                  br(),br(),
                  tabsetPanel(type = "tabs",
                              tabPanel(h4("Top 10 Genus",style="text-align: center;"),
                                       plotlyOutput("genusInsightPlot"),
                              ),
                              tabPanel(h4("Top 10 Species",style="text-align: center;"),
                                       plotlyOutput("speciesInsightPlot"),
                              ),
                              tabPanel(h4("Top 10 Trees",style="text-align: center;"),
                                       plotlyOutput("treeNameInsightPlot"),
                              ),
                              tabPanel(h4("Top 10 Maintenance Actions",style="text-align: center;"),
                                       plotlyOutput("maintenanceInsightPlot")
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
  output$parkValueBox <- renderValueBox({
    valueBox("# of Parks", paste0(length(parks$NAME)), icon = icon("list"),color = "aqua")
  }) 
  
output$speciesValueBox <- renderValueBox({
    valueBox("Unique Species Type", paste0(length(unique(tree$SPECIES))), icon = icon("list"),color = "aqua")
}) 

output$genusValueBox <- renderValueBox({
  valueBox("Unique Genus Type", paste0(length(unique(tree$GENUS))), icon = icon("list"),color = "aqua")
}) 

output$treeNameValueBox <- renderValueBox({
  valueBox("Unique Tree Types", paste0(length(unique(tree$TREE_NAME_VAL))), icon = icon("list"),color = "aqua")
}) 

output$treeSizeValueBox <- renderValueBox({
  valueBox("Average Tree Diameter", paste0(format(round(tree_diameter<- mean(tree$DBH_VAL_update, na.rm = TRUE), 2), nsmall = 2)), 
           icon = icon("list"),color = "aqua")
})

output$treeMaintenanceValueBox <- renderValueBox({
  valueBox("Unique Maintenance Actions", paste0(length(unique(tree$MAINT_VAL))), icon = icon("list"),color = "aqua")
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
    labs(x ="GENUS", y = "Total", title="Top 10 Genus") 
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
    labs(x ="Species", y = "Total", title="Top 10 Species") 
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
    labs(x ="Tree Name", y = "Total", title="Top 10 Trees") 
  theme(legend.text = element_text(size = 10),
        legend.title = element_text(size = 10),
        axis.title = element_text(size = 12),
        axis.text = element_text(size = 10))
  
  ggplotly(g)
  
  
})

output$inventoryOverviewPlot <- renderPlotly({
  g <- tree %>%
    group_by(new_inv_date) %>%
    summarise(Total = n()) %>%
    filter(new_inv_date >= '2008') %>%
    select(new_inv_date, Total) %>% 
    ggplot(aes(x =new_inv_date ,y = Total))  +
    geom_bar(stat = "identity",width = 0.5, fill='black') +
    labs(x ="Inventory Year", y = "Total", title="Annual Tree Inventory") 
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
    labs(x ="Maintenance Activities", y = "Total", title="Top 10 Maintenance Activities") 
  theme(legend.text = element_text(size = 10),
        legend.title = element_text(size = 10),
        axis.title = element_text(size = 12),
        axis.text = element_text(size = 10))
  
  ggplotly(g)
  
  
})

########## Insights #######



  
}

shinyApp(ui, server)
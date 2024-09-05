#========================================
# Shiny web app which provides insights
# about Toronto Public Library
#=========================================
rm(list = ls())
################
# Libraries
################
packages <- c(
  'rjson','dplyr',
  'ggplot2', 'corrplot','tidyverse','shiny','shinydashboard','bslib','DT','readxl',
  'mlbench','caTools','gridExtra','doParallel','grid','forecast','reshape2',
  'caret','dummies','tidyr','Matrix','lubridate','plotly','RColorBrewer',
  'data.table','scales','stopwords','tidytext','stringr','wordcloud','wordcloud2',
  'SnowballC','textmineR','topicmodels','textclean','tm'
)
for (package in packages) {
  if (!require(package, character.only = T, quietly = T)) {
    install.packages(package)
    library(package, character.only = T)
  }
}
################
# Load data
################
tpl_clc <- read_csv("Computer_Learning_Centres.csv")
tpl_dih <- read_csv("Digital_Innovation_Hubs.csv")
tpl_kecl <- read_csv("KidsStop_Early_Literacy_Centres.csv")
tpl_nib <- read_csv("Neighbourhood_Improvement_Area_Branches.csv")
tpl <- read_csv("tpl-branch-general-information-2023.csv")
tpl_branch_card_registration <- read_csv("tpl-card-registrations-annual-by-branch-2012-2022.csv")
tpl_branch_circulation <- read_csv("tpl-circulation-annual-by-branch-2012-2022.csv")
tpl_branch_eventfeed <- read_csv("tpl-events-feed.csv")
tpl_branch_visit <- read_csv("tpl-visits-annual-by-branch-2012-2022.csv")
tpl_branch_workstation <- read_csv("tpl-workstation-usage-annual-by-branch-2012-2022.csv")
tpl_yag <- read_csv("Youth_Advisory_Groups_Locations.csv")
tpl_yh <- read_csv("Youth_Hubs_Locations.csv")
toronto_wellbeing <- read_csv("wellbeing-toronto-economics.csv")


################
# UI
################
ui <- dashboardPage(
  dashboardHeader(title = "TPL",
                  tags$li(a(href = 'https://www.torontopubliclibrary.ca',
                            img(src = 'https://upload.wikimedia.org/wikipedia/commons/4/47/Toronto_Public_Library_Logo.png',
                                title = "Home", height = "30px"),
                            style = "padding-top:10px; padding-bottom:10px;"),
                          class = "dropdown")),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("list")),
      menuItem("About", tabName = "about", icon = icon("th"))
    )
  ),
  dashboardBody(
    #========  
    # Overview
    #========
    tabItems(
      tabItem(tabName = "overview",
              fluidRow(
                valueBoxOutput("libraryBox"),
                valueBoxOutput("clcBox"),
                valueBoxOutput("keclBox"),
                #valueBoxOutput("nibBox"),
                valueBoxOutput("dihBox"),
                valueBoxOutput("yagBox"),
                valueBoxOutput("yhBox")
              ),
              h2("Trends",style="text-align: center;text-style:bold"),
              fluidRow(
                radioButtons( 
                  inputId = "radioTrend", 
                  label = "", 
                  choices = list( 
                    "Annual Card Registrations" = 1, 
                    "Annual Circulation" = 2, 
                    "Annual Visits" = 3,
                    "Annual Workstation Usage" = 4 
                  ) ,
                  inline=T
                ),
                plotlyOutput("tplOverviewTrendPlot"),  
              ),
              
      ),
      tabItem(tabName = "branch",
              navset_pill( 
                nav_panel("A", "Page A content"), 
                nav_panel("B", "Page B content"), 
                nav_panel("C", "Page C content") 
              )
              ),
      tabItem(tabName = "about",includeMarkdown("about.md"),hr())
    )
  )
)


################
# Server
################
server <- function(input, output, session) {
  #-----------
  # Overview
  #-----------
  # of libraries
  output$libraryBox <- renderValueBox({
    tpl_library <- tpl %>%
      filter(PhysicalBranch == 1) %>%
      select(BranchName)
    
    valueBox(
      value = tags$p("Libraries", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(length(unique(tpl_library$BranchName))), style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })
  # Computer_Learning_Centres
  output$clcBox <- renderValueBox({
    valueBox(
      value = tags$p("Computer Learning Centres", style = "font-size: 80%;"),
      subtitle = tags$p(paste0(length(unique(tpl_clc$`Branch Name`))), style = "font-size: 100%;"),
      icon = icon("computer"),    
      color = "aqua"
    )
  })  
  # of KidsStop_Early_Literacy_Centres
  output$keclBox <- renderValueBox({
    valueBox(
      value = tags$p("Early Literacy Centres", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(length(unique(tpl_kecl$`Branch Name`))), style = "font-size: 100%;"),
      icon = icon("child"),  
      color = "aqua"
    )
  })  
  
  # of Neighbourhood_Improvement_Area_Branches
  output$nibBox <- renderValueBox({
    valueBox(
      value = tags$p("Improvement Branches", style = "font-size: 80%;"),
      subtitle = tags$p(paste0(length(unique(tpl_nib$`Branch Name`))), style = "font-size: 100%;"),
      icon = icon("thumbs-up"),  
      color = "aqua"
    )
  })  
  # of Digital_Innovation_Hubs
  output$dihBox <- renderValueBox({
    valueBox(
      value = tags$p("Digital Innovation Hub", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(length(unique(tpl_dih$`Branch Name`))), style = "font-size: 100%;"),
      icon = icon("lightbulb"),  
      color = "aqua"
    )
  })    
  # of Youth_Advisory_Groups_Locations
  output$yagBox <- renderValueBox({
    valueBox(
      value = tags$p("Youth Advisory", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(length(unique(tpl_yag$`Branch Name`))), style = "font-size: 100%;"),
      icon = icon("person"),  
      color = "aqua"
    )
  })   
  # of Youth_Hubs_Locations
  output$yhBox <- renderValueBox({
    valueBox(
      value = tags$p("Youth Hub", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(length(unique(tpl_yh$`Branch Name`))), style = "font-size: 100%;"),
      icon = icon("person"), 
      color = "aqua"
    )
  }) 
  
  output$tplOverviewTrendPlot <- renderPlotly({
    
    if (input$radioTrend == 1) {
      #- tpl-card-registrations-annual-by-branch-2012-2022
      tpl_trend <- tpl_branch_card_registration %>%
        group_by(Year)%>%
        summarise(Total = sum(Registrations)) %>%
        select(Year, Total) 
    } else if (input$radioTrend == 2){
      #- tpl-circulation-annual-by-branch-2012-2022
      tpl_trend <- tpl_branch_circulation%>%
        group_by(Year)%>%
        summarise(Total = sum(Circulation)) %>%
        select(Year, Total)
    } else if (input$radioTrend == 3){
      #- tpl-visits-annual-by-branch-2012-2022
      tpl_trend <- tpl_branch_visit%>%
        group_by(Year)%>%
        summarise(Total = sum(Visits)) %>%
        select(Year, Total)
    } else if (input$radioTrend == 4){
      #- tpl-workstation-usage-annual-by-branch-2012-2022
      tpl_trend <- tpl_branch_workstation%>%
        group_by(Year)%>%
        summarise(Total = sum(Sessions)) %>%
        select(Year, Total)
    }
    
    g <- ggplot(tpl_trend, aes(x = Year, ,y = Total))  +
      geom_bar(stat = "identity",width = 0.5, fill='black') + theme_classic() + 
      labs(x ="Year", y = "Total") + scale_x_continuous(breaks = breaks_pretty()) + 
      scale_y_continuous(breaks = breaks_pretty(),labels = label_comma()) + 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 12),
            axis.title = element_text(size = 14),
            axis.text = element_text(size = 12))
    
    ggplotly(g)
    

    
  })
  

}

shinyApp(ui, server)
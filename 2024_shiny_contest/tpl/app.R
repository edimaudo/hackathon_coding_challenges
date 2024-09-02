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
  'ggplot2', 'corrplot','tidyverse','shiny','shinydashboard','DT','readxl',
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
                valueBoxOutput("nibBox"),
                valueBoxOutput("dihBox"),
                valueBoxOutput("yagBox"),
                valueBoxOutput("yhBox")
              ),
              fluidRow(
                #plotlyOutput("submissionOutput"),  
              ),
              
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
      "Libraries", paste0(length(unique(tpl_library$BranchName))), icon = icon("book"),
      color = "aqua"
    )
  })
  # of  Computer_Learning_Centres
  output$clcBox <- renderValueBox({
    valueBox(
      "Computer Learning Centres", paste0(length(unique(tpl_clc$`Branch Name`))), icon = icon("computer"),
      color = "aqua"
    )
  })  
  # of KidsStop_Early_Literacy_Centres
  output$keclBox <- renderValueBox({
    valueBox(
      "Early Literacy Centres", paste0(length(unique(tpl_kecl$`Branch Name`))), icon = icon("child"),
      color = "aqua"
    )
  })  
  
  # of Neighbourhood_Improvement_Area_Branches
  output$nibBox <- renderValueBox({
    valueBox(
      "Improvement Branches", paste0(length(unique(tpl_nib$`Branch Name`))), icon = icon("thumbs-up"),
      color = "aqua"
    )
  })  
  # of Digital_Innovation_Hubs
  output$dihBox <- renderValueBox({
    valueBox(
      "Digital Innovation Hub", paste0(length(unique(tpl_dih$`Branch Name`))), icon = icon("lightbulb"),
      color = "aqua"
    )
  })    
  # of Youth_Advisory_Groups_Locations
  output$yagBox <- renderValueBox({
    valueBox(
      "Youth Advisory", paste0(length(unique(tpl_yag$`Branch Name`))), icon = icon("person"),
      color = "aqua"
    )
  })   
  # of Youth_Hubs_Locations
  output$yhBox <- renderValueBox({
    valueBox(
      "Youth Hub", paste0(length(unique(tpl_yh$`Branch Name`))), icon = icon("person"),
      color = "aqua"
    )
  }) 

}

shinyApp(ui, server)
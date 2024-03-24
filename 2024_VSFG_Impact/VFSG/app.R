#================================================================================
# Shiny web app which provides insights visualization for social good projects
#================================================================================
rm(list = ls())
################
# Packages 
################
packages <- c(
  'ggplot2', 'corrplot','tidyverse','shiny','shinydashboard','DT','readxl',
  'mlbench','caTools','gridExtra','doParallel','grid','forecast','reshape2',
  'caret','dummies','tidyr','Matrix','lubridate','plotly','RColorBrewer',
  'data.table','scales','stopwords','tidytext','stringr','wordcloud','wordcloud2',
  'SnowballC','textmineR','topicmodels','textclean','tm'
)
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}


################
# Load Data
################
charity_sdg <- read_excel("Charity - SDG.xlsx",sheet="SDG Goals")
charity_impact <- read_excel("Charity - SDG.xlsx",sheet="Impact Data")
partner_quotes <- read_excel("partner_quotes.xlsx")
linkedin <- read_excel("Linkedin Stats.xlsx",sheet="LI Metrics")
linkedin_posts <- read_excel("Linkedin Stats.xlsx",sheet="All posts")
project_nepal <- read_excel("projects/Build Up Nepal.xlsx")
project_india <- read_excel("projects/India Water Portal submissions.xlsx")
project_sunny <- read_excel("projects/Sunny Street Submissions.xlsx")
project_tap <- read_excel("projects/Tap Elderly Women_s Wisdom for Youth (TEWWY) Submissions.xlsx")
project_video <- read_excel("projects/Video Volunteers Submissions.xlsx")
project_who <- read_excel("projects/Who submissions.xlsx")


################
# Data Setup
################


################
# UI
################
ui <- dashboardPage(
  dashboardHeader(title = "VSFG Data Challenge"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("About", tabName = "about", icon = icon("th")),
      menuItem("Partners", tabName = "partner", icon = icon("list")),
        menuSubItem("Partner Feedback", tabName = "partner_quotes"),
        menuSubItem("Partner Insights", tabName = "partner_insights"),
      menuItem("Social Media", tabName = "social", icon = icon("list")),
      menuSubItem("Social Media Insights", tabName = "social_insights"),
      menuItem("Projects", tabName = "project", icon = icon("list"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "about",includeMarkdown("about.md"),hr()), 
      tabItem(tabName = "partner",
            fluidRow(
              valueBoxOutput("charityBox"),
              valueBoxOutput("countryBox"),
              valueBoxOutput("cityBox"),
              valueBoxOutput("topicBox"),
              valueBoxOutput("sdgBox"),
              valueBoxOutput("submissionBox"),
              plotOutput("submissionOutput"),
            ),
          ),
    tabItem(tabName = "partner_quotes","Widgets tab content"),
    tabItem(tabName = "partner_insights","Widgets tab content")
  )
 )
)



################
# Server logic 
################
server <- function(input, output,session) {
  
  #================
  # Charity Overview
  #================
  output$charityBox <- renderValueBox({
    valueBox(
      "Charities", paste0(length(unique(charity_impact$`Name of charity/Project`))), icon = icon("list"),
      color = "aqua"
    )
  })

  output$countryBox <- renderValueBox({
    valueBox(
      "Countries", paste0(length(unique(charity_impact$`Charity Country`))), icon = icon("list"),
      color = "aqua"
    )
  })  
  
  output$cityBox <- renderValueBox({
    valueBox(
      "Cities", paste0(length(unique(charity_impact$`Charity City`))), icon = icon("list"),
      color = "aqua"
    )
  }) 
  
  output$topicBox <- renderValueBox({
    valueBox(
      "Topics", paste0(length(unique(charity_impact$Topic))), icon = icon("thumbs-up"),
      color = "aqua"
    )
  }) 

  output$sdgBox <- renderValueBox({
      valueBox(
        "SDGs", paste0(length(unique(charity_sdg$`SDG Goals`))), icon = icon("thumbs-up"),
        color = "aqua"
      )
    })     
  
  output$submissionBox <- renderValueBox({
    valueBox(
      "Submissions", paste0(sum(charity_impact$`Number of Submissions`)), icon = icon("thumbs-up"),
      color = "aqua"
    )
  }) 

  output$submissionOutput <- renderPlot({
    charity_impact %>% 
      group_by(`Date of project`) %>%
      summarize(total_submissions = sum(`Number of Submissions`)) %>%
      select(`Date of project`,total_submissions) %>%
      ggplot( aes(x=`Date of project`, y=total_submissions)) +
      geom_line() + theme_classic() + 
      labs(x ="Dates", y = "# of Submissions") +
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 12),
            axis.title = element_text(size = 14),
            axis.text = element_text(size = 12))  
  })
  
}

shinyApp(ui, server)


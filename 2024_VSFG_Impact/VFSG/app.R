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
  'caret','dummies','tidyr','Matrix','lubridate','plotly',
  'data.table','scales','stopwords','tidytext','stringr', 
  'textmineR','topicmodels','textclean'
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
    tabItems(tabItem(tabName = "about",includeMarkdown("about.md"),hr())), 
    tabItem(tabName = "partner","Widgets tab content"), 
    tabItem(tabName = "partner_quotes","Widgets tab content"),
    tabItem(tabName = "partner_insights","Widgets tab content")
  )
)



################
# Server logic 
################
server <- function(input, output,session) {}

shinyApp(ui, server)


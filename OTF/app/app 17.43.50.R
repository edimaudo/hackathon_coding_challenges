################
# Ontario Trillium Foundation Insights
################

################
# Libraries
################
library(ggplot2)
library(plotly)
library(tidyverse)
library(shiny)
library(shinydashboard)
library(DT)
library(lubridate)
library(stopwords)
library(tidytext)
library(stringr)
library(wordcloud)
library(wordcloud2)
library(textmineR)
library(topicmodels)
library(textclean)
library(tm)
library(htmltools)
library(markdown)
library(scales)

################
# Data
################
#load data
df <- read.csv("otf.csv")

#===============
# Data Setup
#===============



#=============
# Text analytics
#=============




################
# UI
################
ui <- dashboardPage(
  dashboardHeader(
    title = "OTF Insights",
    tags$li(a(href = 'https://otf.ca',
    img(src = 'https://i.cbc.ca/1.4984433.1547842893!/fileImage/httpImage/image.jpg_gen/derivatives/16x9_940/ontario-trillium-foundation.jpg',
    title = "Home", height = "30px"),
    style = "padding-top:10px; padding-bottom:10px;"),
    class = "dropdown")
    ),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("house")),
      menuItem("Charity Insights", tabName = "charity", icon = icon("list")),
      menuItem("City Insights", tabName = "city", icon = icon("list")),
      menuItem("About", tabName = "about", icon = icon("th"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "about",includeMarkdown("about.md"),hr())
    )
  )
)




################
# Server
################
server <- function(input, output, session) {}
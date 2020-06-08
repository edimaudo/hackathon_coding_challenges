

#packages 
packages <- c('ggplot2', 'corrplot','tidyverse','shiny',
              'countrycode','shinydashboard','highcharter',"gridExtra")
#load packages
for (package in packages) {
    if (!require(package, character.only=T, quietly=T)) {
        install.packages(package)
        library(package, character.only=T)
    }
}

#load data
df <- read.csv("otf.csv")

#app
ui <- dashboardPage(
    dashboardHeader(title = "Ontario Trillium Fund analysis"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Introduction", tabName = "Introduction", icon = icon("dashboard")),
            menuItem("Summary", tabName = "Summary", icon = icon("dashboard")),
            menuItem("Trends", tabName = "Trends", icon = icon("th")),
            menuItem("Cohort Analysis", tabName = "CohortAnalysis", icon = icon("dashboard")),
            menuItem("Text Analysis", tabName = "TextAnalysis", icon = icon("th")),
            menuItem("Text Classification", tabName = "TextClassification", icon = icon("dashboard")),
            
        )
    ),
    dashboardBody(
        tabItems(
            tabItem(tabName = "Introduction",includeMarkdown("intro.md")
            ),
            tabItem(tabName = "Summary",
                    )
            )
    )
)

server <- function(input, output) { }

shinyApp(ui, server)
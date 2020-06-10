

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


yearInfo <- length(unique(df$year))
grantInfo <- length(unique(df$grant_program2))
organizationInfo <- length(unique(df$organization_name))
amountAwardedInfo <- sum(df$amount_awarded)
ageGroupInfo <- length(unique(df$age_group2))
budgetInfo <- length(unique(df$budget_fund))

#app
ui <- dashboardPage(
    dashboardHeader(title = "Ontario Trillium Fund analysis"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Introduction", tabName = "Introduction", icon = icon("dashboard")),
            menuItem("Summary", tabName = "Summary", icon = icon("dashboard")),
            menuItem("Trends", tabName = "Trends", icon = icon("th")),
            menuItem("Text Analysis", tabName = "TextAnalysis", icon = icon("th")),
            menuItem("Text Classification", tabName = "TextClassification", icon = icon("dashboard"))
            
        )
    ),
    dashboardBody(
        tabItems(
            tabItem(tabName = "Introduction",includeMarkdown("intro.md")),
            tabItem(tabName = "Summary",
                    
                    fluidRow(
                        infoBoxOutput("yearInfo"),
                        infoBoxOutput("grantInfo")
                    ),
                    fluidRow(
                        infoBoxOutput("organizationalInfo"),
                        infoBoxOutput("amountAwardedInfo")
                    ), 
                    fluidRow(
                        infoBoxOutput("areaInfo"),
                        infoBoxOutput("budgetInfo")
                    )
            ),
            tabItem(tabName = "Trends",
                
            )
        )
    )
)


server <- function(input, output) {
    
    # of years
    output$yearInfo <- renderInfoBox({
        infoBox(
            "# of Years", paste0(yearInfo), icon = icon("list"),
            color = "blue"
        )
    })
    
    # grant information
    output$grantInfo <- renderInfoBox({
        infoBox(
            "Type of Grants", paste0(grantInfo), icon = icon("list"),
            color = "blue", fill = TRUE
        )
    })
    
    # of organizations
    output$organizationalInfo <- renderInfoBox({
        infoBox(
            "# of Organizations", paste0(organizationInfo), icon = icon("list"),
            color = "blue"
        )
    })
    
    # dollar amount
    output$amountAwardedInfo <- renderInfoBox({
        infoBox(
            "$ value of grants awarded", paste0(amountAwardedInfo, " CAD"), icon = icon("list"),
            color = "blue", fill = TRUE
        )
    })
    
    #types of budget
    output$budgetInfo <- renderInfoBox({
        infoBox(
            "Types of budget", paste0(budgetInfo), icon = icon("list"),
            color = "blue"
        )
    })    
    
    # of cities for summary page
    output$areaInfo <- renderInfoBox({
        infoBox(
            "# of places covered by grants", paste0(amountAwardedInfo), icon = icon("list"),
            color = "blue", fill = TRUE
        )
    })
    

    
    #cohort analysis by project
    
    #visualizations

}

shinyApp(ui, server)
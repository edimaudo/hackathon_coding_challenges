#=============
# Kiva Application
#=============

rm(list = ls()) # Clear environment

#=============
# Package Information
#=============
packages <- c('ggplot2', 'corrplot','tidyverse','readxl',
              'shiny','shinydashboard','scales','dplyr','mlbench','caTools',
              'forecast','TTR','xts','lubridate')
for (package in packages) {
    if (!require(package, character.only=T, quietly=T)) {
        install.packages(package)
        library(package, character.only=T)
    }
}

#=============
# UI 
#=============

#=============
# UI drop-down
#=============
sector <- c(sort(unique(loans$SECTOR_NAME)))
country <- c(sort(unique(loans$COUNTRY_NAME)))
lender_term <- c(sort(unique(loans$LENDER_TERM)))
repayment_interval <- c(sort(unique(loans$REPAYMENT_INTERVAL)))
#=============
# UI Layout 
#=============
ui <- dashboardPage(
  dashboardHeader(title = "Patient Forecast"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Data", tabName = "data", icon = icon("th")),
      menuItem("Analysis", tabName = "analysis", icon = icon("th")),
      menuItem("Forecasting", tabName = "Forecast", icon = icon("th"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "data",
              sidebarLayout(
                sidebarPanel(
                  fileInput("file1", "Choose CSV File", accept = ".csv"),
                  checkboxInput("header", "Header", TRUE)
                ),
                mainPanel(
                  tableOutput("contents")
                )
              )
      ),
      tabItem(tabName = "analysis",
              sidebarLayout(
                sidebarPanel(
                  selectInput("aggregateInput", "Aggregate", 
                              choices = aggregate_info, selected = 'daily'),
                  selectInput("frequencyInput", "Frequency", 
                              choices = frequency_info, selected = 7),
                  radioButtons("differenceInput","Difference",
                               choices = difference_info, selected = "No"),
                  numericInput("differenceNumericInput", "Difference Input", 
                               1, min = 1, max = 52, step = 0.5),
                  radioButtons("logInput","Log",
                               choices = log_info, selected = "No"),
                  submitButton("Submit")
                ),
                mainPanel(
                  h1("Analysis",style="text-align: center;"), 
                  tabsetPanel(type = "tabs",
                              tabPanel(
                                h4("Decomposition",
                                   style="text-align: center;"),
                                plotOutput("decompositionPlot")),
                              tabPanel(
                                h4("Multi seasonal Decomposition",
                                   style="text-align: center;"),
                                plotOutput("multidecompositionPlot")),
                              tabPanel(
                                h4("ACF Plot",style="text-align: center;"), 
                                plotOutput("acfPlot")),
                              tabPanel(
                                h4("PACF Plot",style="text-align: center;"), 
                                plotOutput("pacfPlot"))
                  )
                )
              )  
      )
    )
  )
)

#=============
# Define server logic 
#=============
server <- function(input, output,session) {

}

shinyApp(ui, server)

#portfolio optimization using loan data
# by sector

# by country

#other factors (lender term, repayment interval, distribution model)


#loan impact using sroi framework

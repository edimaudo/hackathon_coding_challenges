#=============
# Kiva Application
#=============
rm(list = ls()) # Clear environment
#=============
# Package Information
#=============
packages <- c('ggplot2', 'corrplot','tidyverse','readxl',
              'shiny','shinydashboard','scales','dplyr','mlbench','caTools',
              "dummies",'readxl','forecast','TTR','xts','lubridate','data.table')
for (package in packages) {
    if (!require(package, character.only=T, quietly=T)) {
        install.packages(package)
        library(package, character.only=T)
    }
}
#=============
# data
#=============
df <- data.table::fread("loans.csv")
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
ui <- dashboardPage(skin = "green",
  dashboardHeader(title = "Kiva Application"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("About", tabName = "about", icon = icon("th")),
      menuItem("Data Insights", tabName = "analysis", icon = icon("th")),
      menuItem("Fund analysis", tabName = "fund", icon = icon("th")),
      menuItem("Loan Impact", tabName = "loan", icon = icon("th"))
    )
  ),
  dashboardBody(
      tabPanel("about",
               includeMarkdown("about.md"),
               hr()),
      tabItems(
        
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

#===============
#TO DO
#- BUILD ABOUT
#- LOAD DATA + INFO
#- BUILD preliminary UI LAYOUT

#- BUILD UI LAYOUT
# - Fund distribution - How might we optimize fund distribution to borrowers?
# - Loan impact - How might we show the impact of the loans?
# - Test model

  
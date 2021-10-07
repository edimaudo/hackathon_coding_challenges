#portfolio optimization using loan data
# by sector
# by country
# other factors (lender term, repayment interval, distribution model)

#impact modeling
#loan impact using sroi framework

#===============
#TO DO
#- BUILD UI LAYOUT
# - Fund distribution - How might we optimize fund distribution to borrowers?
# - Loan impact - How might we show the impact of the loans?
# - Test model


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
sector <- c(sort(unique(df$SECTOR_NAME)))
country <- c(sort(unique(df$COUNTRY_NAME)))
lender_term <- c(sort(unique(df$LENDER_TERM)))
repayment_interval <- c(sort(unique(df$REPAYMENT_INTERVAL)))
#=============
# UI Layout 
#=============
ui <- dashboardPage(skin = "green",
  dashboardHeader(title = "Kiva Application"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("About", tabName = "about", icon = icon("th")),
      #menuItem("Data Insights", tabName = "insights", icon = icon("th")),
      menuItem("Fund analysis", tabName = "fund", icon = icon("th")),
      menuItem("Loan Impact", tabName = "loan", icon = icon("th"))
    )
  ),
  dashboardBody(
               tabItems(
                 tabItem(tabName = "about",includeMarkdown("about.md"),hr()),
                 tabItem(tabName = "fund",
                         sidebarLayout(
                           sidebarPanel(
                             # selectInput("aggregateInput", "Aggregate", 
                             #             choices = aggregate_info, selected = 'weekly'),
                             # selectInput("typeInput", "Type", 
                             #             choices = type_info,selected = "All"),
                             # selectInput("regionInput", "Region", 
                             #             choices = region_info, selected = "All"),
                             # selectInput("frequencyInput", "Frequency", 
                             #             choices = frequency_info, selected = 7),
                             # selectInput("horizonInput", "Forecast Horizon", 
                             #             choices = horizon_info, selected = 12),
                             # selectInput("modelInput", "Model", 
                             #             choices = model_info, selected = 'auto exponential'),
                             submitButton("Submit")
                           ),
                           mainPanel(
                             h2("Revenue Forecast Analysis",style="text-align: center;"), 
                             fluidRow(
                               h3("Forecast Plot",style="text-align: center;"),
                               #plotOutput("forecastPlot"),
                               br()#,
                               #h3("Forecast Accuracy",style="text-align: center;"),
                               #DT::dataTableOutput("accuracyOutput")
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



  
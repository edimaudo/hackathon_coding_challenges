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
packages <- c('ggplot2', 'corrplot','tidyverse','readxl','doParallel',
              'shiny','shinydashboard','scales','dplyr','mlbench','caTools','RColorBrewer',
              "dummies",'readxl','forecast','TTR','xts','lubridate','data.table','timetk')
for (package in packages) {
    if (!require(package, character.only=T, quietly=T)) {
        install.packages(package)
        library(package, character.only=T)
    }
}
#=============
# data
#=============
cl <- makePSOCKcluster(4)
registerDoParallel(cl)
df <- data.table::fread("loans.csv")
stopCluster(cl)
#=============
# UI drop-down
#=============
sector <- c("All", c(sort(unique(df$SECTOR_NAME))))
country <- c("All", c(sort(unique(df$COUNTRY_NAME))))
lender_term <- c("All", c(sort(unique(df$LENDER_TERM))))
repayment_interval <-
  c("All", c(sort(unique(
    df$REPAYMENT_INTERVAL
  ))))

#=============
# UI Layout
#=============
ui <- dashboardPage(
  skin = "green",
  dashboardHeader(title = "Kiva Application"),
  dashboardSidebar(sidebarMenu(
    menuItem("About", tabName = "about", icon = icon("th")),
    menuItem("Fund analysis", tabName = "fund", icon = icon("th")),
    menuItem("Loan Impact", tabName = "loan", icon = icon("th"))
  )),
  dashboardBody(tabItems(
    tabItem(tabName = "about", includeMarkdown("about.md"), hr()),
    tabItem(tabName = "fund",
            sidebarLayout(
              sidebarPanel(
                selectInput(
                  "sectorInput",
                  "Sector",
                  choices = sector,
                  selected = 'All'
                ),
                selectInput(
                  "countryInput",
                  "Country",
                  choices = country,
                  selected = "All"
                ),
                selectInput(
                  "lenderInput",
                  "Lender Term",
                  choices = lender_term,
                  selected = "All"
                ),
                selectInput(
                  "repaymentInput",
                  "Repayment Interval",
                  choices = repayment_interval,
                  selected = "All"
                ),
                submitButton("Submit")
              ),
              mainPanel(
                h2("Portfolio Breakdown", style = "text-align: center;"),
                fluidRow(
                  h3("Minimum Variance Portfolio", style = "text-align: center;"),
                  plotOutput("minvarPlot"),
                  br(),
                  h3("Efficient Portfolio", style = "text-align: center;"),
                  plotOutput("efficientPlot"),
                )
              )
            ))
  ))
  
)




#=============
# Define server logic 
#=============
server <- function(input, output,session) {

  # min variance portfolio
  output$minvarPlot <- renderPlot({
    
  })
  
  # efficiency portfolio
  output$efficientPlot <- renderPlot({
    
  })
  
}

shinyApp(ui, server)



  
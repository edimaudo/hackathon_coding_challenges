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
country <- c("All", c(sort(unique(df$COUNTRY_NAME))))
#lender_term <- c("All", c(sort(unique(df$LENDER_TERM))))
#repayment_interval <-c("All", c(sort(unique(df$REPAYMENT_INTERVAL))))
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
                selectInput("countryInput","Country",choices = country,selected = "All"),
                #selectInput("lenderInput","Lender Term",choices = lender_term,selected = "All"),
                #sliderInput("lenderInput","Lender Term",min = 1, max = 195, value = 10),
                #selectInput("repaymentInput","Repayment Interval",choices = repayment_interval,selected = "All"),
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
  
  #filter by funded and clean up dates
  funds_df <- df %>%
    filter(STATUS == 'funded') %>%
    select(FUNDED_AMOUNT, SECTOR_NAME, COUNTRY_NAME,DISBURSE_TIME) %>%
    na.omit()
  funds_df$DISBURSE_DATE <- as.Date(funds_df$DISBURSE_TIME)
  funds_df$DISBURSE_TIME <- NULL
  
  # filter by country information
  if (input$countryInput != "All"){
    funds_df2 <- funds_df %>% 
      filter(COUNTRY_NAME == input$countryInput) %>%
      group_by(SECTOR_NAME, DISBURSE_DATE) %>%
      dplyr::summarise(TOTAL_FUNDED_AMOUNT = sum(FUNDED_AMOUNT)) %>%
      select(SECTOR_NAME, DISBURSE_DATE,TOTAL_FUNDED_AMOUNT)
  } else {
    funds_df2 <- funds_df %>% 
      group_by(SECTOR_NAME, DISBURSE_DATE) %>%
      dplyr::summarise(TOTAL_FUNDED_AMOUNT = sum(FUNDED_AMOUNT)) %>%
      select(SECTOR_NAME, DISBURSE_DATE,TOTAL_FUNDED_AMOUNT)    
  }
  
  # create time series
  funds_df_xts <- funds_df2 %>%
    spread(SECTOR_NAME, value = TOTAL_FUNDED_AMOUNT) %>%
    tk_xts()
  funds_df_xts[is.na(funds_df_xts)] <- 0
  
  # remove dataframes
  funds_df <- NULL
  funds_df2 <- NULL
  
  
  # min variance portfolio
  output$minvarPlot <- renderPlot({
    

    
  })
  
  # efficiency portfolio
  output$efficientPlot <- renderPlot({
    
  })
  
}

shinyApp(ui, server)



  
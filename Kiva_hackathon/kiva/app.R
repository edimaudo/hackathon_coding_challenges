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
# Load data
#=============
#cl <- makePSOCKcluster(4)
#registerDoParallel(cl)
df <- data.table::fread("loans.csv")
#stopCluster(cl)
#=============
# UI drop-down
#=============
country <- c("All", c(sort(unique(df$COUNTRY_NAME))))
sector <- c("All",c(sort(unique(df$SECTOR_NAME))))
#=============
# UI Layout
#=============
ui <- dashboardPage(
  skin = "green",
  dashboardHeader(title = "Kiva Application"),
  dashboardSidebar(sidebarMenu(
    menuItem("About", tabName = "about", icon = icon("th")),
    menuItem("Sector Insights", tabName = "sector", icon = icon("th")),
    menuItem("Fund Distribution", tabName = "fund", icon = icon("th")),
    menuItem("Loan Impact", tabName = "loan", icon = icon("th"))
  )),
  dashboardBody(tabItems(
    #====About====
    tabItem(tabName = "about", includeMarkdown("about.md"), hr()),
    #====Sector====
    tabItem(tabName = "sector",
            sidebarLayout(
              sidebarPanel(
                selectInput("countryInput","Country",choices = country,selected = "All"),
                submitButton("Submit")
              ),
              mainPanel(
                h2("Sector Insight", style = "text-align: center;"),
                fluidRow(
                  column(2,
                         h3("Sector Count", style = "text-align: center;"),
                         plotOutput("sectorCountPlot"),
                         h3("Sector Count", style = "text-align: center;"),
                         plotOutput("lenderSectorPlot")
                  )
                ),
                fluidRow(
                  column(2,
                         h3("Sector Count", style = "text-align: center;"),
                         plotOutput("sectorCountPlot"),
                         h3("Sector Count", style = "text-align: center;"),
                         plotOutput("lenderSectorPlot")
                         
                  )

                  )
                  
                )
              )
            ),
    #====Fund====
    tabItem(tabName = "fund",
            sidebarLayout(
              sidebarPanel(
                selectInput("countryInput","Country",choices = country,selected = "All"),
                submitButton("Submit")
              ),
              mainPanel(
                h2("Portfolio Breakdown", style = "text-align: center;"),
                fluidRow(
                  h3("Efficient Portfolio", style = "text-align: center;"),
                  plotOutput("efficientPlot"),
                  br(),
                  h3("Minimum Variance Portfolio", style = "text-align: center;"),
                  plotOutput("minvarPlot"),
                )
              )
            )
          ), 
    #====Loan====
    tabItem(tabName = "loan",
            sidebarLayout(
              sidebarPanel(
                selectInput("countryInput","Country",choices = country,selected = "All"),
                sliderInput("yearInput", "Year",min = 1,max = 30,value = 5, step = 1),
                sliderInput("discountInput", "Discount Rate (%)",min = 1,max = 100,value = 50, step = 5),
                submitButton("Submit")
              ),
              mainPanel(
                h2("Loan Impact", style = "text-align: center;"),
                fluidRow(
                  h3("SROI Model", style = "text-align: center;"),
                  DT::dataTableOutput("loanOutput")
            )
          )
        )
    )
  )
 )
)

#=============
# Server logic 
#=============
server <- function(input, output,session) {
  
  #filter by funded and clean up dates
  funds_df <- df %>%
    filter(STATUS %in% c('funded','fundRaising')) %>%
    select(FUNDED_AMOUNT, SECTOR_NAME, COUNTRY_NAME,DISBURSE_TIME) %>%
    na.omit()
  funds_df$DISBURSE_DATE <- as.Date(funds_df$DISBURSE_TIME)
  #funds_df$DISBURSE_TIME <- NULL
  
  #=============
  # min variance portfolio
  #=============
  output$minvarPlot <- renderPlot({
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
    
    # remove dataframe
    funds_df <- NULL
    funds_df2 <- NULL
    
    # mean daily loans
    mean_ret <- colMeans(funds_df_xts)
    
    # covariance matrix with annualization
    cov_mat <- cov(funds_df_xts) * 252
    
    #simulation of 10000 portfolios
    num_port <- 10000
    # Creating a matrix to store the weights
    all_wts <- matrix(nrow = num_port,ncol = length(column_info))
    # Portfolio returns
    port_returns <- vector('numeric', length = num_port)
    # Portfolio Standard deviation
    port_risk <- vector('numeric', length = num_port)
    # Portfolio Sharpe Ratio
    sharpe_ratio <- vector('numeric', length = num_port)
    
    set.seed(1)
    # simulation
    for (i in seq_along(port_returns)) {
      
      wts <- runif(length(column_info))
      wts <- wts/sum(wts)
      
      # Storing weight in the matrix
      all_wts[i,] <- wts
      
      # Portfolio returns
      port_ret <- sum(wts * mean_ret)
      port_ret <- ((port_ret + 1)^252) - 1
      
      # Storing Portfolio Returns values
      port_returns[i] <- port_ret
      
      # Creating and storing portfolio risk
      port_sd <- sqrt(t(wts) %*% (cov_mat  %*% wts))
      port_risk[i] <- port_sd
      
      # Creating and storing Portfolio Sharpe Ratios
      # Assuming 0% Risk free rate
      sr <- port_ret/port_sd
      sharpe_ratio[i] <- sr
      
    }
    
    # Storing the values in the table
    portfolio_values <- tibble(Return = port_returns,
                               Risk = port_risk,
                               SharpeRatio = sharpe_ratio)
    
    # Converting matrix to a tibble and changing column names
    all_wts <- tk_tbl(all_wts)
    column_info <- unique(column_info)
    colnames(all_wts) <- column_info
    
    # Combing all the values together
    portfolio_values <- tk_tbl(cbind(all_wts, portfolio_values))
    
    # Next lets look at the portfolios that matter the most.
    # - The minimum variance portfolio
    # - The tangency portfolio (the portfolio with highest sharpe ratio)
    min_var <- portfolio_values[which.min(portfolio_values$Risk),]
    #max_sr <- portfolio_values[which.max(portfolio_values$SharpeRatio),]   
    
    min_var %>%
      gather(Agriculture:Wholesale, key = Sector,
             value = Weights) %>%
      mutate(Sector = as.factor(Sector)) %>%
      ggplot(aes(x = fct_reorder(Sector,Weights), y = Weights, fill = Sector)) +
      geom_bar(stat = 'identity') +
      theme_minimal() + coord_flip() + 
      labs(x = 'Sectors', y = 'Weights') +
      scale_y_continuous(labels = scales::percent)   
    
    # add error handler since some countries don't yield any result
  })
  #=============
  # efficiency portfolio
  #=============
  output$efficientPlot <- renderPlot({
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
    
    # remove dataframe
    funds_df <- NULL
    funds_df2 <- NULL
    
    # mean daily loans
    mean_ret <- colMeans(funds_df_xts)
    
    # covariance matrix with annualization
    cov_mat <- cov(funds_df_xts) * 252
    
    #simulation of 10000 portfolios
    num_port <- 10000
    # Creating a matrix to store the weights
    all_wts <- matrix(nrow = num_port,ncol = length(column_info))
    # Portfolio returns
    port_returns <- vector('numeric', length = num_port)
    # Portfolio Standard deviation
    port_risk <- vector('numeric', length = num_port)
    # Portfolio Sharpe Ratio
    sharpe_ratio <- vector('numeric', length = num_port)
    
    set.seed(1)
    # simulation
    for (i in seq_along(port_returns)) {
      
      wts <- runif(length(column_info))
      wts <- wts/sum(wts)
      
      # Storing weight in the matrix
      all_wts[i,] <- wts
      
      # Portfolio returns
      port_ret <- sum(wts * mean_ret)
      port_ret <- ((port_ret + 1)^252) - 1
      
      # Storing Portfolio Returns values
      port_returns[i] <- port_ret
      
      # Creating and storing portfolio risk
      port_sd <- sqrt(t(wts) %*% (cov_mat  %*% wts))
      port_risk[i] <- port_sd
      
      # Creating and storing Portfolio Sharpe Ratios
      # Assuming 0% Risk free rate
      sr <- port_ret/port_sd
      sharpe_ratio[i] <- sr
      
    }
    
    # Storing the values in the table
    portfolio_values <- tibble(Return = port_returns,
                               Risk = port_risk,
                               SharpeRatio = sharpe_ratio)
    
    # Converting matrix to a tibble and changing column names
    all_wts <- tk_tbl(all_wts)
    column_info <- unique(column_info)
    colnames(all_wts) <- column_info
    
    # Combing all the values together
    portfolio_values <- tk_tbl(cbind(all_wts, portfolio_values))
    
    # Next lets look at the portfolios that matter the most.
    # - The minimum variance portfolio
    # - The tangency portfolio (the portfolio with highest sharpe ratio)
    #min_var <- portfolio_values[which.min(portfolio_values$Risk),]
    max_sr <- portfolio_values[which.max(portfolio_values$SharpeRatio),]   
    
    max_sr %>%
      gather(column_info, key = Sector,
             value = Weights) %>%
      mutate(Sector = as.factor(Sector)) %>%
      ggplot(aes(x = fct_reorder(Sector,Weights), y = Weights, fill = Sector)) +
      geom_bar(stat = 'identity') + 
      theme_minimal() + coord_flip() + 
      labs(x = 'Sectors', y = 'Weights') +
      scale_y_continuous(labels = scales::percent) 
  
    # add error handler since some countries don't yield any result
    })
  #=============
  # SROI model
  #=============
  output$loanOutputOutput <- DT::renderDataTable({
    
  })
  
  
  #=============
  # SECTOR COUNT
  #=============
  output$sectorCountPlot <- renderPlot({
    if (input$countryInput != "All"){
      sector_df <- loans %>%
        filter(COUNTRY_NAME == input$countryInput,STATUS %in% c('funded','fundRaising')) %>%
        dplyr::group_by(SECTOR_NAME) %>%
        dplyr::summarise(count = n()) %>%
        select(SECTOR_NAME, count)
    } else {
      sector_df <- loans %>%
        filter(STATUS %in% c('funded','fundRaising')) %>%
        dplyr::group_by(SECTOR_NAME) %>%
        dplyr::summarise(count = n()) %>%
        select(SECTOR_NAME, count)
    }    
  
    ggplot(sector_df,aes(x=reorder(SECTOR_NAME, count),y=count, fill = SECTOR_NAME)) +
      geom_bar(stat = "identity") + theme_minimal() + scale_y_continuous(labels = comma) +
      coord_flip() + xlab("Sectors") + 
      ylab("Count") + guides(fill = FALSE)
  })
  
  #=============
  # # AVG NUM OF LENDERS BY SECTOR
  #=============
  output$lenderSectorPlot <- renderPlot({
    
    if (input$countryInput != "All"){
      sectors_lender_df <- loans %>%
        filter(COUNTRY_NAME == input$countryInput,STATUS %in% c('funded','fundRaising')) %>%
        dplyr::group_by(SECTOR_NAME) %>%
        dplyr::summarise(AVG_NUM_LENDERS = mean(NUM_LENDERS_TOTAL)) %>%
        select(SECTOR_NAME, AVG_NUM_LENDERS)
    } else {
      sectors_lender_df <- loans %>%
        filter(STATUS %in% c('funded','fundRaising')) %>%
        dplyr::group_by(SECTOR_NAME) %>%
        dplyr::summarise(AVG_NUM_LENDERS = mean(NUM_LENDERS_TOTAL)) %>%
        select(SECTOR_NAME, AVG_NUM_LENDERS)      
    }
    ggplot(data = sectors_lender_df,aes(x=SECTOR_NAME, y=AVG_NUM_LENDERS, fill = SECTOR_NAME)) +
      geom_bar(stat = "identity") + theme_minimal()  + scale_y_continuous(labels = comma) 
    coord_flip() + xlab("Sector Name") + 
      ylab("Average No. of Lenders") + guides(fill = FALSE)
    
  })
  
  #=============
  # # AVG LENDER TERM BY SECTOR
  #=============
  output$lenderTermSectorPlot <- renderPlot({})
  
  #=============
  # FUNDED AMOUNT BY SECTOR
  #=============
  output$fundSectorPlot <- renderPlot({})
  
  #=============
  # DISTRIBUTION MODEL BY SECTOR
  #=============
  output$distributionSectorPlot <- renderPlot({})
  
  #=============
  # REPAYMENT INTERVAL BY SECTOR
  #=============
  output$repaymentSectorPlot <- renderPlot({})
  
  #=============
  # AVERAGE LOAN TIMEFRAME BY SECTOR
  #=============
  output$loanSectorPlot <- renderPlot({})
  
  #=============
  # FUNDED LOANS YEAR AND BY SECTOR
  #=============
  output$fundedLoansSectorPlot <- renderPlot({})
}

shinyApp(ui, server)



  
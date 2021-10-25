#=============
# Kiva Insights
#=============
rm(list = ls()) # Clear environment
#=============
# Package Information
#=============
packages <- c('ggplot2', 'corrplot','tidyverse','doParallel','memoise','qs',
              'shiny','shinydashboard','scales','dplyr','mlbench','caTools',
              "dummies",'forecast','TTR','xts','lubridate','data.table','timetk')
for (package in packages) {
    if (!require(package, character.only=T, quietly=T)) {
        install.packages(package)
        library(package, character.only=T)
    }
}
#=============
# Load data
#=============
loans <-  qread("loans.qs") #read.csv("loans2.csv") 
# Update loan data

loans$LENDER_TERM[is.na(loans$LENDER_TERM)] <- 0
loans$POSTED_DISBURSED_TIME <- as.Date(loans$DISBURSE_TIME) - as.Date(loans$POSTED_TIME)
loans$POSTED_DISBURSED_TIME[is.na(loans$POSTED_DISBURSED_TIME )] <- 0
loans$DISBURSE_TIME <- as.Date(loans$DISBURSE_TIME)
column_info <- c(sort(unique(loans$SECTOR_NAME))) # sector information

# Fund distribution
funds_df2 <- loans %>%
  filter(STATUS %in% c('funded','fundRaising')) %>%
  group_by(SECTOR_NAME, DISBURSE_TIME) %>%
  dplyr::summarise(TOTAL_FUNDED_AMOUNT = sum(FUNDED_AMOUNT)) %>%
  na.omit() %>%
  select(SECTOR_NAME, DISBURSE_TIME,TOTAL_FUNDED_AMOUNT) 

# SROI
loan_df2 <- loans %>%
  filter(STATUS %in% c('funded','fundRaising')) %>%
  na.omit() %>%
  dplyr::group_by(ACTIVITY_NAME) %>%
  dplyr::summarise(TOTAL_FUNDED_AMOUNT = sum(FUNDED_AMOUNT)) %>%
  select(ACTIVITY_NAME,TOTAL_FUNDED_AMOUNT) 
#=============
# UI drop-down
#=============
country <- c("All", c(sort(unique(loans$COUNTRY_NAME))))
sector <- c("All",c(sort(unique(loans$SECTOR_NAME))))
#=============
# UI Layout
#=============
ui <- dashboardPage(
  skin = "green",
  dashboardHeader(title = "KivaInsights"),
  dashboardSidebar(sidebarMenu(
    menuItem("About", tabName = "about", icon = icon("th")),
    menuItem("Sector Insights", tabName = "sector", icon = icon("th")),
    menuItem("Fund Distribution", tabName = "fund", icon = icon("th")),
    menuItem("Loan Impact", tabName = "loan", icon = icon("th"))
  )),
  dashboardBody(tabItems(
    #====About====
    tabItem(tabName = "about", includeMarkdown("about.md"), hr()),
    #====Sector Insights====
    tabItem(tabName = "sector",
            sidebarLayout(
              sidebarPanel(
                selectInput("countryInput","Country",choices = country,selected = "All"),
                submitButton("Submit")
              ),
              mainPanel(
                h2("Sector Insights", style = "text-align: center;"),
                fluidRow(
                         h3("Sector Count", style = "text-align: center;"),
                         plotOutput("sectorCountPlot"),
                         h3("# of Lenders by Sector", style = "text-align: center;"),
                         plotOutput("lenderSectorPlot"),
                         h3("Lenders Term by Sector", style = "text-align: center;"),
                         plotOutput("lenderTermSectorPlot"),
                         h3("Fund Amount by Sector", style = "text-align: center;"),
                         plotOutput("fundSectorPlot"),
                         h3("Distribution by Sector", style = "text-align: center;"),
                         plotOutput("distributionSectorPlot"),
                         h3("Repayment Interval by Sector", style = "text-align: center;"),
                         plotOutput("repaymentSectorPlot"),
                         h3("Average Loan period by Sector", style = "text-align: center;"),
                         plotOutput("loanTimeSectorPlot"),
                         h3("Funded Loan Heatmap", style = "text-align: center;"),
                         plotOutput("fundedLoansSectorPlot")
                  )
                )
              )
            ),
    #====Fund Distribution====
    tabItem(tabName = "fund",
            sidebarLayout(
              sidebarPanel(
                selectInput("countryFundInput","Country",choices = country,selected = "All"), 
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
            )
          ), 
    #====Loan Impact====
    tabItem(tabName = "loan",
            sidebarLayout(
              sidebarPanel(
                selectInput("sectorLoanInput","Sector",choices = sector,selected = "All"),
                selectInput("countryLoanInput","Country",choices = country,selected = "All"),
                sliderInput("yearInput", "Year",min = 0,max = 15,value = 5, step = 1),
                sliderInput("reductionInput", "Reduction Rate (%)",min = 0,max = 100,value = 10, step = 10),
                sliderInput("discountInput", "Discount Rate (%)",min = 0,max = 100,value = 5, step = 10),
                submitButton("Submit")
              ),
              mainPanel(
                h2("SROI Model", style = "text-align: center;"),
                fluidRow(
                  valueBoxOutput("countryBox"),
                  valueBoxOutput("sectorBox"),
                  valueBoxOutput("sroiBox")
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
server <- function(input, output) {
  
  #------------------------------
  # Fund Distribution
  #------------------------------
  
  #=============
  # Minimum Variance Portfolio
  #=============
  output$minvarPlot <- renderPlot({
    # filter by country information
    if (input$countryFundInput != "All"){
      funds_df2 <- loans %>% 
        filter(STATUS %in% c('funded','fundRaising'),COUNTRY_NAME == input$countryFundInput) %>%
        group_by(SECTOR_NAME, DISBURSE_TIME) %>%
        dplyr::summarise(TOTAL_FUNDED_AMOUNT = sum(FUNDED_AMOUNT)) %>%
        na.omit() %>%
        select(SECTOR_NAME, DISBURSE_TIME,TOTAL_FUNDED_AMOUNT) 
    }
    
    column_info <- c(sort(unique(funds_df2$SECTOR_NAME)))
    
      # create time series
      funds_df_xts <- funds_df2 %>%
        spread(SECTOR_NAME, value = TOTAL_FUNDED_AMOUNT) %>%
        tk_xts()
      funds_df_xts[is.na(funds_df_xts)] <- 0

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

      # - The minimum variance portfolio
      min_var <- portfolio_values[which.min(portfolio_values$Risk),]
      length_info <- ncol(min_var)-3

      min_var %>%
        gather(colnames(min_var)[1:length_info], key = Sector,
               value = Weights) %>%
        mutate(Sector = as.factor(Sector)) %>%
        ggplot(aes(x = fct_reorder(Sector,Weights), y = Weights, fill = Sector)) +
        geom_bar(stat = 'identity') +
        theme_minimal()  + theme(axis.text.x = element_text(size = 12),
                                 axis.text.y = element_text(size = 12),
                                 axis.title.x = element_text(size = 14, face = "bold"),
                                 axis.title.y = element_text(size = 14, face = "bold")) + coord_flip() +
        labs(x = 'Sectors', y = 'Weights') +
        scale_y_continuous(labels = scales::percent) + theme(legend.position="none")
    
  })
  #=============
  # Efficient Portfolio
  #=============
  output$efficientPlot <- renderPlot({
    # filter by country information
    if (input$countryFundInput != "All"){
      funds_df2 <- loans %>% 
        filter(STATUS %in% c('funded','fundRaising'),COUNTRY_NAME == input$countryFundInput) %>%
        group_by(SECTOR_NAME, DISBURSE_TIME) %>%
        dplyr::summarise(TOTAL_FUNDED_AMOUNT = sum(FUNDED_AMOUNT)) %>%
        na.omit() %>%
        select(SECTOR_NAME, DISBURSE_TIME,TOTAL_FUNDED_AMOUNT) 
    }
    column_info <- c(sort(unique(funds_df2$SECTOR_NAME)))
    
   # if (!dim(funds_df2)[1] == 0) 
      # create time series
      funds_df_xts <- funds_df2 %>%
        spread(SECTOR_NAME, value = TOTAL_FUNDED_AMOUNT) %>%
        tk_xts()
      funds_df_xts[is.na(funds_df_xts)] <- 0
      
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
      # - The tangency portfolio (the portfolio with highest sharpe ratio)
      max_sr <- portfolio_values[which.max(portfolio_values$SharpeRatio),]   
      length_info <- ncol(max_sr)-3
      
      max_sr %>%
        gather(colnames(max_sr)[1:length_info], key = Sector,
               value = Weights) %>%
        mutate(Sector = as.factor(Sector)) %>%
        ggplot(aes(x = fct_reorder(Sector,Weights), y = Weights, fill = Sector)) +
        geom_bar(stat = 'identity') + 
        theme_minimal()  + theme(axis.text.x = element_text(size = 12), 
                                 axis.text.y = element_text(size = 12), 
                                 axis.title.x = element_text(size = 14, face = "bold"), 
                                 axis.title.y = element_text(size = 14, face = "bold")) + coord_flip() + 
        labs(x = 'Sectors', y = 'Weights') +
        scale_y_continuous(labels = scales::percent) + theme(legend.position="none")    
      
    })
  
  
  #------------------------------
  # Sector Insights
  #------------------------------
  
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
      geom_bar(stat = "identity") + theme_minimal()  + theme(axis.text.x = element_text(size = 12),
                                                             axis.text.y = element_text(size = 12),
                                                             axis.title.x = element_text(size = 14, face = "bold"),
                                                             axis.title.y = element_text(size = 14, face = "bold")) +
      scale_y_continuous(labels = comma) +
      coord_flip() + xlab("Sectors") + 
      ylab("Count") + theme(legend.position="none")
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
    ggplot(data = sectors_lender_df,aes(x=reorder(SECTOR_NAME,AVG_NUM_LENDERS), y=AVG_NUM_LENDERS, 
                                        fill = SECTOR_NAME)) +
      geom_bar(stat = "identity") + theme_minimal()  + theme(axis.text.x = element_text(size = 12),
                                                             axis.text.y = element_text(size = 12),
                                                             axis.title.x = element_text(size = 14, face = "bold"),
                                                             axis.title.y = element_text(size = 14, face = "bold"))  + 
      scale_y_continuous(labels = comma) +
      coord_flip() + xlab("Sectors") + 
      ylab("Average No. of Lenders") + theme(legend.position="none")
    
  })
  
  #=============
  # # AVG LENDER TERM BY SECTOR
  #=============
  output$lenderTermSectorPlot <- renderPlot({
    if (input$countryInput != "All"){
      sectors_lender_term_df <- loans %>%
        filter(COUNTRY_NAME == input$countryInput,STATUS %in% c('funded','fundRaising')) %>%
        dplyr::group_by(SECTOR_NAME) %>%
        dplyr::summarise(AVG_NUM_LENDERS_TERM = mean(LENDER_TERM)) %>%
        select(SECTOR_NAME, AVG_NUM_LENDERS_TERM)
    } else {
      sectors_lender_term_df <- loans %>%
        filter(STATUS %in% c('funded','fundRaising')) %>%
        dplyr::group_by(SECTOR_NAME) %>%
        dplyr::summarise(AVG_NUM_LENDERS_TERM = mean(LENDER_TERM)) %>%
        select(SECTOR_NAME, AVG_NUM_LENDERS_TERM)     
    }
    ggplot(data = sectors_lender_term_df,aes(x=reorder(SECTOR_NAME,AVG_NUM_LENDERS_TERM), 
                                             y=AVG_NUM_LENDERS_TERM, fill = SECTOR_NAME)) +
      geom_bar(stat = "identity") + theme_minimal()  + theme(axis.text.x = element_text(size = 12),
                                                             axis.text.y = element_text(size = 12),
                                                             axis.title.x = element_text(size = 14, face = "bold"),
                                                             axis.title.y = element_text(size = 14, face = "bold")) + 
      scale_y_continuous(labels = comma) + 
      coord_flip() + xlab("Sectors") + 
      ylab("Average Lender Term") + theme(legend.position="none")
  
  })
  
  #=============
  # FUNDED AMOUNT BY SECTOR
  #=============
  output$fundSectorPlot <- renderPlot({
    if (input$countryInput != "All"){
      sector_funded_amount_df <- loans %>%
        filter(COUNTRY_NAME == input$countryInput,STATUS %in% c('funded','fundRaising')) %>%
        dplyr::group_by(SECTOR_NAME) %>%
        dplyr::summarise(AVG_FUNDED_AMOUNT = mean(FUNDED_AMOUNT)) %>%
        select(SECTOR_NAME, AVG_FUNDED_AMOUNT)
    } else{
      sector_funded_amount_df <- loans %>%
        filter(STATUS %in% c('funded','fundRaising')) %>%
        dplyr::group_by(SECTOR_NAME) %>%
        dplyr::summarise(AVG_FUNDED_AMOUNT = mean(FUNDED_AMOUNT)) %>%
        select(SECTOR_NAME, AVG_FUNDED_AMOUNT)
    }
    ggplot(sector_funded_amount_df,aes(x=reorder(SECTOR_NAME, AVG_FUNDED_AMOUNT),
                                       y=AVG_FUNDED_AMOUNT, fill = SECTOR_NAME)) +
      geom_bar(stat = "identity") + theme_minimal()  + theme(axis.text.x = element_text(size = 12),           
                                                             axis.text.y = element_text(size = 12),           
                                                             axis.title.x = element_text(size = 14, face = "bold"),           
                                                             axis.title.y = element_text(size = 14, face = "bold")) + 
      scale_y_continuous(labels = comma) +
      coord_flip() + xlab("Sectors") + 
      ylab("AVERAGE FUNDED AMOUNT") + theme(legend.position="none")
  })
  
  #=============
  # DISTRIBUTION MODEL BY SECTOR
  #=============
  output$distributionSectorPlot <- renderPlot({
    if (input$countryInput != "All"){
      distribution_df <- loans %>%
        filter(COUNTRY_NAME == input$countryInput,STATUS %in% c('funded','fundRaising')) %>%
        dplyr::group_by(SECTOR_NAME,DISTRIBUTION_MODEL) %>%
        dplyr::summarise(count = n()) %>%
        select(SECTOR_NAME,DISTRIBUTION_MODEL, count)
    } else{
      distribution_df <- loans %>%
        filter(STATUS %in% c('funded','fundRaising')) %>%
        dplyr::group_by(SECTOR_NAME,DISTRIBUTION_MODEL) %>%
        dplyr::summarise(count = n()) %>%
        select(SECTOR_NAME,DISTRIBUTION_MODEL, count)

    }
    ggplot(distribution_df,aes(x=reorder(SECTOR_NAME, count),y=count, fill = DISTRIBUTION_MODEL)) +
      geom_bar(stat = "identity") + theme_minimal()  + theme(axis.text.x = element_text(size = 12),          
                                                             axis.text.y = element_text(size = 12), 
                                                             axis.title.x = element_text(size = 14, face = "bold"), 
                                                             axis.title.y = element_text(size = 14, face = "bold")) + 
      scale_y_continuous(labels = comma) +
      coord_flip() + xlab("Sectors") + 
      ylab("Count") + guides(fill=guide_legend(title="Distribution Model"))
  })
  
  #=============
  # REPAYMENT INTERVAL BY SECTOR
  #=============
  output$repaymentSectorPlot <- renderPlot({
    if (input$countryInput != "All"){
      repayment_df <- loans %>%
        filter(COUNTRY_NAME == input$countryInput,STATUS %in% c('funded','fundRaising')) %>%
        dplyr::group_by(SECTOR_NAME,REPAYMENT_INTERVAL) %>%
        dplyr::summarise(count = n()) %>%
        select(SECTOR_NAME,REPAYMENT_INTERVAL, count)
    } else{
      repayment_df <- loans %>%
        filter(STATUS %in% c('funded','fundRaising')) %>%
        dplyr::group_by(SECTOR_NAME,REPAYMENT_INTERVAL) %>%
        dplyr::summarise(count = n()) %>%
        select(SECTOR_NAME,REPAYMENT_INTERVAL, count)

    }
    ggplot(repayment_df,aes(x=reorder(SECTOR_NAME, count),y=count, fill = REPAYMENT_INTERVAL)) +
      geom_bar(stat = "identity") + theme_minimal()  + theme(axis.text.x = element_text(size = 12),
                                                             axis.text.y = element_text(size = 12),
                                                             axis.title.x = element_text(size = 14, face = "bold"),
                                                             axis.title.y = element_text(size = 14, face = "bold")) + 
      scale_y_continuous(labels = comma) +
      coord_flip() + xlab("Sectors") + 
      ylab("Count") + guides(fill=guide_legend(title="Repayment Interval"))
  })
  
  #=============
  # AVERAGE LOAN TIMEFRAME BY SECTOR
  #=============
  output$loanTimeSectorPlot <- renderPlot({
    if (input$countryInput != "All"){
      sectors_loan_time_df <- loans %>%
      filter(COUNTRY_NAME == input$countryInput,STATUS %in% c('funded','fundRaising')) %>%
        dplyr::group_by(SECTOR_NAME) %>%
        dplyr::summarise(AVG_POSTED_DISBURSED_TIME = mean(POSTED_DISBURSED_TIME)) %>% 
        select(SECTOR_NAME,AVG_POSTED_DISBURSED_TIME)
      sectors_loan_time_df$AVG_POSTED_DISBURSED_TIME <- -(sectors_loan_time_df$AVG_POSTED_DISBURSED_TIME)
    } else{
      sectors_loan_time_df <- loans %>%
        filter(STATUS %in% c('funded','fundRaising')) %>%
        dplyr::group_by(SECTOR_NAME) %>%
        dplyr::summarise(AVG_POSTED_DISBURSED_TIME = mean(POSTED_DISBURSED_TIME)) %>% 
        select(SECTOR_NAME,AVG_POSTED_DISBURSED_TIME)
      sectors_loan_time_df$AVG_POSTED_DISBURSED_TIME <- -(sectors_loan_time_df$AVG_POSTED_DISBURSED_TIME)
      
    }
    
    ggplot(sectors_loan_time_df,aes(x=reorder(SECTOR_NAME, AVG_POSTED_DISBURSED_TIME),
                                    y=AVG_POSTED_DISBURSED_TIME, 
                                    fill = SECTOR_NAME)) +
      geom_bar(stat = "identity") + theme_minimal()  + theme(axis.text.x = element_text(size = 12),
                                                             axis.text.y = element_text(size = 12),
                                                             axis.title.x = element_text(size = 14, face = "bold"),
                                                             axis.title.y = element_text(size = 14, face = "bold")) + 
      scale_y_continuous(labels = comma) +
      coord_flip() + xlab("Sectors") + 
      ylab("Average Loan disbursment time in days") + theme(legend.position="none")
  })
  
  #=============
  # FUNDED LOANS BY YEAR AND SECTOR
  #=============
  output$fundedLoansSectorPlot <- renderPlot({
    options(scipen=10000)
    col1 = "#d8e1cf" 
    col2 = "#438484"
    if (input$countryInput != "All"){
      funded_loan_time_df <- loans %>%
      filter(COUNTRY_NAME == input$countryInput,STATUS %in% c('funded','fundRaising')) %>%
        mutate(DISBURSED_TIME = lubridate::year(as.Date(DISBURSE_TIME))) %>%
        dplyr::group_by(SECTOR_NAME,DISBURSED_TIME) %>%
        dplyr::summarise(AVG_FUNDED_AMOUNT = mean(FUNDED_AMOUNT)) %>%
        select(SECTOR_NAME,DISBURSED_TIME,AVG_FUNDED_AMOUNT )
    } else{
      funded_loan_time_df <- loans %>%
        filter(STATUS %in% c('funded','fundRaising')) %>%
        mutate(DISBURSED_TIME = lubridate::year(as.Date(DISBURSE_TIME))) %>%
        dplyr::group_by(SECTOR_NAME,DISBURSED_TIME) %>%
        dplyr::summarise(AVG_FUNDED_AMOUNT = mean(FUNDED_AMOUNT)) %>%
        select(SECTOR_NAME,DISBURSED_TIME,AVG_FUNDED_AMOUNT )
    }
    funded_loan_time_df <- na.omit(funded_loan_time_df)
    
      ggplot(funded_loan_time_df, aes(DISBURSED_TIME, SECTOR_NAME, fill= AVG_FUNDED_AMOUNT)) +
        geom_tile() +
        scale_fill_gradient(low = col1, high = col2) +
        guides(fill=guide_legend(title="Average Funded Amount")) +
        labs(x = "Year", y = "Sectors") +
        theme_minimal()  + theme(axis.text.x = element_text(size = 12),           
                                 axis.text.y = element_text(size = 12),           
                                 axis.title.x = element_text(size = 14, face = "bold"),           
                                 axis.title.y = element_text(size = 14, face = "bold"))
    

  })
  #------------------------------
  # SROI model
  #------------------------------

  
  output$sectorBox <- renderValueBox ({ 
    sector_info <- input$sectorLoanInput
    valueBox(
      sector_info, "Sector", icon = icon("list"),
      color = "purple"
    )
  })
  
  output$countryBox <- shinydashboard::renderValueBox ({ 
    country_info <- input$countryLoanInput
    valueBox(
      country_info, "Country", icon = icon("list"),color = "blue"
    )
  })
  
  output$sroiBox <- renderValueBox({
    
    time_period <- as.numeric(input$yearInput)
    reduction_rate <- as.numeric(input$reductionInput)/100
    discount_rate <- as.numeric(input$discountInput)/100
    
    if ((input$countryLoanInput == "All")  & (input$sectorLoanInput != "All") ){ 
        loan_df2 <- loans %>%
          filter(STATUS %in% c('funded','fundRaising'), SECTOR_NAME == input$sectorLoanInput) %>%
          na.omit() %>%
          dplyr::group_by(ACTIVITY_NAME) %>%
          dplyr::summarise(TOTAL_FUNDED_AMOUNT = sum(FUNDED_AMOUNT)) %>%
          select(ACTIVITY_NAME,TOTAL_FUNDED_AMOUNT) 
    } else if ((input$countryLoanInput != "All") & (input$sectorLoanInput == "All")) {
        loan_df2 <- loans %>%
          filter(STATUS %in% c('funded','fundRaising'), COUNTRY_NAME == input$countryLoanInput) %>%
          na.omit() %>%
          dplyr::group_by(ACTIVITY_NAME) %>%
          dplyr::summarise(TOTAL_FUNDED_AMOUNT = sum(FUNDED_AMOUNT)) %>%
        select(ACTIVITY_NAME,TOTAL_FUNDED_AMOUNT)      
      } else if ((input$countryLoanInput != "All")  & (input$sectorLoanInput != "All")) {
        loan_df2 <- loans %>%
          filter(STATUS %in% c('funded','fundRaising'),
                 COUNTRY_NAME == input$countryLoanInput, SECTOR_NAME == input$sectorLoanInput) %>%
          na.omit() %>%
          dplyr::group_by(ACTIVITY_NAME) %>%
          dplyr::summarise(TOTAL_FUNDED_AMOUNT = sum(FUNDED_AMOUNT)) %>%
        select(ACTIVITY_NAME,TOTAL_FUNDED_AMOUNT) 
      }
    
    
   # if (dim(loan_df2)[1] == 0){
      sroi <- 0
      sroi <- as.character(sroi)  
  #  } else {
      # calculate reduction per year
      reduction_data <- matrix(nrow = length(loan_df2$ACTIVITY_NAME),ncol = time_period + 1)
      reduction_info <- vector('numeric', length = time_period)
      for (i in 1:length(loan_df2$ACTIVITY_NAME)) {
        temp <- c()
        activity_info <- loan_df2$ACTIVITY_NAME[i]
        reduction_info <- c()
        loan_info <- loan_df2$TOTAL_FUNDED_AMOUNT[i]
        
        for (j in 1:time_period){
          if (j != 1) {
            reduction_info[j] <- reduction_info[j-1] * (1 - reduction_rate)
          } else {
            reduction_info[1] <- loan_info
          }
        }
        temp <-  c(activity_info,reduction_info)
        reduction_data[i,] <- temp
      }
      
      # calculate npv
      npv_data <- c()
      for (i in 2:ncol(reduction_data)){
        temp <- sum(as.numeric(reduction_data[,i]))
        npv_data[i-1] <- temp / ((1 + discount_rate) ^ i)
      }
      # get total npv - sum of all npv
      total_npv <- sum(npv_data)
      # investment value is  is average of total funds
      investment_value <- mean(loan_df2$TOTAL_FUNDED_AMOUNT)
      # Social Impact value = total npv - investment value
      social_impact_value <- total_npv - investment_value 
      # SROI = Social Impact Value/Investment value
      sroi <- social_impact_value / investment_value
      sroi <- as.character(round(sroi,2))   
   # }
    valueBox(
      paste0(sroi), "Social Return $ for $ ", icon = icon("thumbs-up", lib = "glyphicon"),
      color = "green"
    )
  })
}

shinyApp(ui, server)



  
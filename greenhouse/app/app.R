# Shiny web app for Greenhouse Gas Air Emissions Data
####### Libraries #####

# library(ggplot2)
# library(tidyverse)
# library(shiny)
# library(shinydashboard)
# library(DT)
# library(lubridate)
# library(plotly)
# library(RColorBrewer)
# library(scales)
# library(readxl)
# library(tensorflow)

packages <- c(
  'ggplot2','tidyverse','plotly','leaflet',
  'shiny','shinydashboard','readxl',
  'DT','lubridate','RColorBrewer','scales'
)
for (package in packages) { 
  if (!require(package, character.only = T, quietly = T)) {
    install.packages(package)
    library(package, character.only = T)
  }
}

####### Data #######
df <- read_excel("data.xlsx")

df2 <- df %>% 
  pivot_longer(!c("ObjectId2","Country","ISO2","ISO3","Indicator","Unit",
                  "Source","CTS Code","CTS Name","CTS Full Descriptor",
                  "Industry","Gas Type","Seasonal Adjustment","Scale"),
               names_to = 'Year',
               values_to = 'Total')

country_list <- c(sort(unique(df$Country)))
industry_list <- c(sort(unique(df$Industry)))

####### Forecast info #######
year_data <- c(2023,2024,2025)
horizon_info <- c(1:50) #default 14
frequency_info <- c(7, 12, 52, 365)
difference_info <- c("Yes","No")
log_info <- c("Yes","No")
model_info <- c('auto-arima','auto-exponential','simple-exponential',
                'double-exponential','triple-exponential', 'tbat')
forecast_info <- "Series: forecast data"

forecast_df <- function (ts_df,differenceInput,differenceNumericInput,
                         frequencyInput,dataType) {
  
  df_data <- apply.yearly(ts_df, colMeans) #colMeans
  df_end <- floor(0.8*length(df_data)) 
  df_train <- df_data[1:df_end,] 
  df_test <- df_data[(df_end+1):length(df_data),]
  df_start <- c(year (start(df_train)), month(start(df_train)))
  df_end <- c(year(end(df_train)), month(end(df_train)))
  df_train <- ts(as.numeric(df_train), start = df_start, 
                  end = df_end, frequency = as.numeric(frequencyInput) )
  df_start <- c(year (start(df_test)), month(start(df_test)))
  df_end <- c(year(end(df_test)), month(end(df_test)))
  df_test <- ts(as.numeric(df_test), start = df_start, 
                 end = df_end, frequency = as.numeric(frequencyInput))
  
  if (dataType == "train") {
    output <- df_train
  } else {
    output <- df_test
  }
  
  if (differenceInput == "Yes"){
    output <- diff(output, differences = as.numeric(differenceNumericInput)) 
  }  
  
  output
  
}

numeric_update <- function(df){
  rownames(df) <- c()
  is.num <- sapply(df, is.numeric)
  df[is.num] <- lapply(df[is.num], round, 0)           
  return (df)
}



####### UI #########
ui <- dashboardPage(
  dashboardHeader(title = "Greenhouse Gas Emissions Data",
                  tags$li(a(href = 'https://climatedata.imf.org/datasets/c8579761f19740dfbe4418b205654ddf_0/about',
                            img(src = 'https://imf-dataviz.maps.arcgis.com/sharing/rest/content/items/bf9aa914b237454babc8ed059575c1a7/resources/imf-climate-logo.png',
                                title = "Home", height = "30px"),
                            style = "padding-top:10px; padding-bottom:10px;"),
                          class = "dropdown")
                  ),
  dashboardSidebar(
    sidebarMenu(
      menuItem("About", tabName = "about", icon = icon("th")),
      menuItem("Overview", tabName = "overview", icon = icon("th")),
      menuItem("Details", tabName = "detail", icon = icon("list")), 
      menuItem("Gas Type Analysis", tabName = "analysis", icon = icon("list")),
      menuSubItem("Gas Type Forecasting", tabName = "riderhsip_forecast",icon = icon("th"))
   )
  ),
   dashboardBody(
     tabItems(
      #### About ###
      tabItem(tabName = "about",shiny::includeMarkdown("about.md"),hr()),
      #### Overview ####
      tabItem(tabName = "overview",
              fluidRow(
                valueBoxOutput("countryBox"),
                valueBoxOutput("industryBox"),
                valueBoxOutput("gasBox")
              ),
              fluidRow(
                h2("Gas Types",style="text-align: center;text-style:bold"),
                plotlyOutput("gasTypeOverviewTrendPlot") 
              )
      ),
      tabItem(tabName="detail",
              sidebarLayout(
                sidebarPanel(width = 3,
                             selectInput(
                               "countryDetailInput",
                               "Select Country/Region",
                               country_list,
                               selected = country_list,
                               multiple = TRUE
                             ),
                             selectInput(
                               "industryDetailInput",
                               "Select Industry",
                               industry_list,
                               selected = industry_list,
                               multiple = TRUE
                             ),
                             submitButton("Submit")
                ),
                
                mainPanel (
                  h3("Gas Trend",style="text-align: center;text-style:bold"),
                  fluidRow(
                    plotlyOutput("gasDetailTrendPlot")
                  )
                )
              )
           ),
      #### Overview ####
      tabItem(tabName = "analysis",
              sidebarLayout(
                sidebarPanel(width = 3,
                             selectInput("countryInput", "Countries/Regions", 
                                         choices = country_list, selected = country_list,
                                         multiple = TRUE),
                             selectInput("industryInput", "Industries", 
                                         choices = industry_list, selected = industry_list,
                                         multiple = TRUE),
                             selectInput("frequencyInput", "Frequency", 
                                         choices = frequency_info, selected = 52),
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
                                plotlyOutput("decompositionPlot")),
                              tabPanel(
                                h4("Multi seasonal Decomposition",
                                   style="text-align: center;"),
                                plotlyOutput("multidecompositionPlot")),
                              tabPanel(
                                h4("ACF Plot",style="text-align: center;"), 
                                plotlyOutput("acfPlot")),
                              tabPanel(
                                h4("PACF Plot",style="text-align: center;"), 
                                plotlyOutput("pacfPlot"))
                  )
                )
              )  
      )
         )
       )
     )
####### Server #########
server <- function(input, output,session) {
  #### Value Boxes ####
  output$countryBox <- renderValueBox({
      valueBox(
        value = tags$p("Countries", style = "font-size: 100%;"),
        subtitle = tags$p(paste0(length(unique(df$Country))), style = "font-size: 100%;"),
        icon = icon("book"),
        color = "aqua"
      )
  })

  output$industryBox <- renderValueBox({
    valueBox(
      value = tags$p("Industries", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(length(unique(df$Industry))), style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })

  output$gasBox <- renderValueBox({
    valueBox(
      value = tags$p("Gas Type", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(length(unique(df$`Gas Type`))), style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })
  
  #### Overview Gas Type Plot ####
  output$gasTypeOverviewTrendPlot <- renderPlotly({
    
    trend <- df2  %>%
      group_by(Year, `Gas Type`) %>%
      summarise(Total = sum(Total)) %>%
      select(Year, `Gas Type`, Total)
    
    
    g <- ggplot(trend, aes(Year, Total, group=`Gas Type`, colour = `Gas Type`)) + 
      geom_line( size=1) + theme_minimal() +
      labs(x = "Year", y = "Total", color="Gas Type") + 
      scale_y_continuous(labels = comma) +
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10),
            axis.text.x = element_text(angle = 0, hjust = 1))
    
    ggplotly(g)
    
    
  })
  
  output$gasDetailTrendPlot <- renderPlotly({
    
    
    trend <- df2  %>%
      filter(Country %in% c(input$countryDetailInput) , 
             Industry %in% c(input$industryDetailInput)) %>%
      group_by(Year, `Gas Type`) %>%
      summarise(Total = sum(Total)) %>%
      select(Year, `Gas Type`, Total)
    
    
    g <- ggplot(trend, aes(Year, Total, group=`Gas Type`, colour = `Gas Type`)) + 
      geom_line( size=1) + theme_minimal() +
      labs(x = "Year", y = "Total", color="Gas Type") + 
      scale_y_continuous(labels = comma) +
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10),
            axis.text.x = element_text(angle = 0, hjust = 1))
    
    ggplotly(g)
    
  })
  
}
  
shinyApp(ui, server)
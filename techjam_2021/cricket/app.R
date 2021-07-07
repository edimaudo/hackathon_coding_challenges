rm(list = ls()) #clear environment
#=============
# Packages
#=============
packages <- c('ggplot2', 'corrplot','tidyverse',"caret","dummies",'readxl',
              'scales','dplyr','mlbench','caTools','forecast','TTR','xts',
              'FactoMineR','factoextra',"fastDummies",'scales','dplyr','mlbench',
              'caTools','gridExtra','doParallel','lubridate','data.table')
#=============
# load packages
#=============
for (package in packages) {
    if (!require(package, character.only=T, quietly=T)) {
        install.packages(package)
        library(package, character.only=T)
    }
}

#=============
# load data
#=============

#=============
# dropdowns
#=============

ui <- dashboardPage(
    dashboardHeader(title = "Cricket Australia"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("About", tabName = "about", icon = icon("th")),
            menuItem("Cricket Australia", tabName = "cricket_australia", icon = icon("th")),
            menuItem("Cricket Primer", tabName = "cricket_primer", icon = icon("th")),
            menuItem("Grounds", tabName = "grounds", icon = icon("th")),
            menuItem("Team", tabName = "team", icon = icon("th")),
            menuItem("Player", tabName = "player", icon = icon("th")),
            menuItem("Match", tabName = "match", icon = icon("th"))
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
                                            plotOutput("decompositionPlot")
                                            ),
                                        tabPanel(
                                            h4("Multi seasonal Decomposition",
                                               style="text-align: center;"),
                                            plotOutput("multidecompositionPlot")
                                            ),
                                        tabPanel(
                                            h4("ACF Plot",style="text-align: center;"), 
                                            plotOutput("acfPlot")
                                            ),
                                        tabPanel(
                                            h4("PACF Plot",style="text-align: center;"), 
                                            plotOutput("pacfPlot")
                                            )
                            )
                        )
                    )  
            ),
            tabItem(tabName = "Forecast",
                    sidebarLayout(
                        sidebarPanel(
                            # selectInput("aggregateInput", "Aggregate", 
                            #             choices = aggregate_info, selected = 'daily'),
                            # selectInput("horizonInput", "Horizon", 
                            #             choices = horizon_info, selected = 14),
                            # selectInput("frequencyInput", "Frequency", 
                            #             choices = frequency_info, selected = 7),
                            # sliderInput("traintestInput", "Train/Test Split",
                            #             min = 0, max = 1,value = 0.8),
                            # checkboxGroupInput("modelInput", "Models",choices = model_info, 
                            #                    selected = model_info),
                            #sliderInput("autoInput", "Auto-regression",
                            #            min = 0, max = 100,value = 0),
                            #sliderInput("difference2Input", "Difference",
                            #            min = 0, max = 52,value = 0),
                            #sliderInput("maInput", "Moving Average",
                            #            min = 0, max = 100,value = 0),
                            submitButton("Submit")
                        ),
                        mainPanel(
                            h1("Forecast Analysis",style="text-align: center;"), 
                            tabsetPanel(type = "tabs",
                                        tabPanel(h4("Forecast Visualization",style="text-align: center;"), 
                                                 #plotOutput("forecastPlot")
                                                 ),
                                        tabPanel(h4("Forecast Results",style="text-align: center;"), 
                                                 #DT::dataTableOutput("forecastOutput")
                                                 ),
                                        tabPanel(h4("Forecast Accuracy",style="text-align: center;"), 
                                                 #DT::dataTableOutput("accuracyOutput")
                                                 )
                            )
                        )
                    )
            ) 
        )
    ) 
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {

  
}

# Run the application 
shinyApp(ui = ui, server = server)

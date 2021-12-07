# Open data addathon
rm(list = ls()) #clear environment
#===============
# Libraries
#===============
packages <- c('ggplot2', 'corrplot','tidyverse',"caret",'scales',
              'dplyr','mlbench','caTools','forecast','TTR','xts','lubridate','shiny',
              'shinydashboard','tidyr','gridExtra','stopwords','tidytext','stringr',
              'reshape2', 'textdata','textmineR','topicmodels','textclean','pals','lubridate')
for (package in packages) {
    if (!require(package, character.only=T, quietly=T)) {
        install.packages(package)
        library(package, character.only=T)
    }
}
#=============
# Load data
#=============

cancer_death <- read.csv("Cancer Death - Data.csv")
cancer_incidence <- read.csv("CancerIncidence.csv")
communicable_disease <- read.csv("Communicable Diseases - Data.csv")
episode <- read.csv("Episodes - Data.csv")
patient_number <- read.csv("Number of annual patients_1.csv")
patient_classification <- read.csv("Patient Classification according to gender_1.csv")
payer_claims <- read.csv("Payer Claims - Data.csv")
patient_addiction <- read.csv("Percentage of addiction on the various  substances for NRC patients_0.csv")
population_benchmarks <- read.csv("Population & Benchmarks - Data.csv")

#=============
# Data Update
#=============
#Update Nationality
cancer_death$Nationality <- ifelse(cancer_death$Nationality=="Expatriate","Expatriates",ifelse(
  cancer_death$Nationality=="National","Nationals","Unknown"))

#===============
# UI
#===============

# UI Drop-downs
# time_info <- c('time','day','day of week','month')
# keyword_info <- sort(c(unique(df$keyword)))
# trend_info <- sort(c(unique(df$trend)))

cancer_nationality <- c("All",sort(unique(cancer_death$Nationality)))
cancer_gender <- c("All",sort(unique(cancer_death$Gender)))
cancer_year <- c("All",sort(unique(cancer_death$Year)))

ui <- dashboardPage(
                    dashboardHeader(title = "Adda "),
                    dashboardSidebar(
                        sidebarMenu(
                            menuItem("About", tabName = "about", icon = icon("th")), 
                            #menuItem("Overall", tabName = "overall", icon = icon("th")), 
                            menuItem("Health", tabName = "health", icon = icon("th"))#, 
                            #menuItem("Keywords", tabName = "keyword", icon = icon("th")),
                            #menuItem("Compare Keywords", tabName = "comparekeyword", icon = icon("th")),
                            #menuItem("Trends", tabName = "trends", icon = icon("th")),
                            #menuItem("Compare Trends", tabName = "comparetrend", icon = icon("th"))
                        )
                    ),
                    dashboardBody(
                        tabItems(
                            #=============#
                            # About
                            #=============#
                            tabItem(tabName = "about",
                                    mainPanel(includeMarkdown("about.md"))
                            ),
                            #=============#
                            # Health
                            #=============#
                            tabItem(tabName = "health",
                                      mainPanel(
                                        h1("Healthcare",style="text-align: center;"),
                                        
                                        box(
                                          title = "Cancer", status = "primary", solidHeader = TRUE,

                                          fluidRow(
                                            column(width = 5,
                                                   selectInput("cancerNationalityInput", 
                                                               "Nationality", choices = cancer_nationality),
                                                   selectInput("cancerGenderInput", 
                                                               "Gender", choices = cancer_gender),
                                                   selectInput("cancerYearInput", 
                                                               "Nationality", choices = cancer_year),
                                                   tabBox(
                                                   title = "Insights",
                                                   id = "tabset1", width = '100%', height = "350px",
                                                   tabPanel("Incidence", plotOutput("hourPlot")),
                                                   tabPanel("Death", plotOutput("hourPlot"))
                                                    )
                                                   
                                            )
                                           
                                              
                                              
                                              #tabPanel("Day", plotOutput("dayPlot")),
                                              #tabPanel("Day of Week", plotOutput("dayofweekPlot")),
                                              #tabPanel("Month", plotOutput("monthPlot")), 
                                              #tabPanel('Keywords',DT::dataTableOutput("keywordTable")),
                                              #tabPanel('Trends',DT::dataTableOutput("trendoverallTable")),
                                              #tabPanel('Accounts',DT::dataTableOutput("accountoverallTable")),
                                            #) 
                                        #)#,
                                       # box(
                                      #    title = "Patients", status = "primary", solidHeader = TRUE,
                                      #  ),
                                      #  box(
                                      #    title = "Insurance", status = "primary", solidHeader = TRUE,
                                      #  )
                                      )
                                    
                            )
                            #=============#
                            # Energy
                            #=============#
                            #=============#
                            # Tourism
                            #=============#
                            #=============#
                            # Predictions
                            #=============#
                            
                        )
                    )
  )
)
)


#===============
# Server
#===============
server <- function(input, output,session) {
#=============#
# Overview
#=============#

#=============#
# Health
#=============#
  #overall  month plots
  output$healthdata <- DT::renderDataTable({
    
    DT::datatable(cancer_death)
    
  })
  
#=============#
# Energy
#=============#

#=============#
# Tourism
#=============#

#=============#
# Predictions
#=============#
}

shinyApp(ui, server)
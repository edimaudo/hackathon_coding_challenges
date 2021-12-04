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

# Health data
cancer_death <- read.csv("Cancer Death - Data.csv")
cancer_incidence <- read.csv("CancerIncidence.csv")
communicable_disease <- read.csv("Communicable Diseases - Data.csv")
episode <- read.csv("Episodes - Data.csv")
patient_number <- read.csv("Number of annual patients_1.csv")
patient_classification <- read.csv("Patient Classification according to gender_1.csv")
payer_claims <- read.csv("Payer Claims - Data.csv")
patient_addiction <- read.csv("Percentage of addiction on the various  substances for NRC patients_0.csv")
population_benchmarks <- read.csv("Population & Benchmarks - Data.csv")

#===============
# UI
#===============
# UI Drop-downs
time_info <- c('time','day','day of week','month')
keyword_info <- sort(c(unique(df$keyword)))
trend_info <- sort(c(unique(df$trend)))

ui <- dashboardPage(skin = "green",
                    dashboardHeader(title = "Greener Future "),
                    dashboardSidebar(
                        sidebarMenu(
                            menuItem("Overview", tabName = "overview", icon = icon("th")), 
                            menuItem("Keywords", tabName = "keyword", icon = icon("th")),
                            menuItem("Compare Keywords", tabName = "comparekeyword", icon = icon("th")),
                            menuItem("Trends", tabName = "trends", icon = icon("th")),
                            menuItem("Compare Trends", tabName = "comparetrend", icon = icon("th"))
                        )
                    ),
                    dashboardBody(
                        tabItems(
                            #=============#
                            # About
                            #=============#
                            #=============#
                            # Overview
                            #=============#
                            #=============#
                            # Health
                            #=============#
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
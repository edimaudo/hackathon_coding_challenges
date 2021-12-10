# Open data addathon
rm(list = ls()) #clear environment
#===============
# Libraries
#===============
packages <- c('ggplot2', 'corrplot','tidyverse',"caret",'scales',"plotly",
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
#patient_number <- read.csv("Number of annual patients_1.csv")
#patient_classification <- read.csv("Patient Classification according to gender_1.csv")
payer_claims <- read.csv("Payer Claims - Data.csv")
patient_addiction <- read.csv("Percentage of addiction on the various  substances for NRC patients_0.csv")
population_benchmarks <- read.csv("Population & Benchmarks - Data.csv")

# Tourism data

#=============
# Data Update
#=============

# Update Nationality
cancer_death$Nationality <- ifelse(cancer_death$Nationality=="Expatriate","Expatriates",ifelse(
  cancer_death$Nationality=="National","Nationals","Unknown"))

communicable_disease$Nationality <- ifelse(communicable_disease$Nationality=="Expatriate",
                                           "Expatriates",
                                           ifelse(communicable_disease$Nationality=="National",
                                                  "Nationals","Unknown"))

# Update communicable diseases Cases
communicable_disease$Cases <- as.numeric(communicable_disease$Cases)
#===============
# UI
#===============

# UI Drop-downs
cancer_nationality <- c("All",sort(unique(cancer_death$Nationality)))
cancer_gender <- c("All",sort(unique(cancer_death$Gender)))
insurance_group <- c("All",sort(unique(payer_claims$Package.Group)))


ui <- dashboardPage(
                    dashboardHeader(title = "Adda Discovery"),
                    dashboardSidebar(
                        sidebarMenu(
                            menuItem("About", tabName = "about", icon = icon("th")), 
                            menuItem("Health", tabName = "health", icon = icon("th")), 
                            menuItem("Tourism", tabName = "tourism", icon = icon("th"))#,
                            #menuItem("Tourism", tabName = "tourism", icon = icon("th")),
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
                                    sidebarLayout(
                                      sidebarPanel(
                                        selectInput("cancerNationalityInput",
                                                    "Nationality", choices = cancer_nationality),
                                        selectInput("cancerGenderInput",
                                                    "Gender", choices = cancer_gender),
                                        selectInput("insuranceInput",
                                                    "Insurance Package", choices = insurance_group)
                                      ),
                                      mainPanel(
                                        fluidRow(
                                          tabBox(
                                            title = "Cancer care",
                                            id = "tabset1",
                                            tabPanel("Incidence", plotOutput("incidencePlot", height = 150)),
                                            tabPanel("Death", plotOutput("deathPlot", height = 150)),
                                            tabPanel("Top 5 Cancer sites", plotOutput("cancerSitePlot", height = 150))
                                          ),
                                          tabBox(
                                            title = "Insurance",
                                            side = "right", height = "250px",
                                            selected = "Payer Trend",
                                            tabPanel("Payer Trend", plotOutput("insuranceTrendPlot", height = 150)),
                                            tabPanel("Top 5 Payers", plotOutput("insurancePayerPlot", height = 150)) 
                                          )
                                        ),
                                        fluidRow(
                                          tabBox(
                                            title = "Communicable Disease",
                                            id = "tabset2",
                                            tabPanel("Disease Trend", plotOutput("diseaseTrendPlot", height = 150)),
                                            tabPanel("Top 5 Diseases", plotOutput("diseasePlot", height = 150))
                                          ),
                                          tabBox(
                                            title = "ER Visits",
                                            side = "right", height = "250px",
                                            selected = "Tab1",
                                            tabPanel("Tab1", "Tab content 1"),
                                            tabPanel("Tab2", "Tab content 2"),
                                            tabPanel("Tab3", "Note that when side=right, the tab order is reversed.")
                                          )
                                        )
                                      )
                            )
                        )
                    )
                    
      )
)


#===============
# Server
#===============
server <- function(input, output,session) {
#===================
# Health
#===================

#===================
# Cancer Incident plot
#===================
  output$incidencePlot <- renderPlot({

    df <- cancer_incidence %>%
      group_by(Year) %>%
      summarise(Total = sum(Count)) %>%
      select(Year, Total)
        
    if (input$cancerNationalityInput != "All"){
      df <- cancer_incidence %>%
        filter(Nationality == input$cancerNationalityInput) %>%
        group_by(Year) %>%
        summarise(Total = sum(Count)) %>%
        select(Year, Total)
      
    } else if (input$cancerGenderInput != "All"){
      df <- cancer_incidence %>%
        filter(Gender == input$cancerGenderInput) %>%
        group_by(Year) %>%
        summarise(Total = sum(Count)) %>%
        select(Year, Total)     
    } else if (input$cancerGenderInput != "All" & input$cancerNationalityInput != "All"){
      df <- cancer_incidence %>%
        filter(Nationality == input$cancerNationalityInput,Gender == input$cancerGenderInput) %>%
        group_by(Year) %>%
        summarise(Total = sum(Count)) %>%
        select(Year, Total)
    }

    
    ggplot(data=df, aes(x=Year, y=Total, group=1)) +
      geom_line()+
      geom_point() + theme_minimal() +
      labs(x = "Year", y = "Total") + 
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10),
            axis.text.x = element_text(angle = 0, hjust = 1))
    
  })
#===================
# Cancer death plot
#===================
  output$deathPlot <- renderPlot({
    df <- cancer_death %>%
      group_by(Year) %>%
      summarise(Total = sum(Count)) %>%
      select(Year, Total)
    
    if (input$cancerNationalityInput != "All"){
      df <- cancer_death %>%
        filter(Nationality == input$cancerNationalityInput) %>%
        group_by(Year) %>%
        summarise(Total = sum(Count)) %>%
        select(Year, Total)
      
    } else if (input$cancerGenderInput != "All"){
      df <- cancer_death%>%
        filter(Gender == input$cancerGenderInput) %>%
        group_by(Year) %>%
        summarise(Total = sum(Count)) %>%
        select(Year, Total)     
    } else if (input$cancerGenderInput != "All" & input$cancerNationalityInput != "All"){
      df <- cancer_death %>%
        filter(Nationality == input$cancerNationalityInput,Gender == input$cancerGenderInput) %>%
        group_by(Year) %>%
        summarise(Total = sum(Count)) %>%
        select(Year, Total)
    }
    
    ggplot(data=df, aes(x=Year, y=Total, group=1)) +
      geom_line()+
      geom_point() + theme_minimal() +
      labs(x = "Year", y = "Total") + 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 15),
            axis.title = element_text(size = 15),
            axis.text = element_text(size = 15),
            axis.text.x = element_text(angle = 0, hjust = 1))
    
    

  })
#===================
# Cancer site plot
#===================
  output$cancerSitePlot <- renderPlot({
    df <- cancer_death %>%
      group_by(Cancer.site) %>%
      summarise(Total = sum(Count)) %>%
      arrange(desc(Total)) %>%
      top_n(5)%>%
      select(Cancer.site, Total)
    
    if (input$cancerNationalityInput != "All"){
      df <- cancer_death %>%
        filter(Nationality == input$cancerNationalityInput) %>%
        group_by(Cancer.site) %>%
        summarise(Total = sum(Count)) %>%
        arrange(desc(Total)) %>%
        top_n(5)%>%
        select(Cancer.site, Total)
      
    } else if (input$cancerGenderInput != "All"){
      df <- cancer_death%>%
        filter(Gender == input$cancerGenderInput) %>%
        group_by(Cancer.site) %>%
        summarise(Total = sum(Count)) %>%
        arrange(desc(Total)) %>%
        top_n(5)%>%
        select(Cancer.site, Total)     
    } else if (input$cancerGenderInput != "All" & input$cancerNationalityInput != "All"){
      df <- cancer_death %>%
        filter(Nationality == input$cancerNationalityInput, Gender == input$cancerGenderInput) %>%
        group_by(Cancer.site) %>%
        summarise(Total = sum(Count)) %>%
        arrange(desc(Total)) %>%
        top_n(5)%>%
        select(Cancer.site, Total)
    }
    
    
    ggplot(df, aes(reorder(Cancer.site,Total), Total)) + 
      geom_bar(stat="identity", width = 0.5, position="dodge") +  coord_flip() +
      theme_minimal() + scale_y_continuous(labels = comma) +
      labs(x = "Cancer Site", y = "Total") + 
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10),
            axis.text.x = element_text(angle = 0, hjust = 1))
  })

#=================
# Insurance trend plot
#=================
  output$insuranceTrendPlot <- renderPlot({
    df <- payer_claims %>%
      group_by(Year) %>%
      summarise(Total = sum(Claims.Count)) %>%
      select(Year, Total)
    
    if (input$insuranceInput != "All"){
      df <- payer_claims %>%
        filter(Package.Group == input$insuranceInput) %>%
        group_by(Year) %>%
        summarise(Total = sum(Claims.Count)) %>%
        select(Year, Total)
      
    } 
    
    ggplot(data=df, aes(x=as.factor(Year), y=Total, group=1)) +
      geom_line()+
      geom_point() + theme_minimal() + scale_y_continuous(labels = comma) +
      labs(x = "Year", y = "Total") + 
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10),
            axis.text.x = element_text(angle = 0, hjust = 1))
    
  })

#=====================
# Insurance Payer plot
#=====================
  output$insurancePayerPlot <- renderPlot({
    df <- payer_claims %>%
      group_by(Claim.Payer.Name) %>%
      summarise(Total = sum(Claims.Count)) %>%
      arrange(desc(Total)) %>%
      top_n(5) %>%
      select(Claim.Payer.Name, Total)
    
    if (input$insuranceInput != "All"){
      df <- payer_claims %>%
        filter(Package.Group == input$insuranceInput) %>%
        group_by(Claim.Payer.Name) %>%
        summarise(Total = sum(Claims.Count)) %>%
        arrange(desc(Total)) %>%
        top_n(5) %>%
        select(Claim.Payer.Name, Total)
      
    } 
    
    ggplot(df, aes(reorder(Claim.Payer.Name,Total), Total)) + 
      geom_bar(stat="identity", width = 0.5, position="dodge") +  coord_flip() +
      theme_minimal() + scale_y_continuous(labels = comma) +
      labs(x = "Cancer Site", y = "Total") + 
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 12),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10),
            axis.text.x = element_text(angle = 20, hjust = 1))
    
  })
#===================
# Communicable disease plot
#===================
  output$diseaseTrendPlot <- renderPlot({
    df <- communicable_disease %>%
      group_by(Year) %>%
      summarise(Total = sum(Cases)) %>%
      select(Year, Total)
    
    if (input$cancerNationalityInput != "All"){
      df <- communicable_disease %>%
        filter(Nationality == input$cancerNationalityInput) %>%
        group_by(Year) %>%
        summarise(Total = sum(Cases)) %>%
        select(Year, Total)
    } 
    
    ggplot(data=df, aes(x=as.factor(Year), y=Total, group=1)) +
      geom_line()+
      geom_point() + theme_minimal() + scale_y_continuous(labels = comma) +
      labs(x = "Year", y = "Total") + 
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10),
            axis.text.x = element_text(angle = 0, hjust = 1))
    
  })

  #===================
  # Communicable disease top 5
  #===================
  output$diseasePlot <- renderPlot({
    df <- communicable_disease %>%
      group_by(Disease) %>%
      summarise(Total = sum(Cases)) %>%
      arrange(desc(Total)) %>%
      top_n(5) %>%
      select(Disease, Total)
    
    if (input$cancerNationalityInput != "All"){
      df <- communicable_disease %>%
        filter(Nationality == input$cancerNationalityInput) %>%
        group_by(Disease) %>%
        summarise(Total = sum(Cases)) %>%
        arrange(desc(Total)) %>%
        top_n(5) %>%
        select(Disease, Total)
      
    } 
    
    ggplot(df, aes(reorder(Disease,Total), Total)) + 
      geom_bar(stat="identity", width = 0.5, position="dodge") +  coord_flip() +
      theme_minimal() + scale_y_continuous(labels = comma) +
      labs(x = "Disease", y = "Total") + 
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10),
            axis.text.x = element_text(angle = 0, hjust = 1))
  })
  
}

shinyApp(ui, server)
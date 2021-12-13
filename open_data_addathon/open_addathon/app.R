# Open data addathon
rm(list = ls()) #clear environment
################
# Libraries
################
# packages <- c('ggplot2','corrplot','tidyverse','scales','readxl','dplyr','lubridate','shiny','shinydashboard')
# for (package in packages) {
#     if (!require(package, character.only=T, quietly=T)) {
#         install.packages(package)
#         library(package, character.only=T)
#     }
# }

library(ggplot2)
library(corrplot)
library(tidyverse)
library(scales)
library(readxl)
library(dplyr)
library(lubridate)
library(shiny)
library(shinydashboard)
################
# Load data
################

#===============
# Health data
#===============
cancer_death <- read.csv("Cancer Death - Data.csv")
cancer_incidence <- read.csv("CancerIncidence.csv")
communicable_disease <- read.csv("Communicable Diseases - Data.csv")
episode <- read.csv("Episodes - Data.csv")
payer_claims <- read.csv("Payer Claims - Data.csv")

#===============
# Tourism data
#===============
guest_purpose <- read_excel("Tourism.xlsx",sheet = "Guest_by_purpose")
top_country_visitors <- read_excel("Tourism.xlsx", sheet ="Top_Country_Hotel_Guest")
city_hotel_rooms <- read_excel("Tourism.xlsx",sheet ="City_Hotel_Rooms")

revenue_star_rating <- read_excel("Tourism.xlsx", sheet ="Revenue_Star_Rating")
revenue_region <- read_excel("Tourism.xlsx", sheet ="Revenue_Region")

performance_city <- read_excel("Tourism.xlsx", sheet ="Performance by City")
performance_star_rating <- read_excel("Tourism.xlsx", sheet ="Performance by Star-ratings")
performance_zone <- read_excel("Tourism.xlsx", sheet ="Performance_Zone")


################
# Data Update
################

# Update Nationality
cancer_death$Nationality <- ifelse(cancer_death$Nationality=="Expatriate","Expatriates",ifelse(
  cancer_death$Nationality=="National","Nationals","Unknown"))

communicable_disease$Nationality <- ifelse(communicable_disease$Nationality=="Expatriate",
                                           "Expatriates",
                                           ifelse(communicable_disease$Nationality=="National",
                                                  "Nationals","Unknown"))

episode$National.Expatriate <- ifelse(episode$National.Expatriate=="Expatriate",
                                           "Expatriates",
                                           ifelse(episode$National.Expatriate=="National",
                                                  "Nationals","Unknown"))

# Update communicable diseases Cases
communicable_disease$Cases <- as.numeric(communicable_disease$Cases)
# Update episode count
episode$Episodes.Count <- as.numeric(episode$Episodes.Count)

################
# UI
################

#================
# UI Drop-downs
#================
cancer_nationality <- c("All",sort(unique(cancer_death$Nationality)))
cancer_gender <- c("All",sort(unique(cancer_death$Gender)))
insurance_group <- c("All",sort(unique(payer_claims$Package.Group)))
year_info <- c(2011:2019)
tourism_year_info <- c(2018:2020)
quarter_info <- c(1:4)
city_info <- c("All",'Abu Dhabi','Al Dhafra Region','Al-Ain')

#================
# UI Design
#================
ui <- dashboardPage(
                    dashboardHeader(title = "Adda Discovery"),
                    dashboardSidebar(
                        sidebarMenu(
                            menuItem("About", tabName = "about", icon = icon("th")), 
                            menuItem("Health", tabName = "health", icon = icon("th")), 
                            menuItem("Tourism", tabName = "tourism", icon = icon("th"))
                        )
                    ),
                    dashboardBody(
                        tabItems(
                        ################
                        # About
                        ################
                            tabItem(tabName = "about",
                                    mainPanel(includeMarkdown("about.md"))
                            ),
                        ################
                        # Health
                        ################
                            tabItem(tabName = "health",
                                    sidebarLayout(
                                      sidebarPanel(
                                        selectInput("cancerNationalityInput",
                                                    "Nationality", choices = cancer_nationality),
                                        selectInput("cancerGenderInput",
                                                    "Gender", choices = cancer_gender),
                                        sliderInput("yearInput","Year",min=min(year_info),max=max(year_info),
                                                    value = c(min(year_info),max(year_info)),
                                                    step =1,ticks = TRUE)
                                      ),
                                      mainPanel(
                                        h2("Health Insights",style="text-align: center; font-style: bold;"), 
                                        fluidRow(
                                          tabBox(
                                            title = "Cancer care",
                                            id = "tabset1",
                                            tabPanel("Incidence", plotOutput("incidencePlot", height = 150)),
                                            tabPanel("Death", plotOutput("deathPlot", height = 150)),
                                            tabPanel("Top 5 Cancer sites", 
                                                     plotOutput("cancerSitePlot", height = 150))
                                          ),
                                          tabBox(
                                            title = "Insurance",
                                            side = "right", height = "250px",
                                            selected = "Payer Trend",
                                            tabPanel("Payer Trend", 
                                                     plotOutput("insuranceTrendPlot", height = 150))
                                          )
                                        ),
                                        fluidRow(
                                          tabBox(
                                            title = "Communicable Diseases",
                                            id = "tabset2",
                                            tabPanel("Disease Trend", 
                                                     plotOutput("diseaseTrendPlot", height = 150)),
                                            tabPanel("Top 5 Diseases", 
                                                     plotOutput("diseasePlot", height = 150))
                                          ),
                                          tabBox(
                                            title = "Episodes",
                                            side = "right", height = "250px",
                                            selected = "Episode Trends",
                                            tabPanel("Top 5 ER Facilites", 
                                                     plotOutput("erFacilityPlot", height = 150)),
                                            tabPanel("Sector & Region", 
                                                     plotOutput("ersectorRegionPlot", height = 150)),
                                            tabPanel("Episode Trends", 
                                                     plotOutput("erTrendPlot", height = 150)),
                                            tabPanel("Patient & Facility Type", 
                                                     plotOutput("erPatientFacilityPlot", height = 150)),
                                            tabPanel("ER & Patient Type", 
                                                     plotOutput("erPatientTypePlot", height = 150))
                                          )
                                        )

                            
                                      )
                            )
                        ),
                        ################
                        # Tourism
                        ################
                        tabItem(tabName = "tourism",
                                sidebarLayout(
                                  sidebarPanel(
                                    sliderInput("yearTourismInput","Year",min=min(tourism_year_info),
                                                max=max(tourism_year_info),
                                                value = c(min(tourism_year_info),max(tourism_year_info)),
                                                step =1,ticks = FALSE),
                                    sliderInput("quarterTourismInput","Quarter",min=min(quarter_info),
                                                max=max(quarter_info),
                                                value = c(min(quarter_info),max(quarter_info)),
                                                step =1,ticks = FALSE),
                                    selectInput("cityTourismInput", "City", choices = city_info),
                                  ),
                                  mainPanel(
                                    h2("Tourism Insights",style="text-align: center; font-style: bold;"),
                                    fluidRow(
                                      tabBox(
                                        title = "Guests",
                                        id = "tabset5",
                                        width = "80%",
                                        selected = "Purpose",
                                        tabPanel("Purpose", plotOutput("purposeGuestPlot", height = 150)),
                                        tabPanel("Country", plotOutput("countryGuestPlot", height = 150)),
                                        tabPanel("Hotels", plotOutput("hotelGuestPlot", height = 150)),
                                        tabPanel("Rooms", plotOutput("roomGuestPlot", height = 150))
                                      )
                                    ),
                                    fluidRow(
                                      tabBox(
                                        title = "Revenue",
                                        id = "tabset6",
                                        width = "80%",
                                        selected = "Regions",
                                        tabPanel("Regions", plotOutput("regionRevenuePlot", height = 150)),
                                        tabPanel("Star Ratings", plotOutput("starRatingRevenuePlot", height = 150)),
                                        tabPanel("Revenue breakdown",plotOutput("revenueOtherPlot", height = 150))
                                      )
                                    )
                                  )
                                )
                        )
                        
                    )
      )
)


################
# Server
################
server <- function(input, output,session) {

######################
# Health
######################

#===================
# Cancer Incident plot
#===================
  output$incidencePlot <- renderPlot({

    df <- cancer_incidence %>%
      filter(Year >= input$yearInput[1] & Year <= input$yearInput[2]) %>%
      group_by(Year) %>%
      summarise(Total = sum(Count)) %>%
      select(Year, Total)
        
    if (input$cancerNationalityInput != "All"){
      df <- cancer_incidence %>%
        filter(Nationality == input$cancerNationalityInput,Year >= input$yearInput[1] & Year <= input$yearInput[2]) %>%
        group_by(Year) %>%
        summarise(Total = sum(Count)) %>%
        select(Year, Total)
      
    } else if (input$cancerGenderInput != "All"){
      df <- cancer_incidence %>%
        filter(Gender == input$cancerGenderInput,Year >= input$yearInput[1] & Year <= input$yearInput[2]) %>%
        group_by(Year) %>%
        summarise(Total = sum(Count)) %>%
        select(Year, Total)     
    } else if (input$cancerGenderInput != "All" & input$cancerNationalityInput != "All"){
      df <- cancer_incidence %>%
        filter(Nationality == input$cancerNationalityInput,Gender == input$cancerGenderInput,
               Year >= input$yearInput[1] & Year <= input$yearInput[2]) %>%
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
      filter(Year >= input$yearInput[1] & Year <= input$yearInput[2]) %>%
      group_by(Year) %>%
      summarise(Total = sum(Count)) %>%
      select(Year, Total)
    
    if (input$cancerNationalityInput != "All"){
      df <- cancer_death %>%
        filter(Nationality == input$cancerNationalityInput,Year >= input$yearInput[1] & Year <= input$yearInput[2]) %>%
        group_by(Year) %>%
        summarise(Total = sum(Count)) %>%
        select(Year, Total)
      
    } else if (input$cancerGenderInput != "All"){
      df <- cancer_death%>%
        filter(Gender == input$cancerGenderInput,Year >= input$yearInput[1] & Year <= input$yearInput[2]) %>%
        group_by(Year) %>%
        summarise(Total = sum(Count)) %>%
        select(Year, Total)     
    } else if (input$cancerGenderInput != "All" & input$cancerNationalityInput != "All"){
      df <- cancer_death %>%
        filter(Year >= input$yearInput[1] & Year <= input$yearInput[2],Nationality == input$cancerNationalityInput,Gender == input$cancerGenderInput) %>%
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
      filter(Year >= input$yearInput[1] & Year <= input$yearInput[2]) %>%
      group_by(Cancer.site) %>%
      summarise(Total = sum(Count)) %>%
      arrange(desc(Total)) %>%
      top_n(5)%>%
      select(Cancer.site, Total)
    
    if (input$cancerNationalityInput != "All"){
      df <- cancer_death %>%
        filter(Nationality == input$cancerNationalityInput,
               Year >= input$yearInput[1] & Year <= input$yearInput[2]) %>%
        group_by(Cancer.site) %>%
        summarise(Total = sum(Count)) %>%
        arrange(desc(Total)) %>%
        top_n(5)%>%
        select(Cancer.site, Total)
      
    } else if (input$cancerGenderInput != "All"){
      df <- cancer_death%>%
        filter(Gender == input$cancerGenderInput,
               Year >= input$yearInput[1] & Year <= input$yearInput[2]) %>%
        group_by(Cancer.site) %>%
        summarise(Total = sum(Count)) %>%
        arrange(desc(Total)) %>%
        top_n(5)%>%
        select(Cancer.site, Total)     
    } else if (input$cancerGenderInput != "All" & input$cancerNationalityInput != "All"){
      df <- cancer_death %>%
        filter(Nationality == input$cancerNationalityInput, Gender == input$cancerGenderInput,
               Year >= input$yearInput[1] & Year <= input$yearInput[2]) %>%
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
      filter(Year >= input$yearInput[1] & Year <= input$yearInput[2]) %>%
      group_by(Year) %>%
      summarise(Total = sum(Claims.Count)) %>%
      select(Year, Total)
    
    # if (input$insuranceInput != "All"){
    #   df <- payer_claims %>%
    #     filter(Package.Group == input$insuranceInput) %>%
    #     group_by(Year) %>%
    #     summarise(Total = sum(Claims.Count)) %>%
    #     select(Year, Total)
    #   
    # } 
    
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
  # output$insurancePayerPlot <- renderPlot({
  #   df <- payer_claims %>%
  #     group_by(Claim.Payer.Name) %>%
  #     summarise(Total = sum(Claims.Count)) %>%
  #     arrange(desc(Total)) %>%
  #     top_n(5) %>%
  #     select(Claim.Payer.Name, Total)
  #   
  #   if (input$insuranceInput != "All"){
  #     df <- payer_claims %>%
  #       filter(Package.Group == input$insuranceInput) %>%
  #       group_by(Claim.Payer.Name) %>%
  #       summarise(Total = sum(Claims.Count)) %>%
  #       arrange(desc(Total)) %>%
  #       top_n(5) %>%
  #       select(Claim.Payer.Name, Total)
  #     
  #   } 
  #   
  #   ggplot(df, aes(reorder(Claim.Payer.Name,Total), Total)) + 
  #     geom_bar(stat="identity", width = 0.5, position="dodge") +  coord_flip() +
  #     theme_minimal() + scale_y_continuous(labels = comma) +
  #     labs(x = "Cancer Site", y = "Total") + 
  #     theme(legend.text = element_text(size = 10),
  #           legend.title = element_text(size = 10),
  #           axis.title = element_text(size = 10),
  #           axis.text = element_text(size = 8),
  #           axis.text.x = element_text(angle = 20, hjust = 1))
  #   
  # })


#===================
# Communicable disease plot
#===================
  output$diseaseTrendPlot <- renderPlot({
    df <- communicable_disease %>%
      filter(Year >= input$yearInput[1] & Year <= input$yearInput[2]) %>%
      group_by(Year) %>%
      summarise(Total = sum(Cases)) %>%
      select(Year, Total)
    
    if (input$cancerNationalityInput != "All"){
      df <- communicable_disease %>%
        filter(Nationality == input$cancerNationalityInput,
               Year >= input$yearInput[1] & Year <= input$yearInput[2]) %>%
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
      filter(Year >= input$yearInput[1] & Year <= input$yearInput[2]) %>%
      group_by(Disease) %>%
      summarise(Total = sum(Cases)) %>%
      arrange(desc(Total)) %>%
      top_n(5) %>%
      select(Disease, Total)
    
    if (input$cancerNationalityInput != "All"){
      df <- communicable_disease %>%
        filter(Nationality == input$cancerNationalityInput,
               Year >= input$yearInput[1] & Year <= input$yearInput[2]) %>%
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
  

#=================== 
# ER Visits plot
#=================== 
  output$erTrendPlot <- renderPlot({
    df <- episode %>%
      filter(Year >= input$yearInput[1] & Year <= input$yearInput[2]) %>%
      group_by(Year) %>%
      summarise(Total = sum(Episodes.Count)) %>%
      select(Year, Total)
    
    if (input$cancerNationalityInput != "All"){
      df <- episode %>%
        filter(National.Expatriate == input$cancerNationalityInput,
               Year >= input$yearInput[1] & Year <= input$yearInput[2]) %>%
        group_by(Year) %>%
        summarise(Total = sum(Episodes.Count)) %>%
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
# ER Facility top 5
#=================== 
output$erFacilityPlot <- renderPlot({
  df <- episode %>%
    filter(Year >= input$yearInput[1] & Year <= input$yearInput[2]) %>%
    group_by(Facility.Reporting.Name) %>%
    summarise(Total = sum(Episodes.Count)) %>%
    arrange(desc(Total)) %>%
    top_n(5) %>%
    select(Facility.Reporting.Name, Total)
  
  if (input$cancerNationalityInput != "All"){
    df <- episode %>%
      filter(National.Expatriate == input$cancerNationalityInput,
             Year >= input$yearInput[1] & Year <= input$yearInput[2]) %>%
      group_by(Facility.Reporting.Name) %>%
      summarise(Total = sum(Episodes.Count)) %>%
      arrange(desc(Total)) %>%
      top_n(5) %>%
      select(Facility.Reporting.Name, Total)
  } 
  
  ggplot(df, aes(reorder(Facility.Reporting.Name,Total), Total)) + 
    geom_bar(stat="identity", width = 0.5, position="dodge") +  coord_flip() +
    theme_minimal() + scale_y_continuous(labels = comma) +
    labs(x = "Facility", y = "Total") + 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 20, hjust = 0.5))
})

#=================== 
# Sector vs region
#=================== 
output$ersectorRegionPlot <- renderPlot({
  df <- episode %>%
    filter(Year >= input$yearInput[1] & Year <= input$yearInput[2]) %>%
    group_by(Sector, Facility.Region) %>%
    summarise(Total = sum(Episodes.Count)) %>%
    select(Sector, Facility.Region, Total)
  
  if (input$cancerNationalityInput != "All"){
    df <- episode %>%
      filter(National.Expatriate == input$cancerNationalityInput,
             Year >= input$yearInput[1] & Year <= input$yearInput[2]) %>%
      group_by(Sector, Facility.Region) %>%
      summarise(Total = sum(Episodes.Count)) %>%
      select(Sector, Facility.Region, Total)
  }
  
  ggplot(df, aes(Facility.Region ,Total)) + 
    geom_bar(stat="identity", width = 0.5, position="dodge", aes(fill = Sector)) +
    theme_minimal() + scale_y_continuous(labels = comma) +
    labs(x = "Facility", y = "Total") + 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 20, hjust = 0.5))

})


#=================== 
# Patient type vs facility type
#=================== 
output$erPatientFacilityPlot <- renderPlot({
  df <- episode %>%
    filter(Year >= input$yearInput[1] & Year <= input$yearInput[2]) %>%
    group_by(Inpatient.Outpatient, Facility.Type.Group) %>%
    summarise(Total = sum(Episodes.Count)) %>%
    select(Inpatient.Outpatient, Facility.Type.Group, Total)
  
  if (input$cancerNationalityInput != "All"){
    df <- episode %>%
      filter(National.Expatriate == input$cancerNationalityInput,
             Year >= input$yearInput[1] & Year <= input$yearInput[2]) %>%
      group_by(Inpatient.Outpatient, Facility.Type.Group) %>%
      summarise(Total = sum(Episodes.Count)) %>%
      select(Inpatient.Outpatient, Facility.Type.Group, Total)
  }
  
  

    ggplot(df, aes(Facility.Type.Group,Total)) + 
    geom_bar(stat="identity", width = 0.5, aes(fill = Inpatient.Outpatient)) +
    theme_minimal() + scale_y_continuous(labels = comma) +
    labs(x = "Facility Type", y = "Total", fill="Patient Type") + 
     theme(legend.text = element_text(size = 10),
           legend.title = element_text(size = 10),
           axis.title = element_text(size = 10),
           axis.text = element_text(size = 10),
           axis.text.x = element_text(angle = 20, hjust = 1))
})

#=================== 
# Patient type vs ER type
#=================== 
output$erPatientTypePlot <- renderPlot({
  df <- episode %>%
    filter(Year >= input$yearInput[1] & Year <= input$yearInput[2]) %>%
    group_by(Inpatient.Outpatient, ER) %>%
    summarise(Total = sum(Episodes.Count)) %>%
    select(Inpatient.Outpatient, ER, Total)
  
  if (input$cancerNationalityInput != "All"){
    df <- episode %>%
      filter(National.Expatriate == input$cancerNationalityInput,
             Year >= input$yearInput[1] & Year <= input$yearInput[2]) %>%
      group_by(Inpatient.Outpatient, ER) %>%
      summarise(Total = sum(Episodes.Count)) %>%
      select(Inpatient.Outpatient, ER, Total)
  }
  
  ggplot(df, aes(ER,Total)) + 
    geom_bar(stat="identity", width = 0.5, aes(fill = Inpatient.Outpatient)) +
    theme_minimal() + scale_y_continuous(labels = comma) +
    labs(x = "Facility Type", y = "Total", fill="Patient Type") + 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 0, hjust = 0.5))
})

  
######################
# Tourism
######################  

#=================== 
# Guest
#=================== 

#=================== 
# Hotel guests
#=================== 
output$hotelGuestPlot <- renderPlot({
  if (input$cityTourismInput != "All" ){
    df <- city_hotel_rooms  %>%
      filter(Year >= input$yearTourismInput[1] & Year <= input$yearTourismInput[2],
             Quarter >= input$quarterTourismInput[1] & Quarter <= input$quarterTourismInput[2],
             City == input$cityTourismInput) %>%
      group_by(City, Year) %>%
      summarise(Total = sum(Hotels)) %>%
      select(City, Year, Total)
  } else {
    df <- city_hotel_rooms  %>%
      filter(Year >= input$yearTourismInput[1] & Year <= input$yearTourismInput[2],
             Quarter >= input$quarterTourismInput[1] & Quarter <= input$quarterTourismInput[2]) %>%
      group_by(City, Year) %>%
      summarise(Total = sum(Hotels)) %>%
      select(City, Year, Total)
  }
  
  ggplot(df, aes(as.factor(Year),Total)) + 
    geom_bar(stat="identity", width = 0.5,position="dodge", aes(fill = City),size=2) +
    theme_minimal() + scale_y_continuous(labels = comma) +
    labs(x = "Year", y = "Total", fill="City") + 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 0, hjust = 1))
})
#=================== 
# Room guests
#=================== 
output$roomGuestPlot <- renderPlot({
  if (input$cityTourismInput != "All" ){
    df <- city_hotel_rooms  %>%
      filter(Year >= input$yearTourismInput[1] & Year <= input$yearTourismInput[2],
             Quarter >= input$quarterTourismInput[1] & Quarter <= input$quarterTourismInput[2],
             City == input$cityTourismInput) %>%
      group_by(City, Year) %>%
      summarise(Total = sum(Rooms)) %>%
      select(City, Year, Total)
  } else {
    df <- city_hotel_rooms  %>%
      filter(Year >= input$yearTourismInput[1] & Year <= input$yearTourismInput[2],
             Quarter >= input$quarterTourismInput[1] & Quarter <= input$quarterTourismInput[2]) %>%
      group_by(City, Year) %>%
      summarise(Total = sum(Rooms)) %>%
      select(City, Year, Total)
  }
  
  ggplot(df, aes(as.factor(Year),Total)) + 
    geom_bar(stat="identity", width = 0.5,position="dodge", aes(fill = City),size=2) +
    theme_minimal() + scale_y_continuous(labels = comma) +
    labs(x = "Year", y = "Total", fill="City") + 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 0, hjust = 1))
  
})

#=================== 
# Country guests
#=================== 
output$countryGuestPlot <- renderPlot({
  df <- top_country_visitors  %>%
    filter(Year >= input$yearTourismInput[1] & Year <= input$yearTourismInput[2]) %>%
    group_by(Country) %>%
    summarise(Total = sum(Total)) %>%
    arrange(desc(Total)) %>%
    select(Country, Total)

  ggplot(df, aes(reorder(Country,Total),Total)) + 
    geom_bar(stat="identity", width = 0.5,size=2) +
    theme_minimal() + scale_y_continuous(labels = comma) + coord_flip() +
    labs(x = "Country Visitors", y = "Total") + 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 0, hjust = 1))
  
})

#=================== 
# Guest purpose
#=================== 
output$purposeGuestPlot <- renderPlot({
  df <- guest_purpose %>%
    filter(Year >= input$yearTourismInput[1] & Year <= input$yearTourismInput[2],
           Quarter >= input$quarterTourismInput[1] & Quarter <= input$quarterTourismInput[2]) %>%
    group_by(PurposeOfVisit, Year) %>%
    summarise(Total = sum(TotalGuests)) %>%
    select(PurposeOfVisit, Year, Total)
  
  ggplot(df, aes(as.factor(Year),Total)) + 
    geom_bar(stat="identity", width = 0.5, position = "dodge", aes(fill = PurposeOfVisit),size=2) +
    theme_minimal() + scale_y_continuous(labels = comma) +
    labs(x = "Year", y = "Total", fill="Purpose of Visit") + 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 0, hjust = 1))
})


#=================== 
# Revenue
#=================== 

#=================== 
# Star Rating revenue
#=================== 
output$starRatingRevenuePlot <- renderPlot({
   
  df <- revenue_star_rating  %>%
    filter(Year >= input$yearTourismInput[1] & Year <= input$yearTourismInput[2],
           Quarter >= input$quarterTourismInput[1] & Quarter <= input$quarterTourismInput[2]) %>%
    group_by(StarRating, Year) %>%
    summarise(Total = sum(TotalRevenue)) %>%
    select(StarRating, Year, Total)
  
  ggplot(df, aes(as.factor(Year),Total)) + 
    geom_bar(stat="identity", width = 0.5, position = "dodge", aes(fill = StarRating),size=2) +
    theme_minimal() + scale_y_continuous(labels = comma) +
    labs(x = "Year", y = "Total", fill="Star Rating") + 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 0, hjust = 1))
  
})
#=================== 
# Region Revenue
#=================== 
output$regionRevenuePlot <- renderPlot({
  
  if (input$cityTourismInput != "All" ){
    df <- revenue_region  %>%
      filter(Year >= input$yearTourismInput[1] & Year <= input$yearTourismInput[2],
             Quarter >= input$quarterTourismInput[1] & Quarter <= input$quarterTourismInput[2],
             Region == input$cityTourismInput) %>%
      group_by(Region, Year) %>%
      summarise(Total = sum(TotalRevenue)) %>%
      select(Region, Year, Total)
  } else {
    df <- revenue_region  %>%
      filter(Year >= input$yearTourismInput[1] & Year <= input$yearTourismInput[2],
             Quarter >= input$quarterTourismInput[1] & Quarter <= input$quarterTourismInput[2]) %>%
      group_by(Region, Year) %>%
      summarise(Total = sum(TotalRevenue)) %>%
      select(Region, Year, Total)
  }
    
  ggplot(df, aes(as.factor(Year),Total)) + 
    geom_bar(stat="identity", width = 0.5, position = "dodge", aes(fill = Region), size=2) +
    theme_minimal() + scale_y_continuous(labels = comma) +
    labs(x = "Year", y = "Total", fill="City/Region") + 
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          axis.title = element_text(size = 10),
          axis.text = element_text(size = 10),
          axis.text.x = element_text(angle = 0, hjust = 1))
  
})
#=================== 
# Revenue Other
#=================== 
output$revenueOtherPlot <- renderPlot({
  
  if (input$cityTourismInput != "All" ){
    df <- revenue_region  %>%
      filter(Year >= input$yearTourismInput[1] & Year <= input$yearTourismInput[2],
             Quarter >= input$quarterTourismInput[1] & Quarter <= input$quarterTourismInput[2],
             Region == input$cityTourismInput) %>%
      group_by(Quarter) %>%
      summarise(`Room` = sum(RoomRevenue),
                `Food & Beverage` = sum(`Food&Beverage Revenue`),	
                `Other` = sum(OtherRevenue))  %>%
      select(Quarter, `Room`, `Food & Beverage`,`Other`) %>%
      pivot_longer(-Quarter, names_to = "variable", values_to = "value")
  } else {
    df <- revenue_region  %>%
      filter(Year >= input$yearTourismInput[1] & Year <= input$yearTourismInput[2],
             Quarter >= input$quarterTourismInput[1] & Quarter <= input$quarterTourismInput[2]) %>%
      group_by(Quarter) %>%
      summarise(`Room` = sum(RoomRevenue),
                `Food & Beverage` = sum(`Food&Beverage Revenue`),	
                `Other` = sum(OtherRevenue))  %>%
      select(Quarter, `Room`, `Food & Beverage`,`Other`) %>%
      pivot_longer(-Quarter, names_to = "variable", values_to = "value")
  }
  
    ggplot(df, aes(Quarter, value, colour = variable)) + geom_line(size=2) + theme_minimal() +
      labs(x = "Quarter", y = "Total", color="Revenue Type") +  scale_y_continuous(labels = comma) +
      theme(legend.text = element_text(size = 10),
            legend.title = element_text(size = 10),
            axis.title = element_text(size = 10),
            axis.text = element_text(size = 10),
            axis.text.x = element_text(angle = 0, hjust = 1))
  
})


#=================== 
# Performance
#=================== 

  }

shinyApp(ui, server)
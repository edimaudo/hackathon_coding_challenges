################
# Shiny web app which provides 
# insights about  Toronto Public Library
################
rm(list = ls())
################
# Libraries
################
packages <- c(
  'rjson','dplyr',
  'ggplot2', 'corrplot','tidyverse','shiny','shinydashboard','bslib','DT','readxl',
  'mlbench','caTools','gridExtra','doParallel','grid','forecast','reshape2',
  'caret','dummies','tidyr','Matrix','lubridate','plotly','RColorBrewer',
  'data.table','scales','stopwords','tidytext','stringr','wordcloud','wordcloud2',
  'SnowballC','textmineR','topicmodels','textclean','tm'
)
for (package in packages) {
  if (!require(package, character.only = T, quietly = T)) {
    install.packages(package)
    library(package, character.only = T)
  }
}
################
# Data
################
tpl_clc <- read.csv("Computer_Learning_Centres.csv",sep = ",")  
tpl_dih <- read.csv("Digital_Innovation_Hubs.csv",sep = ",")
tpl_kecl <- read.csv("KidsStop_Early_Literacy_Centres.csv",sep = ",")
tpl_nib <- read.csv("Neighbourhood_Improvement_Area_Branches.csv",sep = ",")
tpl <- read.csv("tpl-branch-general-information-2023.csv",sep = ",")
tpl_branch_card_registration <- read.csv("tpl-card-registrations-annual-by-branch-2012-2022.csv",sep = ",")
tpl_branch_circulation <- read.csv("tpl-circulation-annual-by-branch-2012-2022.csv",sep = ",")
tpl_branch_eventfeed <- read.csv("tpl-events-feed.csv",sep = ",")
tpl_branch_visit <- read.csv("tpl-visits-annual-by-branch-2012-2022.csv",sep = ",")
tpl_branch_workstation <- read.csv("tpl-workstation-usage-annual-by-branch-2012-2022.csv",sep = ",")
tpl_yag <- read.csv("Youth_Advisory_Groups_Locations.csv",sep = ",")
tpl_yh <- read.csv("Youth_Hubs_Locations.csv",sep = ",")

tpl_branch_code <- function(branchName){
  tpl_branch <- tpl %>%
    filter(BranchName == branchName) %>%
    select(BranchCode)
}

tpl_branch <- tpl %>%
  filter(PhysicalBranch == 1) %>%
  select(BranchName) %>%
  arrange()

tpl_branch_eventfeed$Month <- lubridate::month(tpl_branch_eventfeed$startdate,label=TRUE,abbr = FALSE)
tpl_branch_eventfeed$DOW <- lubridate::wday(tpl_branch_eventfeed$startdate,label=TRUE,abbr = FALSE)


month <- tpl_branch_eventfeed %>%
  mutate(Month = factor(Month, levels = month.name)) %>%
  Select (Month) %>%
  arrange(Month)

################
# UI
################
ui <- dashboardPage(
  dashboardHeader(
    title = "TPL",
    tags$li(a(href = 'https://www.torontopubliclibrary.ca',
    img(src = 'https://upload.wikimedia.org/wikipedia/commons/4/47/Toronto_Public_Library_Logo.png',
    title = "Home", height = "30px"),
    style = "padding-top:10px; padding-bottom:10px;"),
    class = "dropdown")
    ),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("house")),
      menuItem("Branch", tabName = "branch", icon = icon("book")),
      menuItem("Branch Events", tabName = "branch_event", icon = icon("book")),
      menuItem("About", tabName = "about", icon = icon("th"))
    )
  ),
  dashboardBody(

    tabItems(
    #========  
    # Overview
    #========
      tabItem(tabName = "overview",
              fluidRow(
                valueBoxOutput("libraryBox"),
                valueBoxOutput("clcBox"),
                valueBoxOutput("keclBox"),
                valueBoxOutput("dihBox"),
                valueBoxOutput("yagBox"),
                valueBoxOutput("yhBox")
              ),
              
              fluidRow(
                h2("Trends",style="text-align: center;text-style:bold"),
                radioButtons( 
                  inputId = "radioTrend", 
                  label = "", 
                  choices = list( 
                    "Annual Card Registrations" = 1, 
                    "Annual Circulation" = 2, 
                    "Annual Visits" = 3,
                    "Annual Workstation Usage" = 4 
                  ) ,
                  inline=T
                ),
                plotlyOutput("tplOverviewTrendPlot") 
              )
      ),
    #========  
    # Branch
    #========
      tabItem(tabName = "branch",
              sidebarLayout(
                sidebarPanel(width = 3,
                             selectInput("branchInput", 
                                         label = "Branch",
                                         choices =tpl_branch)
                ),
                
                mainPanel (
                  fluidRow(
                    valueBoxOutput("branchCodeBox"),
                    valueBoxOutput("workStationsBox"),
                    #valueBoxOutput("serviceTierBox"),
                    valueBoxOutput("presentSiteBox")
                  ),
                  fluidRow(
                    valueBoxOutput("kidStopBox"),
                    valueBoxOutput("branchclcBox"),
                    #valueBoxOutput("branchdihBox"),
                    valueBoxOutput("teenCouncilBox")
                  ),
                  fluidRow(
                    dataTableOutput("branchTable")
                  ),
                  fluidRow(
                    h3("Branch Trends",style="text-align: center;text-style:bold"),
                    fluidRow(
                      radioButtons( 
                        inputId = "radioBranchTrend", 
                        label = "", 
                        choices = list( 
                          "Annual Card Registrations" = 1, 
                          "Annual Circulation" = 2, 
                          "Annual Visits" = 3,
                          "Annual Workstation Usage" = 4 
                        ) ,
                        inline=T
                      ),
                      plotlyOutput("tplBranchTrendPlot")
                    )
                  )
                )
      )
    ),
    #========  
    # Branch Events
    #========
    tabItem(tabName = "branch_event",
            sidebarLayout(
              sidebarPanel(width = 3,
                           selectInput("branchEventInput", 
                                       label = "Branch",
                                       choices =tpl_branch),
                           selectInput("monthEventInput", 
                                       label = "Month",
                                       choices =month)
              ),
              
              mainPanel (
                fluidRow(
                  #valueBoxOutput("branchCodeBox"),
                  #valueBoxOutput("workStationsBox"),
                  #valueBoxOutput("serviceTierBox"),
                  #valueBoxOutput("presentSiteBox")
                ),
                fluidRow(
                  #valueBoxOutput("kidStopBox"),
                  #valueBoxOutput("branchclcBox"),
                  #valueBoxOutput("branchdihBox"),
                  #valueBoxOutput("teenCouncilBox")
                ),
                fluidRow(
                  dataTableOutput("branchEventTable")
                )
              )
            )
    ),
    #========  
    # About
    #========
      tabItem(tabName = "about",includeMarkdown("about.md"),hr())
  )
 )
)
################
# Server
################
server <- function(input, output, session) {
  #-----------
  # Overview
  #-----------
  # of libraries
  output$libraryBox <- renderValueBox({
    tpl_library <- tpl %>%
      filter(PhysicalBranch == 1) %>%
      select(BranchName)
    
    valueBox(
      value = tags$p("Libraries", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(length(tpl_library$BranchName)), style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })
  
  # Computer_Learning_Centres
  output$clcBox <- renderValueBox({
    valueBox(
      value = tags$p("Computer Learning Centres", style = "font-size: 80%;"),
      subtitle = tags$p(paste0(length(tpl_clc$Branch.Name)), style = "font-size: 100%;"),
      icon = icon("computer"),    
      color = "aqua"
    )
  })  
  # of KidsStop_Early_Literacy_Centres
  output$keclBox <- renderValueBox({
    valueBox(
      value = tags$p("Early Literacy Centres", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(length(tpl_kecl$Branch.Name)), style = "font-size: 100%;"),
      icon = icon("child"),  
      color = "aqua"
    )
  })  
  
  # of Neighbourhood_Improvement_Area_Branches
  output$nibBox <- renderValueBox({
    valueBox(
      value = tags$p("Improvement Branches", style = "font-size: 80%;"),
      subtitle = tags$p(paste0(length(tpl_nib$Branch.Name)), style = "font-size: 100%;"),
      icon = icon("thumbs-up"),  
      color = "aqua"
    )
  })  
  # of Digital_Innovation_Hubs
  output$dihBox <- renderValueBox({
    valueBox(
      value = tags$p("Digital Innovation Hub", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(length(tpl_dih$Branch.Name)), style = "font-size: 100%;"),
      icon = icon("lightbulb"),  
      color = "aqua"
    )
  })    
  # of Youth_Advisory_Groups_Locations
  output$yagBox <- renderValueBox({
    valueBox(
      value = tags$p("Youth Advisory", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(length(tpl_yag$Branch.Name)), style = "font-size: 100%;"),
      icon = icon("person"),  
      color = "aqua"
    )
  })   
  # of Youth_Hubs_Locations
  output$yhBox <- renderValueBox({
    valueBox(
      value = tags$p("Youth Hub", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(length(tpl_yh$Branch.Name)), style = "font-size: 100%;"),
      icon = icon("person"), 
      color = "aqua"
    )
  }) 
  #-----------
  # Overview Trend
  #-----------
  output$tplOverviewTrendPlot <- renderPlotly({
    
    if (input$radioTrend == 1) {
      tpl_trend <- tpl_branch_card_registration %>%
        group_by(Year)%>%
        summarise(Total = sum(Registrations)) %>%
        select(Year, Total) 
    } else if (input$radioTrend == 2){
      
      tpl_trend <- tpl_branch_circulation%>%
        group_by(Year)%>%
        summarise(Total = sum(Circulation)) %>%
        select(Year, Total)
    } else if (input$radioTrend == 3){
      
      tpl_trend <- tpl_branch_visit%>%
        group_by(Year)%>%
        summarise(Total = sum(Visits)) %>%
        select(Year, Total)
    } else if (input$radioTrend == 4){
      
      tpl_trend <- tpl_branch_workstation%>%
        group_by(Year)%>%
        summarise(Total = sum(Sessions)) %>%
        select(Year, Total)
    }
    
    g <- ggplot(tpl_trend, aes(x = Year, y = Total))  +
      geom_bar(stat = "identity",width = 0.5, fill='#0474ca') + theme_classic() + 
      labs(x ="Year", y = "Total") + scale_x_continuous(breaks = breaks_pretty()) + 
      scale_y_continuous(breaks = breaks_pretty(),labels = label_comma()) + 
      theme(legend.text = element_text(size = 12),
            legend.title = element_text(size = 12),
            axis.title = element_text(size = 14),
            axis.text = element_text(size = 12))
    
    ggplotly(g)
    
  })
    
  
  #-----------
  # Branch boxes
  #-----------
  tpl_branch_info  <- reactive({
    tpl %>%
      filter(PhysicalBranch == 1, BranchName==input$branchInput) %>%
      select(BranchName,BranchCode,Workstations,ServiceTier,PresentSiteYear,KidsStop,CLC,DIH,TeenCouncil)
  }) 
  

  output$branchCodeBox <- renderValueBox({
    valueBox(
      value = tags$p("Branch Code", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(tpl_branch_info()$BranchCode), style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })

  output$workStationsBox <- renderValueBox({
    valueBox(
      value = tags$p("Workstations", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(tpl_branch_info()$Workstations), style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })

  output$serviceTierBox <- renderValueBox({
    valueBox(
      value = tags$p("Service Tier", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(tpl_branch_info()$ServiceTier), style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })

  output$presentSiteBox <- renderValueBox({
    valueBox(
      value = tags$p("Available Since", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(tpl_branch_info()$PresentSiteYear), style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })

  output$kidStopBox <- renderValueBox({
    valueBox(
      value = tags$p("Kid Stop", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(tpl_branch_info()$KidsStop), style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })

  output$branchclcBox <- renderValueBox({
    valueBox(
      value = tags$p("CLC", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(tpl_branch_info()$CLC), style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })

  output$branchdihBox <- renderValueBox({
    valueBox(
      value = tags$p("DIH", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(tpl_branch_info()$DIH), style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })

  output$teenCouncilBox <- renderValueBox({
    valueBox(
      value = tags$p("Youth Council", style = "font-size: 100%;"),
      subtitle = tags$p(paste0(tpl_branch_info()$TeenCouncil), style = "font-size: 100%;"),
      icon = icon("book"),
      color = "aqua"
    )
  })
# 
  #-----------
  # Branch Table
  #-----------
  tbl_branch_table <- reactive({
    tpl %>%
      filter(PhysicalBranch == 1, BranchName == input$branchInput) %>%
      select(Address,PostalCode,WardName,Website,Telephone,SquareFootage)
  })
  
  output$branchTable <- renderDataTable({
      tbl_branch_table()
  })

  #-----------
  # Branch Trend
  #-----------
    output$tplBranchTrendPlot <- renderPlotly({
      if (input$radioBranchTrend == 1) {
        #- tpl-card-registrations-annual-by-branch-2012-2022
        tpl_trend <- tpl_branch_card_registration %>%
          filter(BranchCode == tpl_branch_code(input$branchInput)[,1]) %>%
          group_by(Year)%>%
          summarise(Total = sum(Registrations)) %>%
          select(Year, Total)
      } else if (input$radioBranchTrend == 2){
        #- tpl-circulation-annual-by-branch-2012-2022
        tpl_trend <- tpl_branch_circulation%>%
          filter(BranchCode == tpl_branch_code(input$branchInput)[,1]) %>%
          group_by(Year)%>%
          summarise(Total = sum(Circulation)) %>%
          select(Year, Total)
      } else if (input$radioBranchTrend == 3){
        #- tpl-visits-annual-by-branch-2012-2022
        tpl_trend <- tpl_branch_visit%>%
          filter(BranchCode == tpl_branch_code(input$branchInput)[,1]) %>%
          group_by(Year)%>%
          summarise(Total = sum(Visits)) %>%
          select(Year, Total)
      } else if (input$radioBranchTrend == 4){
        #- tpl-workstation-usage-annual-by-branch-2012-2022
        tpl_trend <- tpl_branch_workstation%>%
          filter(BranchCode == tpl_branch_code(input$branchInput)[,1]) %>%
          group_by(Year)%>%
          summarise(Total = sum(Sessions)) %>%
          select(Year, Total)
      }

      g <- ggplot(tpl_trend, aes(x = Year, y = Total))  +
        geom_bar(stat = "identity",width = 0.5, fill='#0474ca') + theme_classic() +
        labs(x ="Year", y = "Total") + scale_x_continuous(breaks = breaks_pretty()) +
        scale_y_continuous(breaks = breaks_pretty(),labels = label_comma()) +
        theme(legend.text = element_text(size = 12),
              legend.title = element_text(size = 12),
              axis.title = element_text(size = 14),
              axis.text = element_text(size = 12))

      ggplotly(g)

    })
  #-----------
  # Branch Events
  #-----------
  
  tpl_event_info  <- reactive({
    tpl_branch_eventfeed %>%
      filter(library==input$branchEventInput, Month = monthEventInput) %>%
      select(title, description,location,pagelink,eventtype1,eventtype2,eventtype3,agregroup1,Month,DOW)
  }) 
  
  #-----------
  # Branch Event sentiment analysis
  #-----------
  
  #-----------
  # Branch Event word cloud
  #-----------
  
  
  #-----------
  # Branch Events Table
  #-----------
  output$branchEventTable <- renderDataTable({
    tpl_event_info()
  })
  
  

}

shinyApp(ui, server)
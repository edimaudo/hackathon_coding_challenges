

#packages 
packages <- c('ggplot2', 'corrplot','tidyverse','shiny',
              'countrycode','shinydashboard','highcharter',"gridExtra","scales")
#load packages
for (package in packages) {
    if (!require(package, character.only=T, quietly=T)) {
        install.packages(package)
        library(package, character.only=T)
    }
}

#load data
df <- read.csv("otf.csv")


yearInfo <- length(unique(df$year))
grantInfo <- length(unique(df$grant_program2))
organizationInfo <- length(unique(df$organization_name))
amountAwardedInfo <- sum(df$amount_awarded)
ageGroupInfo <- length(unique(df$age_group2))
budgetInfo <- length(unique(df$budget_fund))
cityInfo <- length(unique(df$city2))

yearSliderInput <- sort(as.vector(unique(df$year)))
yearData = as.array(yearSliderInput)
futureYears = c(2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023,2024,2025,2026,2027,
                2028,2029,2030)


#app
ui <- dashboardPage(
    dashboardHeader(title = "Ontario Trillium Fund analysis"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Introduction", tabName = "Introduction", icon = icon("dashboard")),
            menuItem("Summary", tabName = "Summary", icon = icon("dashboard")),
            menuItem("Trends", tabName = "Trends", icon = icon("th")),
            menuItem("Text Analysis", tabName = "TextAnalysis", icon = icon("th")),
            menuItem("Amount Regression", tabName = "AmountRegression", icon = icon("dashboard"))
            
        )
    ),
    dashboardBody(
        tabItems(
            tabItem(tabName = "Introduction",
                    includeMarkdown("intro.md")),
            tabItem(tabName = "Summary",
                    fluidRow(
                        infoBoxOutput("yearInfo"),
                        infoBoxOutput("grantInfo")
                    ),
                    fluidRow(
                        infoBoxOutput("organizationalInfo"),
                        infoBoxOutput("amountAwardedInfo")
                    ), 
                    fluidRow(
                        infoBoxOutput("areaInfo"),
                        infoBoxOutput("budgetInfo")
                    )
            ),
            tabItem(tabName = "Trends",
                    sidebarLayout(
                        sidebarPanel(
                            sliderInput("Years", "Years:", min = 1999, max = 2019, 
                                        value = yearSliderInput, step=1, ticks = FALSE, sep="")
                        ),
                        mainPanel(
                            fluidRow(
                             h2("Grants and Amount Awarded",style="text-align: center;"),
                             plotOutput("grantAwarded")
                            ),
                            fluidRow(
                                h2("Budget areas and Amount Awarded",style="text-align: center;"),
                                plotOutput("budgetAwarded")
                            ), 
                            fluidRow(
                                h2("Program areas and Amount Awarded",style="text-align: center;"),
                                plotOutput("programAwarded")
                            )
                        )
                    )
            ), 
            tabItem(tabName = "AmountRegression",
                    sidebarLayout(
                        sidebarPanel (
                            selectInput("yearInput", label = "Year",choices = futureYears),
                            selectInput("planInput","Planned date", choices=c()),
                            selectInput("budgetFundInput","Budget Fund", choices=c()),
                            selectInput("coappInput","Co applications", choices=c()),
                            selectInput("grantInput","Grant Programs", choices=c()),
                            selectInput("cityInput","City", choices=c())
                        ), 
                        mainPanel(
                            
                        )
                    )
            )
        )
    )
)


server <- function(input, output) {
    
    # of years
    output$yearInfo <- renderInfoBox({
        infoBox(
            "# of Years", paste0(yearInfo), icon = icon("list"),
            color = "blue"
        )
    })
    
    # grant information
    output$grantInfo <- renderInfoBox({
        infoBox(
            "Type of Grants", paste0(grantInfo), icon = icon("list"),
            color = "blue", fill = TRUE
        )
    })
    
    # of organizations
    output$organizationalInfo <- renderInfoBox({
        infoBox(
            "# of Organizations", paste0(organizationInfo), icon = icon("list"),
            color = "blue"
        )
    })
    
    # dollar amount
    output$amountAwardedInfo <- renderInfoBox({
        infoBox(
            "$ value of grants awarded", paste0(amountAwardedInfo, " CAD"), icon = icon("list"),
            color = "blue", fill = TRUE
        )
    })
    
    #types of budget
    output$budgetInfo <- renderInfoBox({
        infoBox(
            "Types of budget", paste0(budgetInfo), icon = icon("list"),
            color = "blue",fill = TRUE
        )
    })    
    
    # of cities for summary page
    output$areaInfo <- renderInfoBox({
        infoBox(
            "# of places covered by grants", paste0(cityInfo), icon = icon("list"),
            color = "blue"
        )
    })
    
    #visualizations
    output$grantAwarded <- renderPlot({
        
        data<-df[df$year >= input$Years[[1]] & df$year <= input$Years[[2]],]
        
        yearAwardedGrantProgram <- data %>%
            #filter(year %in% input$Years) %>%
            group_by(year,grant_program2) %>%
            summarize(total_awarded = sum(amount_awarded))
        
        ggplot(data=yearAwardedGrantProgram, aes(x=as.factor(year), y=total_awarded, fill=grant_program2)) +
            geom_bar(stat="identity", width = 0.4) + theme_classic() +
            labs(x = "Years", y = "Amount awarded (CAD)", fill  = "Grant Programs") +
            scale_y_continuous(labels = comma) +
            scale_x_discrete() +
            theme(legend.text = element_text(size = 10),
                  legend.title = element_text(size = 10),
                  axis.title = element_text(size = 15),
                  axis.text = element_text(size = 10),
                  axis.text.x = element_text(angle = 45, hjust = 1))
    })
    
    #budget fund
    output$budgetAwarded <- renderPlot({
        data<-df[df$year >= input$Years[[1]] & df$year <= input$Years[[2]],]
        
        yearAwardedBudget <- data %>%
            group_by(year,budget_fund) %>%
            summarize(total_awarded = sum(amount_awarded))
        
        ggplot(data=yearAwardedBudget, aes(x=as.factor(year), y=total_awarded, fill=budget_fund)) +
            geom_bar(stat="identity", width = 0.4) + theme_classic() +
            labs(x = "Years", y = "Amount awarded (CAD)", fill  = "Budget funds") +
            scale_y_continuous(labels = comma) +
            scale_x_discrete() +
            theme(legend.text = element_text(size = 10),
                  legend.title = element_text(size = 10),
                  axis.title = element_text(size = 15),
                  axis.text = element_text(size = 10),
                  axis.text.x = element_text(angle = 45, hjust = 1))       
    })
    
    #programs
    output$programAwarded <- renderPlot({
        data<-df[df$year >= input$Years[[1]] & df$year <= input$Years[[2]],]
        
        yearAwardedProgram <- data %>%
            group_by(year,program_area) %>%
            summarize(total_awarded = sum(amount_awarded))
        
        ggplot(data=yearAwardedProgram, aes(x=as.factor(year), y=total_awarded, fill=program_area)) +
            geom_bar(stat="identity", width = 0.4) + theme_classic() +
            labs(x = "Years", y = "Amount awarded (CAD)", fill  = "Program Areas") +
            scale_y_continuous(labels = comma) +
            scale_x_discrete() +
            theme(legend.text = element_text(size = 10),
                  legend.title = element_text(size = 10),
                  axis.title = element_text(size = 15),
                  axis.text = element_text(size = 10),
                  axis.text.x = element_text(angle = 45, hjust = 1))       
    })       
      
            
    

}

shinyApp(ui, server)
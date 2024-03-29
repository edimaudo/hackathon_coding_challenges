#add business logic

#packages 
packages <- c('ggplot2', 'corrplot','tidyverse','shiny','shinydashboard')
#load packages
for (package in packages) {
    if (!require(package, character.only=T, quietly=T)) {
        install.packages(package)
        library(package, character.only=T)
    }
}

# Define UI for application
ui <- dashboardPage(
    dashboardHeader(title = "Side Project SaaS Price Generator"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Introduction", tabName = "Introduction", icon = icon("dashboard")),
            menuItem("Price Generator", tabName = "priceGenerator", icon = icon("th"))
        )
    ),
    dashboardBody(
        tabItems(
            tabItem(tabName = "Introduction",includeMarkdown("readme.md"),hr()),
            tabItem(tabName = "priceGenerator",
                    sidebarLayout(
                        sidebarPanel(
                            sliderInput("week","How many hours per week?" ,min = 0, max = 60, 
                                        value = 1, step=1, ticks = TRUE, sep=""),
                            sliderInput("cost","What are your fixed costs (per month)?", min = 0, max = 1000, 
                                        value = 100, step=10, ticks = TRUE, sep=""),
                            sliderInput("varCost","What are your variable costs per 1000 users?", min = 0, max = 1000, 
                                        value = 50, step=50, ticks = TRUE, sep=""),
                            sliderInput("userPay:","What percent of users will pay?", min = 0, max = 100, 
                                        value = 10, step=1, ticks = TRUE, sep=""),
                            sliderInput("salary","How much do you make in your current job?", min = 20000, max = 100000, 
                                        value = 50000, step=5000, ticks = TRUE, sep=""),
                            sliderInput("margin","What margins do you want?", min = 0, max = 100, 
                                        value = 50, step=10, ticks = TRUE, sep=""),
                            sliderInput("user","How many users will you have?", min = 0, max = 1000, 
                                        value = 100, step=10, ticks = TRUE, sep=""),
                        ),
                        mainPanel(
                            h2("Side Project SaaS Price Generator",style="text-align: center;"),
                            fluidRow(
                                valueBoxOutput("monthlyPriceOutput"),
                            ),
                            h3("Explanation",style="text-align: center;"),
                            fluidRow(
                                infoBoxOutput("rateOutput")
                            ),
                            fluidRow(
                                infoBoxOutput("projectCostOuput") 
                            ),
                            fluidRow(
                                infoBoxOutput("userCostOutput")
                            )
                        )
        
                    )
            )
        )
    )
)

# Define server logic 
server <- function(input, output) {
    output$monthlyPriceOutput <- renderValueBox({
        infoBox(
            "You should charge your users: ", paste0(""), icon = icon("list"),
            color = "blue"
        )
    })
    
    
    output$rateOutput <- renderInfoBox({
        infoBox(
            "Your rate per month is: ", paste0("1"), icon = icon("list"),
            color = "blue", fill = TRUE
        )
    })
    
    output$projectCostOuput <- renderInfoBox({
        infoBox(
            "Your project cost per month is: ", paste0("1"), icon = icon("list"),
            color = "blue", fill = TRUE
        )
    })
    
    output$userCostOutput <- renderInfoBox({
        infoBox(
            "User cost per month is: ", paste0("1"), icon = icon("list"),
            color = "blue", fill = TRUE
        )
    })

}

# Run the application 
shinyApp(ui = ui, server = server)

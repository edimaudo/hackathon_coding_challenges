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
    dashboardHeader(title = "SaaS Price Generator"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Introduction", tabName = "Introduction", icon = icon("dashboard")),
            menuItem("Price Generator", tabName = "priceGenerator", icon = icon("th"))
        )
    ),
    dashboardBody(
        tabItems(
            tabItem(tabName = "Introduction",hr()), #includeMarkdown("intro.md")
            tabItem(tabName = "priceGenerator",
                    sidebarLayout(
                        sidebarPanel(
                            sliderInput("How many hours per week", "week:", min = 1, max = 60, value = 1, step=1, ticks = FALSE, sep=""),
                            sliderInput("What are your fixed costs (per month", "cost:", min = 1, max = 10000, value = 50, step=50, ticks = FALSE, sep=""),
                            sliderInput("What are your variable costs per 1000 users", "varcost:", min = 50, max = 10000, value = 50, step=50, ticks = FALSE, sep=""),
                            
                        ),
                        mainPanel(
                            fluidRow(
                                h2("Price Generator",style="text-align: center;"),
                                
                            )
                        )
        
                    )
            )
        )
    )
)

# Define server logic 
server <- function(input, output) {


}

# Run the application 
shinyApp(ui = ui, server = server)

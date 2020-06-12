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
                            sliderInput("Years", "Years:", min = 1999, max = 2019, 
                                        value = yearSliderInput, step=1, ticks = FALSE, sep="")
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

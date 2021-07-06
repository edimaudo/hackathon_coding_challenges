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

# Define server logic required to draw a histogram
server <- function(input, output, session) {

  
}

# Run the application 
shinyApp(ui = ui, server = server)

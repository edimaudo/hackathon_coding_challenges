

#packages 
packages <- c('ggplot2', 'corrplot','tidyverse','shiny',
              'countrycode','shinydashboard','highcharter',"gridExtra")
#load packages
for (package in packages) {
    if (!require(package, character.only=T, quietly=T)) {
        install.packages(package)
        library(package, character.only=T)
    }
}

#load data
df <- read.csv("")
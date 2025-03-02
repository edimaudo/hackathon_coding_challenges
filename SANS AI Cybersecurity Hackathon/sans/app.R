# Shiny web app to analyze time series cpu usage
####### Libraries #####

# library(ggplot2)
# library(tidyverse)
# library(shiny)
# library(shinydashboard)
# library(DT)
# library(lubridate)
# library(plotly)
# library(RColorBrewer)
# library(scales)
# library(readxl)
# library(anomalize)

packages <- c(
  'ggplot2','tidyverse','plotly','leaflet',
  'shiny','shinydashboard','readxl',
  'xts','forecast','anomalize',
  'DT','lubridate','RColorBrewer','scales'
)
for (package in packages) { 
  if (!require(package, character.only = T, quietly = T)) {
    install.packages(package)
    library(package, character.only = T)
  }
}
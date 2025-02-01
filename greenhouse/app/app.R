packages <- c(
  'ggplot2','tidyverse','plotly','leaflet',
  'shiny','shinyWidgets','shinydashboard',
  'xts','forecast','TTR',
  'DT','lubridate','RColorBrewer','scales','stopwords',
  'tidytext','stringr','wordcloud','wordcloud2',
  'SnowballC','textmineR','topicmodels','textclean','tm'
)
for (package in packages) { 
  if (!require(package, character.only = T, quietly = T)) {
    install.packages(package)
    library(package, character.only = T)
  }
}
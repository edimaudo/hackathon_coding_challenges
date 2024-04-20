#=========================================
rm(list = ls())
#=============
# Packages 
#=============
packages <- c(
  'ggplot2', 'corrplot','tidyverse','shiny','shinydashboard','DT','readxl',
  'mlbench','caTools','gridExtra','doParallel','grid','forecast','reshape2',
  'caret','dummies','tidyr','Matrix','lubridate','plotly','RColorBrewer',
  'data.table','scales','rfm','forecast','TTR','xts'
)
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}

#=============
# Load Data
#=============
cadmium <- read_csv("Cadmium emissions to air by facility.csv")
lead <- read_csv("Lead emissions to air by facility.csv")
mecury <- read_csv("Mercury emissions to air by facility.csv")

#=============
# Exploratory analysis
#=============

group_by(INTERACTION_TYPE) %>%
  summarise(Total = sum(SUBSTANTIVE_INTERACTION)) %>%
  select(INTERACTION_TYPE, Total) %>%
  ggplot(aes(x = reorder(INTERACTION_TYPE,Total) ,y = Total))  +
  geom_bar(stat = "identity",width = 0.5, fill='black') + theme_classic() + 
  labs(x ="Interaction Type", y = "Total Interactions") + coord_flip() +
  theme(legend.text = element_text(size = 12),
        legend.title = element_text(size = 12),
        axis.title = element_text(size = 14),
        axis.text = element_text(size = 12))

# top 10 mecury emissions by facility
df_mecury_facility <- mecury %>%
  group_by(`Facility name`) %>%
  summarise(Total = sum(as.double(Emissions))) %>%
  select(`Facility name`, Total) %>%
  arrange(desc(Total)) %>%
  top_n(10) %>%
  ggplot(aes(x = reorder(`Facility name`,Total) ,y = Total))  +
  geom_bar(stat = "identity",width = 0.5, fill='black') + theme_classic() + 
  labs(x ="Facility Name", y = "Total Emissions(Kg)") + coord_flip() +
  theme(legend.text = element_text(size = 12),
        legend.title = element_text(size = 12),
        axis.title = element_text(size = 14),
        axis.text = element_text(size = 12))
  
  
ggplotly(df_mecury_facility)


# top 10 mecury emissions by company
df_mecury_company <- mecury %>%
  group_by(`Company name`) %>%
  summarise(Total = sum(as.double(Emissions))) %>%
  select(`Company name`, Total) %>%
  arrange(desc(Total)) %>%
  top_n(10) %>%
  ggplot(aes(x = reorder(`Company name`,Total) ,y = Total))  +
  geom_bar(stat = "identity",width = 0.5, fill='black') + theme_classic() + 
  labs(x ="Company Name", y = "Total Emissions(Kg)") + coord_flip() +
  theme(legend.text = element_text(size = 12),
        legend.title = element_text(size = 12),
        axis.title = element_text(size = 14),
        axis.text = element_text(size = 12))

ggplotly(df_mecury_company)

# top 10 mecury emissions by City
# top 10 mecury emissions by Province
# 
# top 10 cadmium emissions by facility
# top 10 cadmium emissions by company
# top 10 cadmium emissions by City
# top 10 cadmium emissions by Province
# 
# top 10 lead emissions by facility
# top 10 lead emissions by company
# top 10 lead emissions by City
# top 10 lead emissions by Province

# top 10 mecury emissions by facility map
# top 10 mecury emissions by company map
# top 10 mecury emissions by City map
# top 10 mecury emissions by Province map
# 
# top 10 cadmium emissions by facility map
# top 10 cadmium emissions by company map
# top 10 cadmium emissions by City map
# top 10 cadmium emissions by Province map
# 
# top 10 lead emissions by facility map
# top 10 lead emissions by company map
# top 10 lead emissions by City map
# top 10 lead emissions by Province map

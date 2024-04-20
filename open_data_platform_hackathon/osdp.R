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
df_mecury_city <- mecury %>%
  group_by(City) %>%
  summarise(Total = sum(as.double(Emissions))) %>%
  select(City, Total) %>%
  arrange(desc(Total)) %>%
  top_n(10) %>%
  ggplot(aes(x = reorder(City,Total) ,y = Total))  +
  geom_bar(stat = "identity",width = 0.5, fill='black') + theme_classic() + 
  labs(x ="City", y = "Total Emissions(Kg)") + coord_flip() +
  theme(legend.text = element_text(size = 12),
        legend.title = element_text(size = 12),
        axis.title = element_text(size = 14),
        axis.text = element_text(size = 12))

ggplotly(df_mecury_city)

# top 10 mecury emissions by Province

mecury$Emissions <- replace(mecury$Emissions, "-", NA) 
mecury$Emissions[is.na(mecury$Emissions)] <- 0

df_mecury_province <- mecury %>%
  group_by(Province) %>%
  summarise(Total = sum(as.double(Emissions))) %>%
  select(Province, Total) %>%
  arrange(desc(Total)) %>%
  top_n(10) %>%
  ggplot(aes(x = reorder(Province,Total) ,y = Total))  +
  geom_bar(stat = "identity",width = 0.5, fill='black') + theme_classic() + 
  labs(x ="Province", y = "Total Emissions(Kg)") + coord_flip() +
  theme(legend.text = element_text(size = 12),
        legend.title = element_text(size = 12),
        axis.title = element_text(size = 14),
        axis.text = element_text(size = 12))

ggplotly(df_mecury_province)
# 
# top 10 cadmium emissions by facility
df_facility <- cadmium %>%
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


ggplotly(df_facility)
# top 10 cadmium emissions by company
df_company <- cadmium %>%
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

ggplotly(df_company)

# top 10 cadmium emissions by City
df_city <- cadmium %>%
  group_by(City) %>%
  summarise(Total = sum(as.double(Emissions))) %>%
  select(City, Total) %>%
  arrange(desc(Total)) %>%
  top_n(10) %>%
  ggplot(aes(x = reorder(City,Total) ,y = Total))  +
  geom_bar(stat = "identity",width = 0.5, fill='black') + theme_classic() + 
  labs(x ="City", y = "Total Emissions(Kg)") + coord_flip() +
  theme(legend.text = element_text(size = 12),
        legend.title = element_text(size = 12),
        axis.title = element_text(size = 14),
        axis.text = element_text(size = 12))

ggplotly(df_city)

# top 10 cadmium emissions by Province
df_province <- cadmium %>%
  group_by(Province) %>%
  summarise(Total = sum(as.double(Emissions))) %>%
  select(Province, Total) %>%
  arrange(desc(Total)) %>%
  top_n(10) %>%
  ggplot(aes(x = reorder(Province,Total) ,y = Total))  +
  geom_bar(stat = "identity",width = 0.5, fill='black') + theme_classic() + 
  labs(x ="Province", y = "Total Emissions(Kg)") + coord_flip() +
  theme(legend.text = element_text(size = 12),
        legend.title = element_text(size = 12),
        axis.title = element_text(size = 14),
        axis.text = element_text(size = 12))

ggplotly(df_province)

# lead
df_facility <- lead %>%
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


ggplotly(df_facility)
# top 10 lead emissions by company
df_company <- lead %>%
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

ggplotly(df_company)

# top 10 lead emissions by City
df_city <- lead %>%
  group_by(City) %>%
  summarise(Total = sum(as.double(Emissions))) %>%
  select(City, Total) %>%
  arrange(desc(Total)) %>%
  top_n(10) %>%
  ggplot(aes(x = reorder(City,Total) ,y = Total))  +
  geom_bar(stat = "identity",width = 0.5, fill='black') + theme_classic() + 
  labs(x ="City", y = "Total Emissions(Kg)") + coord_flip() +
  theme(legend.text = element_text(size = 12),
        legend.title = element_text(size = 12),
        axis.title = element_text(size = 14),
        axis.text = element_text(size = 12))

ggplotly(df_city)

# top 10 lead emissions by Province
df_province <- lead %>%
  group_by(Province) %>%
  summarise(Total = sum(as.double(Emissions))) %>%
  select(Province, Total) %>%
  arrange(desc(Total)) %>%
  top_n(10) %>%
  ggplot(aes(x = reorder(Province,Total) ,y = Total))  +
  geom_bar(stat = "identity",width = 0.5, fill='black') + theme_classic() + 
  labs(x ="Province", y = "Total Emissions(Kg)") + coord_flip() +
  theme(legend.text = element_text(size = 12),
        legend.title = element_text(size = 12),
        axis.title = element_text(size = 14),
        axis.text = element_text(size = 12))

ggplotly(df_province)


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

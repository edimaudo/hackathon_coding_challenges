# Open data addathon
rm(list = ls()) #clear environment
#===============
# Libraries
#===============
packages <- c('ggplot2', 'corrplot','tidyverse',"caret",'scales',
              'dplyr','mlbench','caTools','forecast','TTR','xts','lubridate','shiny',
              'shinydashboard','tidyr','gridExtra','stopwords','tidytext','stringr',
              'reshape2', 'textdata','textmineR','topicmodels','textclean','pals','lubridate')
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}
#=============
# Load data
#=============

# Health
cancer_death <- read.csv("Cancer Death - Data.csv")
cancer_incidence <- read.csv("CancerIncidence.csv")
communicable_disease <- read.csv("Communicable Diseases - Data.csv")
episode <- read.csv("Episodes - Data.csv")
patient_number <- read.csv("Number of annual patients_1.csv")
patient_classification <- read.csv("Patient Classification according to gender_1.csv")
payer_claims <- read.csv("Payer Claims - Data.csv")
patient_addiction <- read.csv("Percentage of addiction on the various  substances for NRC patients_0.csv")
population_benchmarks <- read.csv("Population & Benchmarks - Data.csv")


#Update Nationality
cancer_death$Nationality <- ifelse(cancer_death$Nationality=="Expatriate","Expatriates",ifelse(
  cancer_death$Nationality=="National","Nationals","Unknown"))

cancer_nationality <- c("All",sort(unique(cancer_death$Nationality)))
cancer_gender <- c("All",sort(unique(cancer_death$Gender)))
cancer_year <- c("All",sort(unique(cancer_death$Year)))

df <- cancer_incidence %>%
  group_by(Year) %>%
  summarise(Total = sum(Count)) %>%
  select(Year, Total)

df <- cancer_death %>%
  group_by(Cancer.site) %>%
  summarise(Total = sum(Count)) %>%
  arrange(desc(Total)) %>%
  top_n(5)%>%
  select(Cancer.site, Total)

ggplot(df, aes(reorder(Cancer.site,Total), Total)) + 
  geom_bar(stat="identity", width = 0.5, position="dodge") +  coord_flip() +
  theme_minimal() + scale_y_continuous(labels = comma) +
  labs(x = "Cancer Site", y = "Total", fill="Gender") + 
  theme(legend.text = element_text(size = 12),
        legend.title = element_text(size = 15),
        axis.title = element_text(size = 15),
        axis.text = element_text(size = 15),
        axis.text.x = element_text(angle = 0, hjust = 1))

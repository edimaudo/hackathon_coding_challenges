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

communicable_disease$Nationality <- ifelse(communicable_disease$Nationality=="Expatriate",
                                           "Expatriates",
                                           ifelse(communicable_disease$Nationality=="National",
                                                  "Nationals","Unknown"))

communicable_disease$Cases <- as.numeric(communicable_disease$Cases)

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

communicable_disease$Cases <- parse_number(communicable_disease$Cases)
df <- communicable_disease %>%
  group_by(Year) %>%
  summarise(Total = sum(Cases)) %>%
  select(Year, Total)

ggplot(data=df, aes(x=Year, y=Total, group=1)) +
  geom_line()+
  geom_point() + theme_minimal() +
  labs(x = "Year", y = "Total") + 
  theme(legend.text = element_text(size = 12),
        legend.title = element_text(size = 15),
        axis.title = element_text(size = 15),
        axis.text = element_text(size = 15),
        axis.text.x = element_text(angle = 0, hjust = 1))




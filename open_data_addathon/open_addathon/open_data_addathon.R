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

guest_purpose <- read_excel("Tourism.xlsx",sheet = "Guest_by_purpose")
top_country_visitors <- read_excel("Tourism.xlsx", sheet ="Top_Country_Hotel_Guest")
city_hotel_rooms <- read_excel("Tourism.xlsx",sheet ="City_Hotel_Rooms")

revenue_star_rating <- read_excel("Tourism.xlsx", sheet ="Revenue_Star_Rating")
revenue_region <- read_excel("Tourism.xlsx", sheet ="Revenue_Region")

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

df <- top_country_visitors  %>%
  filter(Year >= 2018 & Year <= 2020) %>%
  group_by(Country) %>%
  summarise(Total = sum(Total)) %>%
  arrange(desc(Total)) %>%
  select(Country, Year, Total)


ggplot(df, aes(Country,Total)) + 
  geom_bar(stat="identity", width = 0.5, aes(fill = Year)) +
  theme_minimal() + scale_y_continuous(labels = comma) + coord_flip() +
  labs(x = "Country", y = "Total", fill="Purpose of Visit") + 
  theme(legend.text = element_text(size = 10),
        legend.title = element_text(size = 10),
        axis.title = element_text(size = 10),
        axis.text = element_text(size = 10),
        axis.text.x = element_text(angle = 0, hjust = 1))


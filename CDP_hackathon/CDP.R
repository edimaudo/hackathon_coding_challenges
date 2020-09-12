# =======================================================
# Objective
# Challenge 1 Overview: City-Business Collaboration
# To identify opportunities for companies and cities to collaborate on sustainability solutions, 
# we need to first understand how the data they each report is aligned or divergent by 
# using data science and text analytics techniques.

#Task:
# Utilize data science and text analytics techniques to improve readability of CDP cities and 
  # corporate data.
# Visualize shared sentiment between cities and companies on specific 
  # topics (such as clean energy, sustainable buildings, clean transport, 
  # waste and circular economy).
# Create a KPI model that measures the propensity of cities to collaborate with companies. 
  # Provide the justification of your weights and indicators.

# =======================================================
# Judging crtieria
# =======================================================
# Use of CDP and external data
# Does your team utilize the CDP data provided in combination with external data sources?
# 
# Outcome
# Does your team have a clear understanding of the challenge? 
# Do you address the challenge prompt?
# 
# Feasibility of idea
# Can your solution viably be implemented and sustained in the real world?
# 
# Innovation
# Are you thinking outside of the box? 
# Does the solution implement trends and best practice from other innovative areas?
# 
# Technical explanation
# Each challenge asks teams to explain their technical decisions 
# (i.e. Justify weights, explain assumptions, etc). 
# Are clear justifications or explanations provided?

# =======================================================
rm(list=ls()) #clear environment
# =======================================================
# load packages
# =======================================================
packages <- c('ggplot2', 'corrplot','tidyverse','dplyr','tidyr','tidytext',
              'caret','mlbench','mice','scales','proxy','reshape2',
              'caTools','dummies','scales','catboost', 'Matrix','stringr',
              'topicmodels',"textmineR","ldatuning",'gmp','reshape2','purrr')

for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}

# =======================================================
# load data
# =======================================================
corporate_data <- read_csv("2018-2019_CorporateCC_mb2.csv")
city_data <- read_csv("Cities_Data_2017-2019_mb2.csv")
city_adaptation_2018 <- read_csv("2018_Cities_Adaptation_Actions.csv")
city_response_2018 <- read_csv("2018_A_list_Cities_with_Response_Links.csv")
city_2018_2019 <- read_csv("2018_-_2019_Full_Cities_Dataset.csv")
city_response_2019 <- read_csv("2019_A_list_Cities_with_Response_Links.csv")
city_adaptation_2019 <- read_csv("2019_Cities_Adaptation_Actions.csv") 
sustainability <- read_csv("ready-for-100.csv")

# =======================================================
# data exploration
# =======================================================
print("corproate data summary")
summary(corporate_data)

print("city data summary")
summary(city_data)

# check for missing data
missing_data_corporate <- apply(corporate_data, 2, function(x) any(is.na(x))) 
print("corporate data")
print(missing_data_corporate)

missing_data_city<- apply(city_data, 2, function(x) any(is.na(x))) 
print("city data")
print(missing_data_city)

# =======================================================
# Experimentation
# =======================================================

# generate 2018 and 2019 data
city_2018_2019_df <- city_data %>%
  filter(`Project Year` %in% c(2018,2019)) %>%
  select(`Project Year`, `Account Name`, `Account Number`, 
         `Question Name`, `Column Name`, `Response Answer`)


tidy_city_data <- city_2018_2019_df %>%
  unnest_tokens(word, `Response Answer`)

#word count visualization
tidy_city_data %>%
  count(word, sort = TRUE) %>%
  filter(n > 5000) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_col() +
  xlab(NULL) +
  coord_flip()

# term frequency
tidy_city_data2  <- city_2018_2019_df %>%
  unnest_tokens(word, `Response Answer`) %>%
  count(`Account Name`, word, sort = TRUE) %>%
  ungroup()

total_tidy_city_data2 <- tidy_city_data2 %>% 
  group_by(`Account Name`) %>% 
  summarize(total = sum(n))

tidy_city_data2 <- left_join(tidy_city_data2, total_tidy_city_data2)

ggplot(tidy_city_data2, aes(n/total, fill = `Account Name`)) +
  geom_histogram(show.legend = FALSE) +
  facet_wrap(~`Account Name`, ncol = 2, scales = "free_y")

#zipf law
freq_by_rank <- tidy_city_data2 %>% 
  group_by(`Account Name`) %>% 
  mutate(rank = row_number(), 
         `term frequency` = n/total)

freq_by_rank %>% 
  ggplot(aes(rank, `term frequency`, color = `Account Name`)) + 
  geom_line(size = 1.1, alpha = 0.8, show.legend = FALSE) + 
  scale_x_log10() +
  scale_y_log10()

# Topic modeling
#TRY TOPIC MODELING 
# clean energy, sustainable buildings, clean transport, 
# waste and circular economy



# Eliminate words appearing less than 2 times or in more than half of the
# documents
vocabulary <- tf$term[ tf$term_freq > 1 & tf$doc_freq < nrow(dtm) / 2 ]

dtm = dtm

# Running LDA -----------------------------------------------------------
k_list <- seq(1, 20, by = 1)
model_dir <- paste0("models_", digest::digest(vocabulary, algo = "sha1"))
if (!dir.exists(model_dir)) dir.create(model_dir)

model_list <- TmParallelApply(X = k_list, FUN = function(k){
  filename = file.path(model_dir, paste0(k, "_topics.rda"))
  
  if (!file.exists(filename)) {
    m <- FitLdaModel(dtm = dtm, k = k, iterations = 500)
    m$k <- k
    m$coherence <- CalcProbCoherence(phi = m$phi, dtm = dtm, M = 5)
    save(m, file = filename)
  } else {
    load(filename)
  }
  
  m
}

# =======================================================
# city text analysis
# =======================================================

# =======================================================
# corproation analysis
# =======================================================


# =======================================================
#shared sentiments between city and corporations
# =======================================================
#match responses between city and corproation
# use external data - sustainiability, adaptation, response

# =======================================================
#KPI models
# =======================================================

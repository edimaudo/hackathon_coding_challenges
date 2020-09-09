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
  # topics (such as clean energy, sustainable buildings, clean transport, waste and circular economy).
# Create a KPI model that measures the propensity of cities to collaborate with companies. 
  # Provide the justification of your weights and indicators.

# =======================================================

rm(list=ls()) #clear environment
# =======================================================
# load packages
# =======================================================
packages <- c('ggplot2', 'corrplot','tidyverse','dplyr','tidyr','tidytext'
              'caret','mlbench','mice','scales','proxy','reshape2',
              'caTools','dummies','scales','catboost', 'Matrix')

for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}

# =======================================================
# load data
# =======================================================
df <- read_csv("1D4.csv")
backup_df <- df
# =======================================================
# data setup
# =======================================================
# check for missing data
missing_data_df <- apply(df, 2, function(x) any(is.na(x))) 
print(missing_data_df)
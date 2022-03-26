#===================
## Load Libraries
#===================
rm(list = ls()) #clear environment
packages <- c('ggplot2', 'corrplot','tidyverse',"caret","dummies","fastDummies"
              ,'FactoMineR','factoextra','scales','dplyr','mlbench','caTools',
              'gridExtra','doParallel','readxl')
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}
################
# Load data
################
df <- read_csv("challenge_1_gut_microbiome_data.csv")

################
# Data Check
################
summary(df)

# Check for missing variables
missing_data <- apply(df, 2, function(x) any(is.na(x)))
print(missing_data)

# Check for for imbalance
table(df$disease)

# drop missing values
df <- na.omit(df)

#=================
# Modeling Approach 1
#=================
# drop sample column
df[1] <- NULL

# Correlation


# Label Encoder
labelEncoder <-function(x){
  as.numeric(factor(x))-1
}
# Normalize data
normalize <- function(x) {
  return ((x - min(x)) / (max(x) - min(x)))
}

disease_df <- df %>%
  select(disease)

disease_cts_df <- df[,c(1:1094)]



#=================
# Modeling Approach 2
#=================
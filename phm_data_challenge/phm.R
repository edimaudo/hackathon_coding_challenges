packages <- c(
  'ggplot2', 'corrplot','tidyverse','DT',
  'mlbench','caTools','gridExtra','doParallel','grid','forecast','reshape2',
  'caret','dummies','tidyr','Matrix','lubridate','plotly','RColorBrewer',
  'data.table','scales','Metrics'
)
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}



################
# Load data
################
train <- read.csv("X_train.csv")
y_train <- read.csv("y_train.csv")
test <- read.csv("X_test.csv")

#===============
# Summary
#===============
summary(train)
summary(test)

#===============
# Data clean up
#===============
train <- na.omit(train)
test <- na.omit(test)

################
# Analysis
################
corrplot(cor(train), method = "num") # no correlation

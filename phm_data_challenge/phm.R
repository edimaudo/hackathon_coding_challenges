#===============
# PHM Data Challenge
#===============

#===============
# Packages
#===============
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

#===============
# Load data
#===============
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
missing_data_train <- apply(train, 2, function(x) any(is.na(x))) 
print(missing_data_train)

missing_data_test <- apply(test, 2, function(x) any(is.na(x))) 
print(missing_data_test)

#===============
# Correlation
#===============
corrplot(cor(train), method = "num") # no correlation

# =======================================================
# Histogram visualization
# =======================================================
# trq_measured
ggplot(train, aes(x=trq_measured))+
  geom_histogram(color="darkblue", fill="lightblue") + theme_classic()
#highest clusters between 30 to 90, centered around 60

# oat
ggplot(train, aes(x=oat))+
  geom_histogram(color="darkblue", fill="lightblue") + theme_classic()
#centered between 10 and 20

# mgt
ggplot(train, aes(x=mgt))+
  geom_histogram(color="darkblue", fill="lightblue") + theme_classic()
#centered around 550 and 650

# pa
ggplot(train, aes(x=pa))+
  geom_histogram(color="darkblue", fill="lightblue") + theme_classic()
#centered around 0 and 500

# ias
ggplot(train, aes(x=ias))+
  geom_histogram(color="darkblue", fill="lightblue") + theme_classic()
#centered after 100 and 150

# np
ggplot(train, aes(x=np))+
  geom_histogram(color="darkblue", fill="lightblue") + theme_classic()
#centered around 100

# ng
ggplot(train, aes(x=ng))+
  geom_histogram(color="darkblue", fill="lightblue") + theme_classic()
#skewed around 90 and 102


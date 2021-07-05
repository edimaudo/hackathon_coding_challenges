rm(list = ls()) #clear environment

#===================
# Packages
#===================
packages <- c('ggplot2', 'corrplot','tidyverse',"caret","dummies",'readxl',
              'scales','dplyr','mlbench','caTools','forecast','TTR','xts',
              'FactoMineR','factoextra',"fastDummies",'scales','dplyr','mlbench',
              'caTools','gridExtra','doParallel','lubridate')
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}

#===================
# Load Data
#===================



#===================
# Check for missing information
#===================


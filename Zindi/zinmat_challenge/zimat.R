#clear environment
rm(list = ls())

#packages 
packages <- c('ggplot2', 'corrplot','tidyverse','ggfortify','readxl','dplyr',
              'caret','mlbench','mice','scales','recommenderlab','proxy','reshape2',
              'caTools','dummies','highcharter',"gridExtra",'scales','catboost', 
              'Matrix')
#load packages
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}

#load data
train <- read.csv("Train.csv")
test <- read.csv("Test.csv")
sample_submission <- read.csv("SampleSubmission.csv")

products <- c('P5DA', 'RIBP', '8NN1',
              '7POT', 'X66FJ', 'GYSR', 'SOP4', 'RVSZ', 'PYUQ', 'LJR9', 'N2MW', 'AHXO',
              'BSTQ', 'FM3X', 'K6QO', 'QBOL', 'JWFN', 'JZ9D', 'J9JW', 'GHYX', 'ECY3')

train <- na.omit(train)
test <- na.omit(test)

#recommendation system
train1 <- train %>%
  select(ID,P5DA, RIBP, X8NN1,X7POT, X66FJ, GYSR, SOP4, RVSZ, PYUQ, LJR9, N2MW, AHXO,
        BSTQ, FM3X, K6QO, QBOL, JWFN, JZ9D, J9JW, GHYX, ECY3)

#initial setup
ratingmat = as.matrix(train1[,-1])
ratingmat = as(ratingmat, "binaryRatingMatrix")

#Create Recommender Model. The parameters are UBCF and Cosine similarity. 
#We take 10 nearest neighbours
rec_mod = Recommender(ratingmat, method = "UBCF", param=list(method="Cosine",nn=10)) 

#Obtain top 5 recommendations for 1st user entry in dataset
Top_5_pred = predict(rec_mod, ratingmat[1], n=5)

Top_5_List = as(Top_5_pred, "list")
Top_5_List


#training 


#test



#prediction

#evaluate model

#combine data into submission 





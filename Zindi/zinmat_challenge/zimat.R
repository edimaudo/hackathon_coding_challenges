# clear environment
rm(list = ls())

# =======================================================
# load packages
# =======================================================
packages <- c('ggplot2', 'corrplot','tidyverse','ggfortify','readxl','dplyr',
              'caret','mlbench','mice','scales','recommenderlab','proxy','reshape2',
              'caTools','dummies','highcharter',"gridExtra",'scales','catboost', 
              'Matrix')

for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package)
    library(package, character.only=T)
  }
}

# =======================================================
# load data
# =======================================================
train <- read.csv("Train.csv")
test <- read.csv("Test.csv")
sample_submission <- read.csv("SampleSubmission.csv")

# =======================================================
# data setup
# =======================================================
# check for missing data
missing_data_train <- apply(train, 2, function(x) any(is.na(x))) 
print(missing_data_train)

missing_data_test <- apply(test, 2, function(x) any(is.na(x))) 
print(missing_data_test)

# remove any nas
train <- na.omit(train)
test <- na.omit(test)

products <- c('P5DA', 'RIBP', '8NN1',
              '7POT', 'X66FJ', 'GYSR', 'SOP4', 'RVSZ', 'PYUQ', 'LJR9', 'N2MW', 'AHXO',
              'BSTQ', 'FM3X', 'K6QO', 'QBOL', 'JWFN', 'JZ9D', 'J9JW', 'GHYX', 'ECY3')

#select id and products for train and test
train_df <- train %>%
  select(ID,P5DA, RIBP, X8NN1,X7POT, X66FJ, GYSR, SOP4, RVSZ, PYUQ, LJR9, N2MW, AHXO,
        BSTQ, FM3X, K6QO, QBOL, JWFN, JZ9D, J9JW, GHYX, ECY3)

test_df <- train %>%
  select(ID,P5DA, RIBP, X8NN1,X7POT, X66FJ, GYSR, SOP4, RVSZ, PYUQ, LJR9, N2MW, AHXO,
         BSTQ, FM3X, K6QO, QBOL, JWFN, JZ9D, J9JW, GHYX, ECY3)

ratingmat_train = as.matrix(train_df[,-1])
ratingmat_train = as(ratingmat_train, "binaryRatingMatrix")

ratingmat_test = as.matrix(test_df[,-1])
ratingmat_test = as(ratingmat_test, "binaryRatingMatrix")


# =======================================================
# build recommendation models
# =======================================================
items_to_recommend <- length(products)
#UBCF
rec_mod_ubcf = Recommender(ratingmat, method = "UBCF")
eval_recommender = Recommender(data = ratingmat,
                               method = "UBCF", parameter = NULL)
eval_prediction = predict(object = eval_recommender,
                          newdata = getData(eval_sets, "known"),
                          n = items_to_recommend,
                          type = "ratings")
eval_accuracy = calcPredictionAccuracy(x = eval_prediction,
                                       data = getData(eval_sets, "unknown"),
                                       byUser = TRUE)
head(eval_accuracy)
#UBCF - cosine
rec_mod_ubcf_cosine = Recommender(ratingmat, method = "UBCF", param=list(method="Cosine",nn=10)) 

# =======================================================
# Select best recommendation model
# =======================================================

# =======================================================
# output
# =======================================================
submission_cols <- c("ID.X.PCODE","Label")


#Create Recommender Model. The parameters are UBCF and Cosine similarity. 
#We take 10 nearest neighbours
#rec_mod = Recommender(ratingmat, method = "UBCF", param=list(method="Cosine",nn=10)) 
# #Obtain top 5 recommendations for 1st user entry in dataset
# Top_5_pred = predict(rec_mod, ratingmat[1], n=5)
# Top_5_List = as(Top_5_pred, "list")
# Top_5_List





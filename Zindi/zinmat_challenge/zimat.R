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
items_to_recommend <- as.integer(length(products))

# UBCF
#rec_mod_ubcf = Recommender(ratingmat, method = "UBCF")
eval_recommender = Recommender(data = ratingmat_train,
                               method = "UBCF", parameter = NULL)
eval_prediction = predict(object = eval_recommender,
                          newdata = ratingmat_test[1:50],
                          n = items_to_recommend)
eval_accuracy = calcPredictionAccuracy(x = eval_prediction,
                                       data = ratingmat_test[1:50], given=items_to_recommend)

head(eval_accuracy)

#IBCF
eval_recommender = Recommender(data = ratingmat_train,
                               method = "IBCF", parameter = NULL)
eval_prediction = predict(object = eval_recommender,
                          newdata = ratingmat_test[1:50],
                          n = items_to_recommend)
eval_accuracy = calcPredictionAccuracy(x = eval_prediction,
                                       data = ratingmat_test[1:50], given=items_to_recommend)

head(eval_accuracy)

#multiple models
models_to_evaluate = list(IBCF_cos = list(name = "IBCF", param = list(method = "cosine")),
                          IBCF_cor = list(name = "IBCF", param = list(method = "pearson")),
                          UBCF_cos = list(name = "UBCF", param = list(method = "cosine")),
                          UBCF_cor = list(name = "UBCF", param = list(method = "pearson")),
                          random = list(name = "RANDOM", param=NULL),
                          popular = list(name = "POPULAR", param=NULL),
                          UBCF = list(name = "UBCF", param=NULL),
                          IBCF = list(name = "IBCF", param=NULL)
                          )

n_recommendations = c(1, 3, 5, 10, 15, 20,21)
scheme <- evaluationScheme(ratingmat_train, method = "cross-validation", k=5,given = -1)
results <- evaluate(scheme,method = models_to_evaluate,n=n_recommendations)

plot(results, y = "ROC", annotate = 1, legend="topright")
title("ROC Curve")
# Draw precision / recall curve
plot(results, y = "prec/rec", annotate=1)
title("Precision-Recall")

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

# ratings <- read.csv('csv/rating_final.csv')
# binaryMatrix <- as(ratings,"binaryRatingMatrix")
# scheme <- evaluationScheme(binaryMatrix, method = "cross-validation", k=5, train = 0.7, given = -1)
# methods <- list(
#   popular = list(name = "POPULAR", param = NULL), 
#   `user-based CF` = list(name = "UBCF", param = list(method = "cosine", nn = 3)),
#   `item-based CF` = list(name = "IBCF", param = list(method = "cosine", k = 3)),
#   AR = list(name="AR", param = list(supp=0.05,conf=0.5))
# )
# results <- evaluate(scheme, methods, type="topNList", n = c(1,2,5), progress = FALSE)





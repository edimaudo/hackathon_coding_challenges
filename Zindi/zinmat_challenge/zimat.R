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

test_df <- test  %>%
  select(ID,P5DA, RIBP, X8NN1,X7POT, X66FJ, GYSR, SOP4, RVSZ, PYUQ, LJR9, N2MW, AHXO,
         BSTQ, FM3X, K6QO, QBOL, JWFN, JZ9D, J9JW, GHYX, ECY3)

ratingmat_train = as.matrix(train_df[,-1])
ratingmat_train = as(ratingmat_train, "binaryRatingMatrix")

ratingmat_test = as.matrix(test_df[,-1])
ratingmat_test = as(ratingmat_test, "binaryRatingMatrix")

# =======================================================
# Modeling
# =======================================================

# IBCF modeling#
# models_to_evaluate = list(IBCF_cos = list(name = "IBCF", param = list(method = "cosine")),
#                           IBCF_pea = list(name = "IBCF", param = list(method = "pearson")))
#IBCF cos better

# UBCF modeling
#models_to_evaluate = list(UBCF_cos = list(name = "UBCF", param = list(method = "cosine")),
#                          UBCF_pea = list(name = "UBCF", param = list(method = "pearson")))
#UBCF pearson better

# Random & popular modeling
#models_to_evaluate = list(RANDOM = list(name = "RANDOM", param = NULL),
#                          POPULAR = list(name = "POPULAR", param = NULL))
#popular was better

#IBCF and UBCF
#models_to_evaluate = list(IBCF = list(name = "IBCF", param = NULL),
#                          UBCF = list(name = "UBCF", param = NULL))
#IBCF better

#IBCF cos and UBCF pearson
#models_to_evaluate = list(IBCF_cos = list(name = "IBCF", param = list(method = "cosine")),
#                          UBCF_pea = list(name = "UBCF", param = list(method = "pearson")))

#UBCF pearson was better

# models_to_evaluate = list(IBCF = list(name = "IBCF", param = NULL),
#                           POPULAR = list(name = "POPULAR", param = NULL))
#IBCF better

#IBCF and UBCF pearson
models_to_evaluate = list(IBCF_cos = list(name = "IBCF", param = NULL),
                          UBCF_pea = list(name = "UBCF", param = list(method = "pearson")))
#ibcf cos better

#recommender type outputs
n_recommendations = c(1,2,3,4,5)
scheme <- evaluationScheme(ratingmat_train, method = "cross-validation", k=5,given = -1)
results <- evaluate(scheme,method = models_to_evaluate,n=n_recommendations)

#Draw ROC curve
plot(results, y = "ROC", annotate = c(1,2), legend="topleft")
title("ROC Curve")

# Draw precision / recall curve
plot(results, y = "prec/rec", annotate=c(1,2) )
title("Precision-Recall")
 

# =======================================================
# IBCF cos recommendation model 
# =======================================================
items_to_recommend <- 1
eval_recommender = Recommender(data = ratingmat_train,
                               method = "IBCF", 
                               param=list(method="Cosine",k=10000, alpha = 1)) 
eval_prediction = predict(object = eval_recommender,
                          newdata = ratingmat_test,
                          n = items_to_recommend)

rec <-  as(eval_prediction, "list")

# =======================================================
# Hybrid recommendation model
# =======================================================
items_to_recommend <- 1
eval_hybrid_recommender <- HybridRecommender(
  Recommender(ratingmat_train, method = "POPULAR"),
  Recommender(ratingmat_train, method = "IBCF",param=list(method="Cosine",k=10000, alpha = 1)),
  Recommender(ratingmat_train, method = "IBCF"),
  weights = c(.1, .8, .1)
)
# eval_hybrid_prediction = predict(object = eval_hybrid_recommender,
#                           newdata = ratingmat_test,
#                           n = items_to_recommend)

#)
getModel(eval_hybrid_recommender)

rec <- as(predict(eval_hybrid_recommender, ratingmat_test, type = "topNList", n = 1), "list")
rec <- getList(predict(eval_hybrid_recommender, 1:1, data = ratingmat_test, type = "topNList", n = 1))
# =======================================================
# output
# =======================================================


submission_info1 <- sample_submission
submission_info1$ID <- substr(submission_info1$ID.X.PCODE,1,7)
submission_info1$Product <- substr(submission_info1$ID.X.PCODE,11,14)

submission_info2 <- data.frame(matrix(ncol = 4, nrow = 0))
colnames(submission_info2) <- c("ID.X.PCODE","Label","ID","Product")

for (i in 1:length(rec)){
  temp <- submission_info1 %>%
    filter(ID == test_df$ID[i]) %>%
    filter(Product %in% c(rec[i][[1]])) %>%
    mutate (Label = 1)
  temp <- data.frame(temp)
  submission_info2 <- rbind(submission_info2, temp)
}



submission_info3 <- submission_info1 %>%
  left_join(submission_info2, by="ID.X.PCODE")

submission_info3[is.na(submission_info3)] <- 0
submission_info3$Label <- ifelse(submission_info3$Label.y==1, 1, 0)
submission_info3$Label <- as.integer(submission_info3$Label)

final_submission <- submission_info3 %>%
  select(ID.X.PCODE,Label)
write.csv(final_submission,"output_HYBRID.csv",row.names = F)










 
 
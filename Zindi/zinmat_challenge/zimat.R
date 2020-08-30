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
# model experimentation
# =======================================================
# items_to_recommend <- as.integer(length(products))
# 
# # UBCF
# #rec_mod_ubcf = Recommender(ratingmat, method = "UBCF")
# eval_recommender = Recommender(data = ratingmat_train,
#                                method = "UBCF", parameter = NULL)
# eval_prediction = predict(object = eval_recommender,
#                           newdata = ratingmat_test[1:50],
#                           n = items_to_recommend)
# eval_accuracy = calcPredictionAccuracy(x = eval_prediction,
#                                        data = ratingmat_test[1:50], given=items_to_recommend)
# 
# head(eval_accuracy)
# 
# #IBCF
# eval_recommender = Recommender(data = ratingmat_train,
#                                method = "IBCF", parameter = NULL)
# eval_prediction = predict(object = eval_recommender,
#                           newdata = ratingmat_test[1:50],
#                           n = items_to_recommend)
# eval_accuracy = calcPredictionAccuracy(x = eval_prediction,
#                                        data = ratingmat_test[1:50], given=items_to_recommend)
# 
# head(eval_accuracy)
# 
# #multiple models
# models_to_evaluate = list(#random = list(name = "RANDOM", param=NULL),
#                           #popular = list(name = "POPULAR", param=NULL),
#                           UBCF = list(name = "UBCF", param=NULL),
#                           IBCF = list(name = "IBCF", param=NULL)
#                           )
# 
# n_recommendations = c(5,10,15,20)
# scheme <- evaluationScheme(ratingmat_train, method = "cross-validation", k=5,given = -1)
# results <- evaluate(scheme,method = models_to_evaluate,n=n_recommendations)
# 
# #Draw ROC curve
# plot(results, y = "ROC", annotate = c(1,2), legend="topleft")
# title("ROC Curve")
# 
# # Draw precision / recall curve
# plot(results, y = "prec/rec", annotate=1)
# title("Precision-Recall")
# 
# 
# models_to_evaluate = list(IBCF_cos = list(name = "IBCF", param = list(method = "cosine")),
#                           #IBCF_cor = list(name = "IBCF", param = list(method = "pearson")),
#                           UBCF_cos = list(name = "UBCF", param = list(method = "cosine"))#,
#                           #UBCF_cor = list(name = "UBCF", param = list(method = "pearson")
#                           )
# n_recommendations = c(5,10,15,20)
# scheme <- evaluationScheme(ratingmat_train, method = "cross-validation", k=5,given = -1)
# results <- evaluate(scheme,method = models_to_evaluate,n=n_recommendations)
# 
# #Draw ROC curve
# plot(results, y = "ROC", annotate = c(1,2), legend="topleft")
# title("ROC Curve")
# 
# # Draw precision / recall curve
# plot(results, y = "prec/rec", annotate=c(1,2) )
# title("Precision-Recall")
# 
# ##
# models_to_evaluate = list(IBCF_cos = list(name = "IBCF", param = list(method = "cosine")),
#                           IBCF_cor = list(name = "IBCF", param = list(method = "pearson"))
#                           #UBCF_cos = list(name = "UBCF", param = list(method = "cosine"))#,
#                           #UBCF_cor = list(name = "UBCF", param = list(method = "pearson")
# )
# n_recommendations = c(5,10,15,20)
# scheme <- evaluationScheme(ratingmat_train, method = "cross-validation", k=5,given = -1)
# results <- evaluate(scheme,method = models_to_evaluate,n=n_recommendations)
# 
# #Draw ROC curve
# plot(results, y = "ROC", annotate = c(1,2), legend="topleft")
# title("ROC Curve")
# 
# # Draw precision / recall curve
# plot(results, y = "prec/rec", annotate=c(1,2) )
# title("Precision-Recall")
# 
# 
# models_to_evaluate = list(IBCF_cos = list(name = "IBCF", param = list(method = "cosine")),
#                           IBCF = list(name = "IBCF", param = NULL)
#                           #UBCF_cos = list(name = "UBCF", param = list(method = "cosine"))#,
#                           #UBCF_cor = list(name = "UBCF", param = list(method = "pearson")
# )
# n_recommendations = c(5,10,15,20)
# scheme <- evaluationScheme(ratingmat_train, method = "cross-validation", k=5,given = -1)
# results <- evaluate(scheme,method = models_to_evaluate,n=n_recommendations)
# 
# #Draw ROC curve
# plot(results, y = "ROC", annotate = c(1,2), legend="topleft")
# title("ROC Curve")
# 
# # Draw precision / recall curve
# plot(results, y = "prec/rec", annotate=c(1,2) )
# title("Precision-Recall")
# 
# 
# models_to_evaluate = list(IBCF = list(name = "IBCF", param = NULL),
#                           IBCF_cor = list(name = "IBCF", param = list(method = "pearson"))
#                           #UBCF_cos = list(name = "UBCF", param = list(method = "cosine"))#,
#                           #UBCF_cor = list(name = "UBCF", param = list(method = "pearson")
# )
# n_recommendations = c(5,10,15,20)
# scheme <- evaluationScheme(ratingmat_train, method = "cross-validation", k=5,given = -1)
# results <- evaluate(scheme,method = models_to_evaluate,n=n_recommendations)
# 
# #Draw ROC curve
# plot(results, y = "ROC", annotate = c(1,2), legend="topleft")
# title("ROC Curve")
# 
# # Draw precision / recall curve
# plot(results, y = "prec/rec", annotate=c(1,2) )
# title("Precision-Recall")





# =======================================================
# Select best recommendation model
# =======================================================
#IBCF cosine
#IBCF_cos = list(name = "IBCF", param = list(method = "cosine"))

#used ibcf pearson - not good 16.2 rating need to get it lower for 21 rec
# ibcf cosine - not good 25 rating need to get it lower for 21 rec

#- parameter = list(method = "cosine")
# ibcf
# ubcf pearson
# ubcf cosine
# ubcf


#ibcf pearson - 
#ibcf cosine - 

#- parameter = list(method = "cosine")
# ibcf
# ubcf pearson
# ubcf cosine
# ubcf

items_to_recommend <- 1#as.integer(length(products))
eval_recommender = Recommender(data = ratingmat_train,
                               method = "IBCF", parameter = list(method = "cosine"))
eval_prediction = predict(object = eval_recommender,
                          newdata = ratingmat_test,
                          n = items_to_recommend)
eval_accuracy = calcPredictionAccuracy(x = eval_prediction,
                                       data = ratingmat_test, given=items_to_recommend)
eval_accuracy

# =======================================================
# output
# =======================================================

submission_info1 <- sample_submission
submission_info1$ID <- substr(submission_info1$ID.X.PCODE,1,7)
submission_info1$Product <- substr(submission_info1$ID.X.PCODE,11,14)

rec <-  as(eval_prediction, "list")

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
write.csv(final_submission,"output_ibcf_cos2.csv",row.names = F)

#=============================
eval_recommender = Recommender(data = ratingmat_train,
                               method = "IBCF", parameter = list(method = "pearson"))
eval_prediction = predict(object = eval_recommender,
                          newdata = ratingmat_test,
                          n = items_to_recommend)
eval_accuracy = calcPredictionAccuracy(x = eval_prediction,
                                       data = ratingmat_test, given=items_to_recommend)
eval_accuracy



submission_info1 <- sample_submission
submission_info1$ID <- substr(submission_info1$ID.X.PCODE,1,7)
submission_info1$Product <- substr(submission_info1$ID.X.PCODE,11,14)

rec <-  as(eval_prediction, "list")

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
write.csv(final_submission,"output_ibcf_pearson2.csv",row.names = F)




# t2 <- submissions_temp %>%
#   filter(ID == test_df$ID[1]) %>%
#   filter(Products %in% c(recommendations[1][[1]])) %>%
#   mutate(label = 1)
# final_output <- data.frame(matrix(ncol = 2, nrow = 0))
# submission_cols <- c("ID.X.PCODE","Label")
# colnames(final_output) <- submission_cols
# 
#  for (i in 1:length(output)){
# #   recommendations <- c(output[i][1])
# #   for (k in 1:length(recommendations)){
#      for (j in 1:length(products)){
#        id <- paste(test_df$ID[i]," X ", products[j])
#        label <- 0
# #       if (products[j] == recommendations[k]){
# #         label <- 1
# #       } else {
# #         label <- 0
# #       }
#        temp_output <- data.frame(id,label)
#        final_output <- rbind(final_output, temp_output)
#        final_output <- final_output %>%
#          unique()
#      }
#    }
# # }


#Create Recommender Model. The parameters are UBCF and Cosine similarity. 
#We take 10 nearest neighbours
#rec_mod = Recommender(ratingmat, method = "UBCF", param=list(method="Cosine",nn=10)) 
# #Obtain top 5 recommendations for 1st user entry in dataset
# Top_5_pred = predict(rec_mod, ratingmat[1], n=5)
# Top_5_List = as(Top_5_pred, "list")
# Top_5_List

# ratings <- read.csv('csv/rating_final.csv')
# binaryMatrix <- as(ratings,"binaryRatingMatrix")
# scheme <- evaluationScheme(binaryMatrix, method = "cross-validation", 
#k=5, train = 0.7, given = -1)
# methods <- list(
#   popular = list(name = "POPULAR", param = NULL), 
#   `user-based CF` = list(name = "UBCF", param = list(method = "cosine", nn = 3)),
#   `item-based CF` = list(name = "IBCF", param = list(method = "cosine", k = 3)),
#   AR = list(name="AR", param = list(supp=0.05,conf=0.5))
# )
# results <- evaluate(scheme, methods, type="topNList", n = c(1,2,5), progress = FALSE)

# 
# for (j in 1:length(c(output[1]$`1`)))  {
#   for (i in 1:length(products)){
#     id <- paste(test_df$ID[1]," X ", products[i])
#     recommendations <- c(output[1]$`1`)
#     if (products[i]==recommendations[j]){
#       label <- 1
#     } else {
#       label <- 0
#     }
#       temp_output <- data.frame(id,label)
#       final_output <- rbind(final_output, temp_output)
#   }
# }



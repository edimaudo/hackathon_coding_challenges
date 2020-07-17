### Akeed Restaurant Recommendation Challenge
***

## Overview
There are ~10,000 customers in the test set. These are the customers you will need to recommend a vendor to. Each customer can order from multiple locations (LOC_NUM).
There are ~35,000 customers in the train set. Some of these customers have made orders at at least one of 100 vendors.

## Objective
The objective of this competition is to build a recommendation engine to predict what restaurants customers are most likely to order from, given the customer location, the restaurant, and the customer order history.

## File information
test_customers.csv - customer id’s in the test set.
test_locations.csv - latitude and longitude for the different locations of each customer.
train_locations.csv - customer id’s in the test set.
train_customers.csv - latitude and longitude for the different locations of each customer.
orders.csv - orders that the customers train_customers.csv from made.
vendors.csv - vendors that customers can order from.
VariableDefinitions.txt - Variable definitions for the datasets
SampleSubmission.csv - is an example of what your submission file should look like. The order of the rows does not matter, but the names of CID X LOC_NUM X VENDOR must be correct. The column "target" is your prediction. The submission file is large so please allow up to 30 minutes for your score to reflect

## Metrics

The error metric for this competition is the F1 score, which ranges from 0 (total failure) to 1 (perfect score). Hence, the closer your score is to 1, the better your model.

F1 Score: A performance score that combines both precision and recall. It is a harmonic mean of these two variables. The formula is given as: 2*Precision*Recall/(Precision + Recall)

Precision: This is an indicator of the number of items correctly identified as positive out of total items identified as positive. The formula is given as: TP/(TP+FP)

Recall / Sensitivity / True Positive Rate (TPR): This is an indicator of the number of items correctly identified as positive out of total actual positives. The formula is given as: TP/(TP+FN
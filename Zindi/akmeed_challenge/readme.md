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
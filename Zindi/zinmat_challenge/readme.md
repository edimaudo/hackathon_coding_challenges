### Zinmat Challenge
***

## Overview
***

For insurance markets to work well, insurance companies need to be able to pool and spread risk across a broad customer base. This works best where the population to be insured is diverse and large. In Africa, formal insurance against risk has been hampered by lack of private sector companies offering insurance, with no way to diversify and pool risk across populations.

Understanding the varied insurance needs of a population, and matching them to appropriate products offered by insurance companies, makes insurance more effective and makes insurance companies more successful.

At the heart of this, understanding the consumer of insurance products helps insurance companies refine, diversify, and market their product offerings. Increased data collection and improved data science tools offer the chance to greatly improve this understanding.

In this competition, you will leverage data and ML methods to improve market outcomes for insurance provider Zimnat, by matching consumer needs with product offerings in the Zimbabwean insurance market. Zimnat wants an ML model to use customer data to predict which kinds of insurance products to recommend to customers. The company has provided data on nearly 40,000 customers who have purchased two or more insurance products from Zimnat.

## Challenge

For around 10,000 customers in the test set, you are given all but one of the products they own, and are asked to make predictions around which products are most likely to be the missing product. This same model can then be applied to any customer to identify insurance products that might be useful to them given their current profile.


## Evaluation

The error metric for this competition is the log loss.
For every customer ID in the test set, for each product code, you must submit a prediction between 0 and 1 for likelihood that that customer has that product. You may NOT round your predictions to 0s and 1s.
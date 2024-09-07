## PHM North America 2024 Conference Data Challenge

### Objective

This year’s data challenge is on estimating the health of helicopter turbine engines. It is both a regression and classification problem. We also want to know how trustworthy the algorithm(s) are, so a measure of confidence will be reported for each of your predictions. Our intent is that the design of this confidence metric is as important as the prediction itself.

### Problem

This year’s problem is to assess the health of helicopter turbine engines. The combined datasets has seven engines (assets) all of the same make and model. You will be given all of the measured data for four of the assets in the training dataset, but the observations have been shuffled and asset ids have been removed. The remaining three assets are used to form the test and validation datasets.
Note that your algorithms will have to generalize on assets on which they were not trained.

Each engine is instrumented to capture the outside air temperature, mean gas temperature, power available, indicated airspeed, net power, and compressor speed. For these operational conditions, there is a design (target) torque. The real output torque is also measured. Engine health is assessed by comparing the output torque to the design torque. More specifically, we look at the torque margin as an indicator of engine health:

torque margin (%) = 100 * (torque measured – torque target) / torque target

Thus it can be observed if an engine underperforming.

For each observation in the test and validation datasets, competing teams will predict the asset’s health by

Estimating the binary classification of the health state (0 = nominal, 1 = faulty), and confidence metric (continuous variable 0 to 1).
Estimating the torque margin expressed at a probability distribution function (PDF).  
Select from a list of PDFs. This is probabilistic regression.


### Output

Please ensure the submission file uses the JSON format


For each prediction, you will submit the following;
– sample_id
– This is the key for each json entry
– classification
– key: “class”
– binary entry
– 0 = nominal, 1 = faulty
– classification confidence
– key: “class_conf”
– continuous variable ranging from 0 to 1
– 0 = no confidence, 1 = high confidence
– PDF type
– key: “pdf_type”
– string
– PDF variables
– key: “pdf_args”
– floats

An example submission is as follows:

{
"0": {
"class": 1,
"class_conf": 0.5,
"pdf_type": "norm",
"pdf_args": {
"loc": -1,
"scale": 0.1
}
},
"1": {
"class": 0,
"class_conf": 0.4,
"pdf_type": "cauchy",
"pdf_args": {
"loc": -0.1,
"scale": 1
}
},
"2": {
"class": 0,
"class_conf": 0.4,
"pdf_type": "gamma",
"pdf_args": {
"loc": -0.1,
"scale": 1,
"a": 0.5
}
}
}


The Python Scipy package is being used to evaluate the pdf. Specifically, we’re using the stats, continuous distribution functions. Each of these distributions has a pdf method that creates a pdf that can be used to score your answer (more on that below). You can select any PDF listed below. When submitting the pdf, use the notation and include the positional arguments as a list.

Stats model	Nomenclature
Normal	norm
Exponential	expon
Uniform	uniform
Gamma	gamma
Beta	beta
Log-Normal	lognorm
Chi-Squared	chi2
Weibull	weibull_min
Student’s t	t
F	f
Cauchy	cauchy
Laplace	laplace
Rayleigh	rayleigh
Pareto	pareto
Gumbel	gumbel_r
Logistic	logistic
Erlang	erlang
Power Law	powerlaw
Nakagami	nakagami
Beta Prime	betaprime
All distributions will be normalized to ensure that the area under the curve is 1 and that the probability of any given value is less than or equal to 1. Other distributions found in Scipy can be used upon request.

Scoring

One aim of this competition is to measure confidence about the submitted classification and regression. As such, the confidence level is a factor in the scoring system. Classification and regression predictions will be scored separately, and the final score is the mean score of all predictions.

### Classifiation score

Classification scores will be linearly weighted for correct answers and false positives but strongly penalized for highly confident false negatives. As a reminder, a false negative is predicting that the engine is healthy when, in fact, it’s faulty. A false negative prediction can lead to expensive repairs and, in the worst case, be deadly.

#### Scoring function

- check confidence to make sure it's between 0 and 1
if (confidence < 0) or (confidence > 1):
score = -100
return score

- make sure that the pred_label is 1 or 0
if pred_label != 0:
if pred_label != 1:
score = -100
return score

- invert confidence is pred_label is incorrect
if pred_label != true_label:
confidence = - confidence

- true state is healthy
if true_label == 0:
score = confidence

- true state is faulty
else:
if confidence >= 0:
score = confidence
else:
score = 4 * confidence **11 + 1.0 * confidence

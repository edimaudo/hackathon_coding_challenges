# ABOUT THE CHALLENGE

In this hackathon, participants will focus on building a heart-toxicity predictive model, a crucial challenge in drug discovery and chemical safety assessment.
 
By leveraging machine learning techniques, you'll work with real-world datasets to create models that can predict how chemical compounds might interact with biological systems, potentially identifying toxic compounds before they reach clinical trials or industrial applications.
 
This hackathon provides a unique opportunity to apply your data science and machine learning skills to solve complex biological problems and contribute to public health and safety. We are calling on bioinformaticians, data scientists, and ML experts to collaborate, innovate, and push the boundaries of predictive modeling.

The goal is simple: given a set of molecules labeled as toxic (1) or non-toxic (0), participants are expected to tackle the 3 following tasks:

(Task 1) - Predict the toxicity of a uniformly sampled set of molecules, denoted as test set 1.

(Task 2) - Predict the toxicity of 6 series of molecules. In the drug discovery universe, a molecular series is a family of molecules that share a common global structure, only differing in fragments. These molecular series make up the test set 2.

(Task 3) - Among the predictions of test set 1, select the 200 molecules for which predictions are the most reliable.

These tasks are far from trivial, and there are many skills that can help you in your quest towards molecular toxicity estimation:


# EVALUATION METRICS

The following metrics will be used to assess the quality of the predictions:

(Task 1) - Cohen kappa score on test set 1.
(Task 2) - Accuracy on each series of test set 2 (total of 6 accuracy metrics). These 6 scores wil be averaged to a single evaluation metric.
(Task 3) - Accuracy on the first 200 rows of submission file for test set 1.

# DATASET DESCRIPTION

3 datasets are provided in the csv (comma-separated) format
- train.csv   (9415 rows)
- test_1.csv  (750 rows)
- test_2.csv  (478 rows)

Each row of a dataset corresponds to a molecule

Each csv file comports the following columns
- smiles : Chemical formula of the molecule in the SMILES format.
- 199 molecular features computed with the rdkit package (from column BalabanJ to qed). These features were computed with the rdkit package.
- ecfc_0000 to ecfc_2047 (2048 features) : bit vector representation of Morgan fingerprints
- fcfc_0000 to fcfc_2047 (2048 features) : bit vector representation of pharmacophore feature-based Morgan fingerprints
- class (train.csv only) :  The label to predict (1 for hERG inhibitor, 0 otherwise)
Likely, optimal predictors will not use the complete set of 4295 features provided in the datasets.

3 datasets are provided in the csv (comma-separated) format:

- The training set: 'train.csv'
    - 9415 rows, each corresponding to a molecule
    - 1 'smiles' column, containing the chemical formula of the molecule represented by the row (in canonical SMILES format)
    - 199 molecular features computed with the rdkit package
    - 2048 columns (named 'ecfc_XXXX') containing the bit vector representation of Morgan fingerprints
    - 2048 columns (named 'fcfc_XXXX') containing the bit vector representation of pharmacophore feature-based Morgan fingerprints
    - 1 'class' column containing the label to predict (1 for hERG inhibitor, 0 otherwise)

- Test set 1: 'test_1.csv'
    - 750 rows, each corresponding to a molecule
    - 1 'smiles' column, containing the chemical formula of the molecule represented by the row (in canonical SMILES format)
    - 199 molecular features computed with the rdkit package
    - 2048 columns (named 'ecfc_XXXX') containing the bit vector representation of Morgan fingerprints
    - 2048 columns (named 'fcfc_XXXX') containing the bit vector representation of pharmacophore feature-based Morgan fingerprints

- Test set 2: 'test_2.csv'
    - 478 rows, each corresponding to a molecule
    - 1 'smiles' column, containing the chemical formula of the molecule represented by the row (in canonical SMILES format)
    - 1 'series' columns, containing the identifier of the molecular series to which the molecule belongs
    - 199 molecular features computed with the rdkit package
    - 2048 columns (named 'ecfc_XXXX') containing the bit vector representation of Morgan fingerprints
    - 2048 columns (named 'fcfc_XXXX') containing the bit vector representation of pharmacophore feature-based Morgan fingerprints


All molecular features & fingerprints were generated using the rdkt (https://www.rdkit.org/) python package version 2023.03.1.


# COPYRIGHT NOTICE


Datasets used during the event were made available in the following Article.
Karim, A., Lee, M., Balle, T. et al. CardioTox net: a robust predictor for hERG channel blockade based on
deep learning meta-feature ensembles. J Cheminform 13, 60 (2021). https://doi.org/10.1186/s13321-021-00541-z

Molecules in the datasets were sanitized using Qubit-pharmaceuticals preprocessing procedures.
All molecular features were generated using the rdkit package (https://www.rdkit.org/).


# LICENSE


Open Access - This article is licensed under a Creative Commons Attribution 4.0 International License, which 
permits use, sharing, adaptation, distribution and reproduction in any medium or format, as long as you give appropriate credit to the
original author(s) and the source, provide a link to the Creative Commons licence, and indicate if changes were made. To view a copy
of this licence, visit http://creativecommons.org/licenses/by/4.0/

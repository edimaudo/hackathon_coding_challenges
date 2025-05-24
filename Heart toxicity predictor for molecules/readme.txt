The following datasets are provided for the hackathon at Ecole Telecom Paris with the student association,
taking place from 05/23/2025 to 05/25/2025.
This event is organized by MARGO, Qubit-pharmaceuticals and IBM.

The aim of this event is to build a binary classifier capable of predicting whether a molecule is toxic or not.
The toxicity studied here is that associated with hERG inhibition, cause of heart problems for certain drugs.

====================
DATASETS DESCRIPTION
====================

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

================
COPYRIGHT NOTICE
================

Datasets used during the event were made available in the following Article.
Karim, A., Lee, M., Balle, T. et al. CardioTox net: a robust predictor for hERG channel blockade based on
deep learning meta-feature ensembles. J Cheminform 13, 60 (2021). https://doi.org/10.1186/s13321-021-00541-z

Molecules in the datasets were sanitized using Qubit-pharmaceuticals preprocessing procedures.
All molecular features were generated using the rdkit package (https://www.rdkit.org/).

=======
LICENSE
=======

Open Access - This article is licensed under a Creative Commons Attribution 4.0 International License, which 
permits use, sharing, adaptation, distribution and reproduction in any medium or format, as long as you give appropriate credit to the
original author(s) and the source, provide a link to the Creative Commons licence, and indicate if changes were made. To view a copy
of this licence, visit http://creativecommons.org/licenses/by/4.0/

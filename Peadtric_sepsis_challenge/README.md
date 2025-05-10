# Pediatric Sepsis Data Challenge: In-Hospital Mortality Prediction Task

<!-- Brief introduction to the challenge and its objectives -->
Welcome to the Pediatric Sepsis Data Challenge! This challenge focuses on predicting in-hospital mortality for pediatric sepsis cases using a synthetic dataset derived from real-world data. The ultimate goal is to improve early detection models for better resource allocation and clinical outcomes in low-resource healthcare settings.

## Objective

<!-- State the primary task for participants -->
Develop an open-source algorithm to predict in-hospital mortality among children with sepsis. This algorithm should be trained solely on the provided dataset, using any or all variables available within.

## Contents

<!-- Table of contents for easy navigation in a Markdown file -->
1. [Data and Code Requirements](#1-data-and-code-requirements)
2. [Submission Guidelines and Limits](#2-submission-guidelines-and-limits)
3. [Submission Instructions for Your Code](#3-Submission-Instructions-for-Your-Code)
4. [Testing and Evaluation Criteria](#4-testing-and-evaluation-criteria)
5. [Final Instructions](#5-final-instructions)

---

## 1. Data and Code Requirements

#### Dataset

- **Provided Dataset**: Synthetic data derived from real hospital data from Uganda, use file SyntheticData_Training.csv as training data, and SyntheticData_DataDictionary_V1.docx as data dictionary.
- **Feature Constraints**: Your algorithm should exclusively use the provided dataset variables for predictions.

#### Submission Requirements

- **Code and Model**: Submit both:
  - **Training Code**: All scripts and code required for training the model.
  - **Trained Model**: The model file generated from your code.
  - **Language**: Submissions must be in Python; however, R, and MATLAB submissions are no longer acceptable. Python is recommended to facilitate baseline comparisons.



#### Code Validity

- **Environment**: Code will run in a containerized setup.
- **Execution Time**: Maximum 24 hours for training, with 8 hours allocated for validation and testing.
- **Autonomous Execution**: Ensure your code can execute end-to-end without manual intervention.
  - **Dependencies**: List all dependencies in `requirements.txt` or a compatible environment configuration file.

---

## 2. Submission Guidelines and Limits

#### Submission Limit

- Each team may submit code up to **3 times** throughout the challenge.

#### Evaluation

- Each submission will be assessed on a hidden evaluation set to ensure unbiased scoring.
- Only the **final model from each training phase** will be evaluated for the official score.

#### Repository Security

- Teams are expected to maintain their code in **private repositories** during the challenge to ensure fairness.

#### Post-Challenge Public Release

<!-- Explain the requirements for the public release of solutions after the challenge concludes -->
Upon completion, all final solutions must be shared publicly (e.g., GitHub) to promote reproducibility and transparency.

**Public Release Requirements**:
- Complete source code and trained models.
- Detailed README file with instructions for replication.
- An open-source license (e.g., MIT, BSD) specifying usage and redistribution rights.

---

## 3. Submission Instructions for Your Code

### Overview
Use the provided [Python example code](python-example-2023) as a starting point. Clone or download this repository, replace the example code with your implementation, and push or upload the updated files to your repository. Share your repository with the aditya1000 & PediatricSepsisDataChallenge2024 user. Submit your entry using this [submission form](https://docs.google.com/forms/d/e/1FAIpQLSdLvCU4BG4ttA8Gkek8XK0QhsQpbiTUnBZ7__fVCCQcvIEnIQ/viewform?pli=1). 

### File Descriptions and Guidelines

#### 1. **Dockerfile**
- Update the `Dockerfile` to specify the version of Python you are using locally.
- Add any additional packages required for your code.
- **Important**: Do not rename or relocate the `Dockerfile`. Its structure must remain intact, especially the three lines marked as "DO NOT EDIT." These lines are critical for our submission system.

#### 2. **requirements.txt**
- Add all Python packages required by your code.
- Specify the exact versions of these packages to match your local environment.
- Remove any unnecessary packages that your code does not depend on.

#### 3. **Documentation Files**
- Update the following files as needed:
  - `AUTHORS.txt`: Include the names of all contributors.
  - `LICENSE.txt`: Specify your license terms.
  - `README.md`: Provide relevant information about your code.  
- **Note**: Our submission system does not use the README file to determine how to execute your code.

#### 4. **Code Scripts**
- **`team_code.py`**: Modify this script to load and run your trained model(s).
- **`train_model.py`**: Do not modify this script. It calls functions in `team_code.py` to train your model using the training data.
- **`helper_code.py`**: Do not modify this script. It provides helper functions for your code. Feel free to use these functions, but note that any changes made to this file will not be included when we run your code.
- **`run_model.py`**: Do not modify this script. It calls functions in `team_code.py` to load and run your trained models on the test data. Any changes to this file will not be reflected in our execution environment.

#### 5. **Docker Development**
- You can develop and test your code without using Docker. However, before submission, ensure that you can:
  - Build a Docker image from your `Dockerfile`.
  - Successfully run your code within a Docker container.

### Submission Instructions
1. Push or upload your updated code to the root directory of the `master` branch in your repository.
2. Ensure the repository contains all necessary files and updates as described above.

### Execution on Our System
Once submitted, we will:
1. Download your repository.
2. Build a Docker image using your `Dockerfile`.
3. Execute your code in our local or cloud environment.

---

### 4. Testing and Evaluation Criteria (Tentative)

<!-- Details on how submissions will be evaluated based on several key metrics -->
Your model will be evaluated on the following metrics:

1. **Area Under the ROC Curve (AUC-ROC)**: A secondary metric to measure general performance across thresholds.
2. **AUPRC:** Focuses on precision and recall, especially useful for imbalanced datasets.
3. **Net Benefit:** 
Balances true positives and false positives to measure decision-making utility.
4. **Estimated Calibration Error (ECE):** 
Assesses how well predicted probabilities align with actual outcomes.

To get your leaderboard score on test data use [evaluate_2024.py](evaluation-2024) file after reading the respective [README.md](evaluation-2024) from evaluation-2024 folder of this repository. 

---



---

### 5. Final Instructions

#### Autonomous Execution
- Ensure all components of your submission run autonomously from start to finish in a **cloud-based container**.

#### Leaderboard
- Scores will be updated on the leaderboard based on the **best score achieved**.

#### Open-Source Compliance
- Ensure that your final submission is properly documented and made available publicly after the completion of the competition.

---

We are excited to see your innovative solutions aimed at improving pediatric sepsis outcomes in resource-constrained settings!


# Overview
Machinery such as turbines and bearings undergo subtle changes in their vibration signals and signatures, long before catastrophic failure occurs. Being able to track this degradation process accurately is crucial for predictive maintenance and avoiding downtime.

In this Coding Challenge, TII is providing high-frequency vibration recordings and tachometer signals from a controlled degradation test. However, the file names have been randomly permuted: scrambled up, to hide the true order of the recordings. Your task is to reconstruct the true chronological order of the data files. By developing methods to extract the features that evolve consistently over time, Solvers are asked to reassemble the degradation timeline of the test setup.

# About Company
Technology Innovation Institute (TII) is a global scientific research center attracting the world’s foremost scientists and researchers. TII leads worldwide advances in artificial intelligence, autonomous robotics, quantum computing, cryptography and quantum communications, directed energy, secure communication, smart devices, advanced materials, and propulsion and space technologies, and biotechnology fields.

TII belongs to the Abu Dhabi Government’s Advanced Technology Research Council (ATRC), which oversees the technology research.

# Challenge Background

## Background

Bearings are among the most critical components in rotating machinery, enabling smooth motion and distributing loads. Over time, bearings degrade, and this gradual process is reflected in the vibration signals of the machine. The ability to detect, track, and interpret these evolving vibration patterns is essential for predictive maintenance, improving safety, and avoiding costly downtime.

Traditionally, condition monitoring systems provide sequential, labelled, and timestamped datasets. This allows engineers to observe the degradation process in order. However, in this Challenge, participants are given a scrambled dataset – the file names have been randomly permuted, hiding the true chronological order of the recordings.

The task is to reconstruct the true timeline of bearing degradation by analyzing high-frequency vibration and tachometer signals from a helicopter’s turboshaft engine. In real-world conditions, changing loads and operational variability make vibration data stochastic. Despite this, degradation is unidirectional – bearings do not ‘heal themselves’. Thus, participants must identify consistent features that evolve over time and use them to reassemble the correct order of events.

## Why It Matters

In aviation and other industries, failures in rotating machinery (such as turbines and bearings) can have catastrophic consequences. Subtle changes in vibration signals often occur long before visible failure. Had the monitoring system not raised an alert in this real-world dataset, continued operation could have resulted in a mishap. Developing methods to detect, track, and predict degradation enables safer operations and better scheduling of maintenance, while reducing downtime and cost.

## The Setup

Your Challenge is to develop a method to reorder the provided dataset files, estimating the true chronological sequence of the bearing degradation run.

You are provided with a set of vibration and tachometer recordings from a helicopter turboshaft engine.
The file order has been randomized to obscure the true chronological progression.
Your task is to reconstruct the original sequence of recordings, for files {1, …, N}, estimating the true degradation timeline.
Specifically, in this Coding Challenge, Solvers must submit a predicted permutation vector – mapping each input file (from the dataset provided) to its estimated position in the reconstructed timeline.

# Dataset and Scoring
This dataset also includes example submissions for you to see the desired format.

Solvers should note that this file, even zipped, is approximately 55mb, and when unzipped is much larger.

The dataset includes N time-history files of vibration data, each containing:

- Acceleration time series sampled at 93,750 Hz (single channel)
- Zero-cross tachometer timestamps (zct)
- A fixed gear ratio of 5.095238095 from tachometer shaft to turbine shaft → nominal turbine speed ≈ 536.27 Hz
- Bearing geometry factors (cage, ball, inner race, outer race): [0.43, 7.05, 10.78, 8.22], yielding nominal fault-band centers at [231, 3781, 5781, 4408] Hz (based on mean turbine speed).

![Instantaneous shaft speed](image-url "Optional title")

Files provided are file_1.csv, file_2.csv, …, file_N.csv (in a random, scrambled order).

Channels per file:
- Acceleration (1 channel, 93 750 Hz)
- Tachometer zero-cross timestamps (zct)

Fixed parameters table:
![Fixed Parameter table](image-url "Optional title")

# Getting Started
1) Download key files
2) Extract features that should evolve monotonically.
3) Rank files by your chosen feature(s) to estimate the true chronological order
4) Create and upload your submission using the attachments section of the form, using the correct file type (.csv), naming convention, and including methodology description and executable code.
5) Check the leaderboard after submitting.
6) Use your score, status, or competition to guide your next submission!

# Solution Requirements
Submissions must provide the predicted sequence ordering, executable code, and a short, technical description of the method used.

TII is primarily interested in solutions that meet the following must-have requirements:

- **Private Leaderboard ranking**: as the quantitative measure of the Challenge, your leaderboard score will be taken into account when evaluating your submission. The closer the score is to 0, the better/more highly you will rank – using the Spearman Footrule Distance. A score of 0 indicates a perfect chronological order of the dataset. You can view the score for every Coding Submission on the 'My Submissions' tab of the **Leaderboard**.

Pairwise Order Accuracy will be used as a secondary, tie-breaker metric:
Pairwise Order Accuracy (higher is better): 
PairAcc(pi-hat,pi-star) = 1 - Int(pie-hat,pie-star)/(N2), where Inv is the number of discordant pairs

![Pairwise order](image-url "Optional title")

- **Correct format of submission**
 - Provide a .csv file, titled submission.csv, containing a single column with header “prediction” containing an array of N integers – representing the predicted chronological order of the files for the bearing degradation (so that e.g. the first integer in the column represents the predicted position in the true chronological order of file_1.csv).
The permutation/order you submit must include all N files, with no duplicates or omissions, in the format of 1-N (e.g., {1, …, N} – there is no need to include 0 or summary rows.

- - Provide **executable code**, either through a link, attachment, or in the form text (please denote).
  - Submit a concise, written explanation of your methodology, with room to add attachments.


- **Soundness of your methodology**:
The technical validity and merit demonstrated by your methodology will be considered in making the final decision.
Please note again: TII will consider both quantitative and qualitative measures to determine success in this Challenge.

# Submission

### Prediction file
*Type*: .csv file, uploaded as attachment to the submission form
Naming convention: submission.csv
Data range: Submit files from {1, …, N}, no need to include 0 or summary rows.
Format:
```
prediction

p_1

p_2

...

p_N
```

[Where p_i represents the predicted position in the true chronological order of file_i.csv. Predicted positions should be in {1, …, N}. The permutation/order you submit must include all N files, with no duplicates or omissions. Files that are not structured in this manner or with this file type will not be picked up by the leaderboard and will not be considered.]

### Executable Code:
*Type*: GitHub repository, library, distribution package, Jupyter notebook uploaded as links in relevant form field, or uploaded as attachment to the submission form.

### Methodology description:
*Type*: Uploaded in PDF or text file format as an attachment to the submission form.
*Details*: Written answer describing how you developed your solution, your modelling approach, any difference from previous approaches, and any assumptions or observations.

You will also be asked about your **Participation Type** (Individual or Organization), and your relevant **Experience** in the submission form. Please ensure you answer the Experience point in at least one of your submissions.
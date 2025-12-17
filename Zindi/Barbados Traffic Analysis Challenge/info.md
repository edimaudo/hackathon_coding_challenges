# Overview

## Can you predict traffic flow to identify the root causes of traffic in a Barbados roundabout?
On the small island state of Barbados, cars, buses and taxis are the primary mode of transport, and traffic is a well-known problem that affects every Barbadian citizen. The Ministry of Transport and Works wants your help to try and solve the problem with machine learning.

In this challenge, your task is to predict traffic congestion using machine learning, with the aim of recognising the root causes of traffic in a specific roundabout in Barbados. You will be provided with four streams of video data, labelled with the congestion rating for the entrance and exit timestamps, and your model should predict traffic congestion five minutes into the future. Ultimately, we are interested in identifying the root causes of increased time spent in the roundabout by developing features from unstructured video data. Back-propagation is not allowed in training or inference.

The winning models will help the Ministry of Transport and Works predict traffic flow and identify and address root causes of traffic in roundabouts. They will use this information to design interventions to reduce traffic across the island, improving the lives of every citizen.

## Evaluation
This challenge uses multi-metric evaluation. There are two error metrics: F1 and Accuracy.

Your score on the leaderboard is the weighted mean of two metrics:

**Macro-F1 (70%)**: measures how well your model performs across all four congestion classes, treating each class equally. This is important because some classes may appear less often in the data.
**Accuracy (30%)** - measures the overall percentage of correct predictions across all samples.
This means your model should aim for high accuracy and balanced performance across all classes.

For every row in the dataset, submission files should contain 3 columns: id, Target and Target_Accuracy.

F1 is calculated from the column Target.

Accuracy is calculated from the column Target_Accuracy.

Your submission file needs to follow the SampleSubmission.csv file exactly, especially the order and casing of the headers.

ID                                                         Target       Target_Accuracy
time_segment_181_Norman Niles #1_congestion_enter_rating   heavy delay  heavy delay
time_segment_181_Norman Niles #1_congestion_exit_rating    heavy delay  heavy delay
time_segment_181_Norman Niles #2_congestion_enter_rating   heavy delay  heavy delay 
time_segment_181_Norman Niles #2_congestion_exit_rating    heavy delay  heavy delay
time_segment_181_Norman Niles #3_congestion_enter_rating   heavy delay  heavy delay 
time_segment_181_Norman Niles #3_congestion_exit_rating    heavy delay  heavy delay
time_segment_181_Norman Niles #4_congestion_enter_rating   heavy delay  heavy delay 
time_segment_181_Norman Niles #4_congestion_exit_rating    heavy delay  heavy delay


## Data
You are provided with video data from four cameras, with unique views of the four entrances and exits of the Norman Niles traffic roundabout. Each ~1 minute time segment is at the same period for all four cameras, and is labeled with a congestion classification [“free flowing”, “light delay”, “moderate delay”, “heavy delay”].

Your task is to develop models that extract and engineer features from the raw video data to predict the congestion level. These features should capture underlying traffic dynamics such as flow rate, number of vehicles, vehicle entry and exit timing, or other movement patterns that correlate with congestion. You are free to use any reproducible automated modeling or labeling techniques (excluding manual labelling). The test set contains only videos (no labels), and your model must infer congestion classes based solely on learned representations from the training phase.

You may augment or generate your own training data to increase the number of training samples. Ensure that your train creation process is reproducible and included in your submitted code.

Back propagation is NOT allowed in training or in inference. Zindi is committed to providing solutions of value to the client. The implementation of this solution will be to ingest 15timestamps of video data and to predict the 18th to 23rd congestion_enter_rating and congestion_exit_rating.

This is the structure: Training data → Test input → 2-minute embargo (operational lag) → 5-minute test output.

Your solution should operate in real time, meaning:

- Each minute must be predicted sequentially.
- You cannot use data from minute N+1 to predict minute N.
- You cannot use a training segment that follows a test period to inform or adjust your model during inference.
- Back-propagation within a training loop (i.e. updating model weights during normal training) is, of course, allowed — just keep the real-time deployment context in mind.

This means you should not use future data to predict the pass as this would not be possible in the real world.

Anecdotal evidence indicates that in Barbados, many drivers do not use turn signals when entering or exiting roundabouts — a key behavioral factor that may increase congestion. The Ministry hopes that insights from this challenge will help design targeted interventions to improve traffic flow across the island.

The top 20 solutions on the private leaderboard must provide documentation on the top factors contributing to congestion ratings. After the challenge closes, we will request a document from the top 20 with a table that includes feature name, feature contribution, and notes.

You are welcome to use any modeling and labelling techniques, except manual labelling, to label the data. Suggestions include flow rate, number of cars entering and exiting the roundabout, use of indicator, vehicle type, vehicle occupancy, or anything else you can identify from the video data.

For test periods, you are provided with 15 minutes input data, followed by a two-minute embargo. This data is embargoed because in practice, the video data will be processed during this time and won’t be available instantaneously. The prediction period is 5 minutes after the 2 minute embargo period.

## Dataset

- brb-traffic contains the smaller re-encoded dataset: https://storage.googleapis.com/brb-traffic/
- brb-traffic-full contains the full >500GB dataset: https://storage.googleapis.com/brb-traffic-full/
- Train.csv
-TestInputSegment.csv

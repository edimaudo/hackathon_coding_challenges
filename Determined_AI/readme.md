# Determined AI Model Training Hackathon

Build and train a ML model with the fastest and easiest tool to build deep learning models at scale.

## REQUIREMENTS

### WHAT TO BUILD
A machine learning project (complete with deep learning-based model, training loop, evaluation loop, dataset) that works on the Determined AI platform. See the Rules.

### WHAT TO SUBMIT
- A model training project leveraging Determined AI
- A link to the public open-source code repository for the project, including:
  - All code for the project
  - Final model weights
 - A README file containing:
   - Project objective
   - A data sample from your dataset with an explanation
   - A description of your model architecture
   - Instructions for how to run your training job
   - A screenshot of your best metrics from the Determined web UI
   - A description of your evaluation metrics
   - Your evaluation results given these metrics, and
   - Instructions for how to reproduce the evaluation results
- A link to each dataset used within the project. Datasets must be publicly available for the judges and sponsor to test your project.

## Project Objective
### Challenge: Improving Efficiency & Production Process of Electric Vehicles using Data Science Techniques
It is often a challenging and complex task to measure rotor and stator temperatures in commercial electric vehicles. Even if these specific tasks can be completed successfully, these testing processes cannot be classified as economical for manufacturers. Keeping in mind that the temperature data have significant importance on dynamical responses of vehicles and motors’ performances, there is an emerging need for new proposals and scientific contributions in this domain.

Building a predictive machine learning or deep learning model that can propose an estimator for the stator and rotor temperatures could be used to utilize new control strategies of the motors and maximize their operational performances. If an accurate ML/DL model is built, the needs of the company for implementing additional temperature sensors in vehicles will be reduced. The potential contribution will directly result in lowering car construction and maintenance costs.

### Initial considerations
The motors are excited by reference torques and reference velocities. These reference signals are achieved by adjusting motor currents (“i_d” and “i_q”) and voltages (“u_d” and “u_q”) within appropriate control strategy.
Temperature estimations should be real-time, and not based on future values for current predictions. Real-time predictions shall protect the motor from overheating.
The motor torque increases in inverse proportion to the decreased temperature.
A steady-state of a motor can be achieved faster at lower temperatures.
Phase currents increase with increased magnet temperature.
Dataset

### Data Dictionary
Variable    |    Description

Ambient     |	Ambient temperature – measured by a thermal sensor

coolant	    |	Coolant temperature measured at outflow.

u_d		    |    Voltage d-component

u_q 	    |    Voltage q-component

motor_speed |    Motor speed

torque      | Torque induced by current.

i_d         | Current d-component

i_q         | Current q-component

pm          | Permanent Magnet surface temperature (the rotor temperature) – measured with an infrared thermography unit

stator_yoke | Stator yoke temperature – measured by a thermal sensor.

stator_tooth| Stator tooth temperature – measured by a thermal sensor.

stator_winding | Stator winding temperature – measured by a thermal sensor.

profile_id  | Each measurement session with a unique ID.


### Outcomes
Submit your prediction results of your test dataset with four below variables (in csv file) and be sure to name them “predicted_temperatures“.
Unique IDs of these sessions are not presented in the Test dataset as they are within Training dataset, so be careful. Don’t switch the rows within the test data frame and use all the measurements in the established order.

Variable                   Description

pm_predicted             | Predicted rotor temperature

stator_yoke_predicted    | Predicted stator yoke temperature

stator_tooth_predicted   | Predicted stator tooth temperature

stator_winding_predicted | Predicted stator winding temperature

Calculate the overall Root Mean Square Error (RMSE) by adding the RMSE of each of the examined variables with the help of the solution dataset, and name them: RMSE_pm, RMSE_stator_yoke, RMSE_stator_tooth, RMSE_stator_winding. 
Results of test dataset and RMSE. 

## Data Sample

## Model Architecture

## Training job instructions

## Screenshot of best metrics

## Evaluation Metrics

## Final model weights

## Evaluation Results

## How to reproduce results

## Dataset links

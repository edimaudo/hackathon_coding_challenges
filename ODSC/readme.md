## Challenge: Improving Efficiency & Production Process of Electric Vehicles using Data Science Techniques
***

This challenge has been designed to provide with you hands-on understanding of data science problems in commercial EVs’ production and optimization in most advanced motor technologies used by companies like Tesla, BMW and Ford. 

It is often a challenging and complex task to measure rotor and stator temperatures in commercial electric vehicles. Even if these specific tasks can be completed successfully, these testing processes cannot be classified as economical for manufacturers. Keeping in mind that the temperature data have significant importance on dynamical responses of vehicles and motors’ performances, there is an emerging need for new proposals and scientific contributions in this domain.

Consider, one manufacturer of electric cars hired you to propose an estimator for the stator and rotor temperatures and design a predictive machine learning or deep learning model. Such a model could significantly help your new company to utilize new control strategies of the motors and maximize their operational performances. If you build an accurate ML/DL model, the needs of the company for implementing additional temperature sensors in vehicles will be reduced. The potential contribution will directly result in lowering car construction and maintenance costs, and will convince the company to invest further in hiring DS experts like you.


### Initial considerations
The motors are excited by reference torques and reference velocities. These reference signals are achieved by adjusting motor currents (“i_d” and “i_q”) and voltages (“u_d” and “u_q”) within appropriate control strategy.
Temperature estimations should be real-time, and not based on future values for current predictions. Real-time predictions shall protect the motor from overheating.
The motor torque increases in inverse proportion to the decreased temperature.
A steady-state of a motor can be achieved faster at lower temperatures.
Phase currents increase with increased magnet temperature.
Dataset
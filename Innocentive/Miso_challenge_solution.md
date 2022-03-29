## THE CHALLENGE
MISO envisions a future where resource maintenance and outage scheduling is handled in a more automated, self-service environment. In this future, the entire needs of asset maintenance are captured and optimized. The future capabilities of MISO’s operations need to reduce human dependencies and still operate with the highest reliability and efficiency possible.
Specifically, MISO seeks to improve in the following areas:

- How does MISO increase the certainty around outages?
- How do we minimize dependence on MISO staff?
- What technologies would lead to greater predictability and accuracy? How could we implement those?
- What mathematical models or algorithms could be applied to MISO’s outage coordination process?
- What would simplify the process?

Any proposed solution should address the following Solution Requirements: 
- Allows resource down time while protecting system integrity by ensuring a minimum quality of available resources
- Balances overall system integrity with fairness to individual resource owners in allowing for routine maintenance
- Integrates the request, analysis, and scheduling functions while allowing visibility of availability to requestors.

Provide detailed and specific guidance on how to implement major components of the proposed solution and how each component interacts with the other components, including stakeholder systems and input.
The solutions would preferably satisfy the additional following criteria (but not essential):
- Provides insight into how other industries handle scheduled and unscheduled maintenance in high reliability environments.

## Project Criteria
Submitted proposals along with all relevant supporting data should include the information described in the Detailed Description of the Challenge. The solution may combine existing components, commercially available components, and/or novel Solver solutions. Ideas leveraged from other industries with similar problems are encouraged.

The submitted proposal must be written in English and should include the following:
1) An Abstract and optional Conclusion.
2) Detailed description of an approach to an outage coordination system that can meet the above Solution Requirements. This must include:
a) A detailed block diagram/wireframe view of the proposed system with major components and information flow indicated
b) Specific details of each component and how to implement the functionality of the component. This may include custom or commercial software, and in the case of custom software a detailed description of the algorithm and architecture is required
c) Detailed narratives for different outage request scenarios beginning with a request from a participant. Narratives must describe the information flow between components, the decision process within relevant components, and the operation of each component utilized in the scenario. Scenarios must include:
- A simple outage request that can be approved automatically
- An outage request that requires a full outage study and is approved
- An outage request that is denied
3) Rationale as to why the Solver believes that the proposed system will work. This rationale should address each of the Solution Requirements described in the Detailed Description and should be supported with any relevant examples and/or scenarios.
4) Data, drawings etc. necessary to convey the full extent of the proposed solution.

# SOLUTION SUMMARY

## Solution Name
MOMS - Miso Outage Management System

## Solution Abstract
 

## Solution conlusion


#--------------------
# SOLUTION IN DETAIL
#--------------------
MISO (Midcontinent Independent System Operator) is an independent, not-for-profit, member-based organization that delivers safe, cost-effective electric power across 15 U.S. states and the Canadian province of Manitoba. A major service they provide is the coordination of scheduled and unscheduled outages of electricity generation and transmission assets. These assets are controlled by various stakeholders and must occasionally be taken offline for maintenance and repair.  The current process for scheduling outages and coordinating with different stakeholders is cumbersome.  
The goal is to develop a new system that would assist MISO in meeting these criteria:
- Increase the certainty around outages
- Minimize dependence on MISO staff
- Driver greater predictability and accuracy
- Simplify the outage coordination process
- Simplify the overall process

The solution that would solve these challenges is MOMSP.  MOMSP stands for MISO Outage Mangement System & Processes.  It encompasses two key areas:
- outage management system (OMS)
- outage management processes

Why would it be needed
The status quo is not going to be effective moving forward as the supply fo power is being impacted by different factors such as: (https://www.ge.com/digital/blog/riding-storm-network-digital-twin-enhance-electric-grid-reliability-resiliency)
- Climate change is increasing the frequency and magnitude of severe weather events
- Aging infrastructure is increasingly vulnerable to forced outages


An OMS is any type of software or computing device that assists in locating, analyzing, and fixing an outage on the energy grid.  OMS operates within the context of individual utilities, they are often able to coordinate with many different sources of data in order to get an accurate image of the grid in real-time. Some key sources that enable an OMS to function are a Geographical Information System (GIS), a Customer Information System (CIS), Automated Metering Infrastructure (AMI), Mobile Workforce Management Systems (MWM), and Supervisory Control and Data Acquisition Systems (SCADA). 
Some features of an OMS can include but are not limited to, automatically reading grid data to determine an outage, alerting utility operators of any outages, and sending notifications to nearby field crews to investigate and fix outages. (https://www.awesense.com/what-are-outage-management-systems-oms/)

Benefits ot OMS
- An OMS can make a big difference for your local/national utility and for your own power usage. Using new meter technology like AMI, outages are now detected faster than ever. Combined with a good OMS software, many outages today are fixed without anyone even noticing they occurred. 
- Though many outages are detected when a person loses power in their home and calls up their local utility, a reliable OMS can identify this information and provide a quicker response than waiting for you and your neighbor to dial in. 
- This automated coordination and processing an OMS provides means more reliable power and faster resolution for issues to help keep your home running smoothly.


OMS features (https://www.ge.com/digital/blog/riding-storm-network-digital-twin-enhance-electric-grid-reliability-resiliency)
has a suite of diverse cross-domain models and multi-disciplinary software applications to holistically and scientifically consider both non-power and power system factors to provide:

Outage Risk Prediction for transmission assets, based on their vulnerabilities to extreme weather conditions
Real Time Unplanned Outage Detection and Real Time Decision Support for optimal planning and prediction of the impact of plans on the state of the grid
Real Time Automated Closed Loop Control for execution of the plans to reliably operate the grid during Emergency
Transmission Outage & Restoration Planner (TORP), a data analytics application, 
along with Real Time Shutdown & Restoration Manager (RTSRM), 
a control room Advanced Energy Management System (AEMS) application
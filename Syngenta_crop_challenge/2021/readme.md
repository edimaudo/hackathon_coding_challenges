## THE CHALLENGE
***

## PROBLEM SETTING
Commercial corn is processed into multiple food and industrial products and is widely known as one of the world’s most important crops. However, it typically requires many years of in-field testing to deliver new products to market. Recently, innovative and novel technologies have shortened the time required to develop new corn hybrids—new products that can deliver higher-yielding, better-adapted seed options for growers at a faster pace. These promising technologies decrease the amount of time needed to create the parents of commercial hybrids. Commercial hybrids are created by crossing two parents together, so by reducing the amount of time to create these parents, scientists can deliver novel products to growers years faster. By continuously optimizing our product development system with these promising technologies, scientists can ensure increased crop yields for global food security.

With the increased rate of producing parental lines comes new challenges—increased output (the number of harvested ears) can cause storage capacity limitations. Our year-round breeding process could be improved by optimizing planting schedules to achieve a consistent output – a weekly harvest quantity (number of ears).

Erratic weekly harvest quantities create logistical and productivity issues. How can we optimally schedule the planting of our seeds to ensure that when ears are harvested, facilities are not over capacity, and that there is a consistent number of ears each week? This issue is the basis for the 2021 Syngenta Crop Challenge in Analytics. Figure 1 provides diagram for this process.


Figure 1: Process Diagram


## RESEARCH QUESTION
Can an optimal scheduling model be created to ensure consistent weekly harvest quantities that are below the maximum capacity? Figure 2 illustrates a representation of this problem.


Figure 2: Illustration of research question

## OBJECTIVE
The objective is scheduling the planting date for each population to ensure the capacity constraints are met and that there is consistent harvest quantity. The following is the desired objective function.
Objective: Minimize the difference between the weekly harvest quantity and the capacity for each harvesting week.
For each harvesting week and location:
Min: weeklyharvestTotal - locationCapacity
Capacity Constraint: For scenario 1, Site 0 has a capacity of 7000 ears and Site 1 has a capacity of 6000 ears.
For scenario 2, there is not a predefined capacity. The participant is asked to determine the lowest capacity required.
In summary, we desire an optimization model to schedule when planting should occur for a specific seed population so that when the ears are harvested, we are not over holding capacity.

Additional Notes
Each week runs from Sunday – Saturday.
There are two scenarios for a given population’s harvest quantity. The two scenarios roughly emulate normal distributions: N(250,100) and N(350,150), respectively.

## DELIVERABLES
Creation of a planting schedule that:
1. Plants all populations within their available time window,
2. Ensures maximum capacity is not exceeded, and
3. Provides consistent weekly harvest quantity.

Additionally, observing the standards for academic publication, entries should include a written report with the following:

1. Quantitative results to justify your modeling techniques
2. A clear description of the methodology and theory
3. References or citations as appropriate

## EVALUATION CRITERIA

The entries will be evaluated based on:
1. Quantitative evaluation metrics:
	- The maximum and median difference between the weekly harvest quantity and the capacity among all harvesting weeks.
	- Total number of harvest weeks – fewer is preferred.
	- Recommendation of the lowest capacity required for both locations while still considering the other evaluation metrics.
	- Note that, both locations will be evaluated equally.
2. Simplicity and intuitiveness of the solution
3. Clarity in the explanation
4. The quality and clarity of the finalist’s presentation at the 2021 INFORMS Conference on Business Analytics and Operations Research

## DATASETS

You are provided with the following datasets described below.
### Dataset #1
This dataset describes the input variables for an optimization model as well as the number of growing degree units (GDUs) in Celsius needed for harvest. Succinctly, GDUs are a measure of heat accumulation and are used to estimate specific stages of a plant’s growth cycle. In our dataset, for a given population the “required_gdus” is the number of heat units required in order for the corn population to be ready for harvesting.
### Dataset #2
This dataset describes the growing degree units in Celsius accumulated for each day for sites 0 and 1 over the last 10 years. Note that due to the formula for calculating GDUs, year-to-year, GDUs will be different. The participant will need to determine the best way to make use of this historical dataset.
### Dataset #3 (Output)
This dataset is used for evaluation of the optimization model. This is where the planting date will be entered.
### Dataset #4 (Output)
This dataset is used for evaluation of the optimization model. This is where the weekly harvest quantity and recommended capacity for scenario 2 will be entered.


## Dataset #1 	Description
Variable					Description
Population					Seed population identifier
site						Planting site either 0 or 1
original_planting_date		Actual planting date of the population
early_planting_date			Earliest the population could have been planted
late_planting_date			Latest the population could have been planted
required_gdus			    Number of growing degree units needed for harvest
scenario_1_harvest_quantity	Harvest quantity (number of ears) for each population in scenario 1. The value in 								this column must be used as the harvest quantity, not just a percentage of this 							value.
scenario_2_harvest_quantity	Harvest quantity (number of ears) for each population in scenario 2. 
							The value in this column must be used as the harvest quantity, not just a percentage of this value.


## Dataset #2 Description
Variable	Description
date		Calendar date
site_0		GDUs accumulated for each calendar day at site_0
site_1		GDUs accumulated for each calendar day at site_1


## Dataset #3 Description (Planting Schedule Output):
Variable		Description
population		Population of seed
scenario		Scenario indicator
site			Planting site either 0 or 1
planting_date	Planting date for the given population – to be completed by participant


## Dataset #4 Description (harvest Quantity Output):
Variable			Description
scenario			Scenario indicator
site				Planting site either 0 or 1
week				Week index starting from the first week of January 2020.
harvest_quantity	Harvest quantity for the given week – to be completed by participant
capacity			Capacity for scenario 1 – to be completed by participant for scenario 2
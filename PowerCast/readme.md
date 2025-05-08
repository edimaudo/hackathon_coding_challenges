# Overview
Electricity prices fluctuate due to supply, demand, and market dynamics changes. Accurately forecasting these prices is essential for energy traders, industrial consumers, and grid operators to optimize operations, manage risk, and improve market efficiency. This challenge focuses on developing highly accurate and business-relevant electricity price forecasting models for real-world decision-making.
Work with real electricity market data from SMARD (Germany’s electricity market platform), including actual and forecasted generation, consumption, balancing reserves, and cross-border flows. Leverage machine learning and statistical modeling techniques to predict next-day or intraday electricity prices, identify market trends, and assess price volatility.

A successful submission will provide accurate forecasts and deliver meaningful insights into price fluctuations, risk levels, and market behavior in Germany. Participants will submit a structured report summarizing their findings, modeling approach, and key business takeaways.

Submissions will be evaluated based on prediction accuracy, interpretability, business applicability, and overall quality of analysis. 



# Report Guideline

## Objective
Submit a well-rounded report that synthesizes your findings from the data analysis in a format designed to be both accessible and engaging for a diverse audience, including those without technical expertise.

**Audience**
Your report should target an audience without a statistics or data analysis background. Imagine presenting your findings to business people eager to understand the insights but unfamiliar with data analytics terminology or techniques.

## Recommended Sections

**Introduction**
- Provide a concise overview of the purpose and goals of the analysis.
- Use simple, engaging language that avoids jargon and captures the audience's interest.

**Key Findings**
- Present the main insights and discoveries in a clear, straightforward manner.
- Explain any analytical concepts or findings using layman's terms.
- Create a section/subsection for each question of the evaluation criteria.

**Data Visualizations:**
- Include intuitive, visually appealing charts, graphs, and tables that enhance understanding.
- Add concise explanations to help readers interpret the visualizations.

**In-depth Analysis:**
- Break down the analysis of each question, ensuring clarity and simplicity.
- Use analogies, examples, or simple comparisons to make complex ideas relatable and easy to grasp.

**Conclusion:**
- Summarize the key takeaways and implications of your analysis.
- Offer recommendations or actionable next steps in a straightforward, approachable manner.

**Appendix (if needed):**
- Include additional charts, data, or supporting information that complements the main body of the report but is not critical for the primary narrative.


# Data
The dataset contains 16 files which track data on electricity markets and power generation, with a focus on Germany and surrounding European countries. The data includes day-ahead electricity prices, cross-border flows of electricity, and power generation from various sources (e.g., wind, solar, nuclear). Most of the files contain data at 15-minute or hourly intervals for dates ranging from January 1, 2023 to March 5, 2025.

Key themes in the data include:

Electricity Prices: Multiple files track day-ahead electricity prices in Germany and neighboring countries. This data includes the prices in different countries and regions, as well as the average prices of neighboring countries.

Cross-Border Electricity Flows: The data also includes information on the scheduled and actual cross-border flows of electricity between Germany and other countries. This includes both exports and imports of electricity for each country.

Power Generation: Several files contain data on power generation from various sources, including renewable energy sources (e.g., wind, solar, biomass) and conventional sources (e.g., nuclear, coal, gas). This data is provided for Germany and other European countries.

Balancing Services: Some files track the activation and procurement of balancing services, which are used to maintain the stability of the electricity grid. This includes data on the volume and price of balancing energy and reserves.

Data quality is of the utmost importance. Consequently, data provided in this challenge is sourced from "Strommarktdaten" (SMARD), which receives the data directly from the European Network of Transmission System Operators for Electricity (ENTSO-E). Only data verified by the "Bundesnetzagentur" is published on SMARD. The "Bundesnetzagentur" is constantly exchanging information with the transmission network operators (TSOs) in order to continuously improve data quality.


Source: Bundesnetzagentur | SMARD.de


# Evaluation Criteria

## Exploratory Data Analysis (EDA)

Must analyze the dataset to understand key market trends, correlations, and feature importance for forecasting electricity prices.

1. Market Trends & Price Fluctuations (10 points)
- How do electricity prices fluctuate hourly, daily, and weekly across differt countries?
- How do electricity consumption patterns change in the same timeframes, and how does this impact pricing?
- How does electricity generation (actual vs. forecast) align with price trends?
- What patterns emerge from scheduled commercial exchanges and cross-border physical flows?

2. Correlation & Feature Relationships (10 Points)
- What features have the strongest correlation with electricity prices?
- How do electricity prices correlate between different countries?
- What is the relationship between forecasted vs. actual electricity generation and consumption?
- How do balancing reserves and TSO costs impact electricity prices?

3. Price & Consumption Impact Analysis (10 Points)
- How do scheduled commercial exchanges influence price fluctuations?
- What is the impact of cross-border physical flows on electricity prices?

## Market-Driven Prediction Accuracy

Models should be optimized for real-world decision-making, not just low RMSE.

1. Directional Accuracy (10 Points)
- What percentage of predictions are correct when classified as rising, falling, or stable?

2. Volatility Capture (10 Points)
- How well does the model capture the volatility observed in the data?

3. Extreme Price Movement Detection (5 Points)
- Can the model correctly predict sharp price spikes (>15% increase or decrease)?

## Business Usability & Interpretability

For commercial viability, the model must be trustworthy, explainable, and actionable.
How often does the model correctly predict whether prices will increase or decrease?

1. Confidence Intervals & Probability Forecasting (10 Points)
- Can it quantify uncertainty (e.g., 95% probability the price will be between X and Y)?
2. Interpretability & Feature Importance (5 Points)
- Are SHAP values, feature importance graphs, or similar methods used?
- Is there a clear explanation of why prices changed?

## Deployment Readiness & Scalability

The winning model should be ready for integration.

- Does the model effectively forecast electricity prices for a chosen time period (15-minute, 1-hour, or 1-day ahead)?***
- How well does it perform within the selected timeframe in terms of accuracy and reliability?
*** Choose 15-minute, 1-hour, or 1-day so you do not have to build multiple models


## Report if needed
20 points
Can submit a structured report summarizing their work and findings.

1. Exploratory Data Analysis (EDA)
- Describe key trends, feature correlations, and insights from the dataset.
- Justify which features were selected and why.

2. Modeling Approach
- Outline the machine learning techniques used.

3. Results & Performance Metrics
- Present accuracy scores, volatility capture rates, and interpretability insights.
- Show feature importance and uncertainty measures.

4. Key Business Takeaways
- How can energy traders, industrial consumers, and grid operators use these predictions?
- What are the model’s strengths and limitations?
- How could this model be improved or commercialized in the future?
- Reports will be evaluated based on clarity, depth of analysis, and business relevance.
- Reports will be evaluated based on clarity, depth of analysis, and business relevance

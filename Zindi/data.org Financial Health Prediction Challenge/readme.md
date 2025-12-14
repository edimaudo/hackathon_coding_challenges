# Can you predict the financial well-being of small businesses?
Across Southern Africa, small and medium-sized enterprises (SMEs) are vital to employment, innovation, and economic growth, yet many remain financially fragile and excluded from formal financial systems. Limited access to credit, unstable cash flow, and exposure to shocks such as illness or climate events make them vulnerable. Traditional measures like revenue or profit do not capture an SME’s true financial well-being. To support SMEs more effectively, there is a need for a holistic measure that reflects resilience, savings habits, and access to finance.

This challenge introduces a data-driven Financial Health Index (FHI) for SMEs - a composite measure that classifies businesses into Low, Medium, or High financial health across four key dimensions: savings and assets, debt and repayment ability, resilience to shocks, and access to credit and financial services. Derived from survey and business data, the FHI offers a more complete picture of financial stability and inclusion. It provides a rich dataset capturing the financial behaviour, resilience, and operational realities of small and medium-sized enterprises (SMEs) across Eswatini, Lesotho, Malawi, and Zimbabwe. The data is sourced from SME surveys and includes detailed information about business owners, their financial habits, exposure to risks, access to credit, and overall business performance.

Participants will build machine learning models to predict the FHI using socio-economic and business data such as traded commodities, export and import activity, demographics, firm size, and location. This data is sourced from four Southern African countries - Eswatini, Lesotho, Zimbabwe, and Malawi. But the relevance of such an index extends to businesses in developing economies all over the world.

By quantifying SME financial health, the challenge supports data-driven policies and inclusive financing strategies. Financial institutions can better assess credit risk, while development partners and governments can identify vulnerable businesses and target support where it is needed most.

Ultimately, the Financial Health Index redefines how SME wellbeing is measured, beyond profits to resilience and opportunity. By predicting how financially healthy a business is today, participants will help shape the tools and insights that enable small enterprises to thrive tomorrow.


Your task is to use these features to predict the Financial Health Index (FHI) - a category of low, medium or high that reflects how financially resilient and well-positioned each business is. The index incorporates aspects such as savings habits, debt, shock resilience, and access to formal financial services.

## About

[data.org](https://data.org) is a platform accelerating the use of data and AI to solve major global challenges and build the field of data for social impact. It convenes and coordinates across sectors to advance practical solutions, host innovation challenges, and train purpose-driven data practitioners. By 2032, data.org aims to train 1 million purpose-driven data and AI professionals, foster digital public goods, and build connections for impactful data use around the world.

[FinMark Trust](https://finmark.org.za) is an independent non-profit trust with the purpose of making financial markets work for people in poverty by promoting financial inclusion and regional financial integration. We pursue our core objective of making financial markets work for people living in poverty through two principal programmes. The first happens through the creation and analysis of financial services demand-side data to provide in-depth insights on both served and unserved consumers across the developing world. The second is through systematic financial sector inclusion and deepening programmes to overcome regulatory, supplier and other market-level barriers hampering the effective provision of services.

## Evaluation
The evaluation metric for this challenge is the F1 score.

For every row in the dataset, submission files should contain 2 columns: ID and Target:
```
ID            Target
ID_5EGLKX    Low
ID_4AI7RE    Low
ID_V9OB3M    Low
```

## Data
- Test.csv -- This is the dataset that you will use to train your model. It contains the target.

- Train.csv -- This shows the submission format for this challenge.

- SampleSubmission.csv -- Full list of variables and their explanations.

- VariableDefinitions.csv -- This is a starter notebook to help you make your first submission.

- Starter Notebook.ipynb

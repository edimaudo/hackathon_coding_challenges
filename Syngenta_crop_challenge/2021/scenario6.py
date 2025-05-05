# # 🌽 Scenario 6 Optimization (Minimize Deviation from Site Median Harvest Quantities)

## 🔧 Setup
```python
import pandas as pd
import numpy as np
from pulp import *
from datetime import datetime

# Load data
df1 = pd.read_csv('/mnt/data/Dataset_1.csv')
df2 = pd.read_csv('/mnt/data/Dataset_2.csv')

# Convert dates
df1['early_planting_date'] = pd.to_datetime(df1['early_planting_date'])
df1['late_planting_date'] = pd.to_datetime(df1['late_planting_date'])
df2['date'] = pd.to_datetime(df2['date'])
```

## 📈 GDU Accumulation
```python
gdu_df = df2.set_index('date')
gdu_cumsum = gdu_df.cumsum()
```

## ⚙️ Model Initialization
```python
model = LpProblem("Scenario_6_Minimize_Deviation_From_Median", LpMinimize)
decision_vars = {}
harvest_tracker = {}
```

## 🔄 Build Decision Variables & Track Harvest Weeks
```python
for i, row in df1.iterrows():
    pop = row['Population']
    site = row['site']
    gdu_needed = row['required_gdus']
    qty = row['scenario_2_harvest_quantity']
    early = row['early_planting_date']
    late = row['late_planting_date']

    decision_vars[pop] = {}

    for plant_day in pd.date_range(early, late):
        try:
            gdu_series = gdu_cumsum.loc[plant_day:, f"site_{site}"]
            harvest_day = gdu_series[gdu_series - gdu_series.iloc[0] >= gdu_needed].index[0]
        except IndexError:
            continue

        var = LpVariable(f"x_{pop}_{plant_day.date()}", 0, 1, LpBinary)
        decision_vars[pop][plant_day] = (var, harvest_day)

        h_week = (harvest_day - datetime(2020, 1, 1)).days // 7
        if (site, h_week) not in harvest_tracker:
            harvest_tracker[(site, h_week)] = []
        harvest_tracker[(site, h_week)].append((var, qty))
```

## 🔗 Ensure Exactly One Planting Date Per Population
```python
for pop in decision_vars:
    model += lpSum([v[0] for v in decision_vars[pop].values()]) == 1
```

## 🧮 Median Harvest Per Site (from Scenario 2)
```python
# Pre-calculate the median harvest values per site from Scenario 2
median_per_site = df1.groupby("site")["scenario_2_harvest_quantity"].median().to_dict()
```

## 📉 Objective: Minimize Total Deviation from Median
```python
deviation_vars = {}
for (site, week), entries in harvest_tracker.items():
    total = lpSum([v * q for v, q in entries])
    median = median_per_site[site]
    diff = LpVariable(f"deviation_{site}_{week}", lowBound=0)
    model += total - median <= diff
    model += median - total <= diff
    deviation_vars[(site, week)] = diff

model += lpSum(deviation_vars.values()), "Total_Absolute_Deviation_From_Median"
```

## 🚀 Solve
```python
model.solve(PULP_CBC_CMD(msg=1))
print(f"Status: {LpStatus[model.status]}")
print(f"Total Absolute Deviation: {value(model.objective):.0f}")
```

## ✅ Output and Validation
```python
planting_plan = []
harvest_summary = []

for pop in decision_vars:
    for plant_day in decision_vars[pop]:
        var, h_day = decision_vars[pop][plant_day]
        if var.varValue == 1:
            site = df1[df1['Population'] == pop]['site'].values[0]
            qty = df1[df1['Population'] == pop]['scenario_2_harvest_quantity'].values[0]
            week = (h_day - datetime(2020, 1, 1)).days // 7
            planting_plan.append([pop, 6, site, plant_day.date()])
            harvest_summary.append([6, site, week, qty])

planting_df = pd.DataFrame(planting_plan, columns=["population", "scenario", "site", "planting_date"])
harvest_df = pd.DataFrame(harvest_summary, columns=["scenario", "site", "week", "harvest_quantity"])

# Validation: Check absolute deviation manually
for (site, week), group in harvest_df.groupby(['site', 'week']):
    total = group.harvest_quantity.sum()
    expected = median_per_site[site]
    assert abs(total - expected) <= 10000, f"Large deviation detected at {site} week {week}"
```

---

✅ Scenario 6 complete: The model minimizes the **total absolute deviation** of weekly harvests from their site-specific medians while maintaining feasible planting windows and GDU constraints.

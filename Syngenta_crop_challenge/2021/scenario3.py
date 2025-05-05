# # 🌽 Planting Schedule Optimization - Scenario 3 (Capacity Boundaries)

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

## 📈 GDU Calculations
```python
gdu_df = df2.set_index('date')
gdu_cumsum = gdu_df.cumsum()
```

## 📦 Model Initialization
```python
model = LpProblem("Scenario_3_Capacity_Boundaries", LpMinimize)
decision_vars = {}
harvest_tracker = {}
```

## 🔄 Build Decision Variables and Harvest Tracker
```python
for i, row in df1.iterrows():
    pop = row['Population']
    site = row['site']
    gdu_needed = row['required_gdus']
    qty = row['scenario_2_harvest_quantity']  # same quantities used
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

        week = (harvest_day - datetime(2020, 1, 1)).days // 7
        if (site, week) not in harvest_tracker:
            harvest_tracker[(site, week)] = []
        harvest_tracker[(site, week)].append((var, qty))
```

## 📊 Scenario 2 Weekly Capacities
```python
scenario2_capacity = {}
for (site, week), entries in harvest_tracker.items():
    scenario2_capacity[(site, week)] = sum([qty for _, qty in entries])
```

## 📉 Apply ±20% Capacity Boundaries
```python
for (site, week), entries in harvest_tracker.items():
    total = lpSum([v * q for v, q in entries])
    base_cap = scenario2_capacity[(site, week)]
    model += total >= 0.8 * base_cap
    model += total <= 1.2 * base_cap
```

## 📏 Planting Constraints
```python
for pop in decision_vars:
    model += lpSum([decision_vars[pop][d][0] for d in decision_vars[pop]]) == 1
```

## 🎯 Objective Function
```python
model += 0, "No_Objective_Just_Feasibility"
```

## 🚀 Solve
```python
model.solve(PULP_CBC_CMD(msg=1))
print(f"Status: {LpStatus[model.status]}")
```

## ✅ Output & Validation
```python
planting_plan = []
harvest_summary = []

for pop in decision_vars:
    for date in decision_vars[pop]:
        var, h_day = decision_vars[pop][date]
        if var.varValue == 1:
            site = df1[df1['Population'] == pop]['site'].values[0]
            qty = df1[df1['Population'] == pop]['scenario_2_harvest_quantity'].values[0]
            week = (h_day - datetime(2020, 1, 1)).days // 7
            planting_plan.append([pop, 3, site, date.date()])
            harvest_summary.append([3, site, week, qty])

planting_df = pd.DataFrame(planting_plan, columns=["population", "scenario", "site", "planting_date"])
harvest_df = pd.DataFrame(harvest_summary, columns=["scenario", "site", "week", "harvest_quantity"])

# Validation
for (site, week), base_cap in scenario2_capacity.items():
    subset = harvest_df[(harvest_df['site'] == site) & (harvest_df['week'] == week)]
    actual = subset['harvest_quantity'].sum()
    assert 0.8 * base_cap <= actual <= 1.2 * base_cap, f"Capacity violation at site {site}, week {week}"
```

---

✅ **Scenario 3 optimization model implemented with ±20% bounds based on Scenario 2 capacities.** Let me know if you want a combined dashboard, visual summaries, or to start on Scenario 4!

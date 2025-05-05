# # 🌽 Scenario 5 Optimization (Minimize Max Weekly Harvest Quantity)

## 🔧 Setup
```python
import pandas as pd
import numpy as np
from pulp import *
from datetime import datetime

# Load data
df1 = pd.read_csv('/mnt/data/Dataset_1.csv')
df2 = pd.read_csv('/mnt/data/Dataset_2.csv')

# Date conversion
df1['early_planting_date'] = pd.to_datetime(df1['early_planting_date'])
df1['late_planting_date'] = pd.to_datetime(df1['late_planting_date'])
df2['date'] = pd.to_datetime(df2['date'])
```

## 📈 GDU Accumulation
```python
gdu_df = df2.set_index('date')
gdu_cumsum = gdu_df.cumsum()
```

## ⚙️ Model Setup
```python
model = LpProblem("Scenario_5_Minimize_Max_Harvest_Quantity", LpMinimize)
decision_vars = {}
harvest_tracker = {}
```

## 🔄 Build Variables & Track Harvests
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

## 🔗 Assignment Constraint
```python
for pop in decision_vars:
    model += lpSum([decision_vars[pop][d][0] for d in decision_vars[pop]]) == 1
```

## 📊 Minimize Max Weekly Harvest Quantity
```python
z = LpVariable("max_weekly_harvest_quantity", lowBound=0)

for (site, week), entries in harvest_tracker.items():
    model += lpSum([v * q for v, q in entries]) <= z, f"limit_weekly_harvest_{site}_{week}"

model += z, "Minimize_Max_Harvest"
```

## 🚀 Solve
```python
model.solve(PULP_CBC_CMD(msg=1))
print(f"Status: {LpStatus[model.status]}")
print(f"Maximum Weekly Harvest Quantity: {z.varValue:.0f}")
```

## ✅ Output and Validation
```python
planting_plan = []
harvest_summary = []

for pop in decision_vars:
    for date in decision_vars[pop]:
        var, h_day = decision_vars[pop][date]
        if var.varValue == 1:
            site = df1[df1['Population'] == pop]['site'].values[0]
            qty = df1[df1['Population'] == pop]['scenario_2_harvest_quantity'].values[0]
            week_h = (h_day - datetime(2020, 1, 1)).days // 7
            planting_plan.append([pop, 5, site, date.date()])
            harvest_summary.append([5, site, week_h, qty])

planting_df = pd.DataFrame(planting_plan, columns=["population", "scenario", "site", "planting_date"])
harvest_df = pd.DataFrame(harvest_summary, columns=["scenario", "site", "week", "harvest_quantity"])

# Validation
weekly_max = harvest_df.groupby(['site', 'week']).harvest_quantity.sum().max()
assert abs(weekly_max - z.varValue) < 1e-3, "Mismatch in max weekly harvest calculation"
```

---

✅ Scenario 5 complete: Successfully minimizes the **maximum weekly harvest quantity** across all sites while maintaining feasible planting schedules. Ready for analysis or final summary!

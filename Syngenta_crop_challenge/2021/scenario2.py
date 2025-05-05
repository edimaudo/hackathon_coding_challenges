# # 🌽 Planting Schedule Optimization - Scenario 2 (Variable Capacity)

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
model = LpProblem("Scenario_2_Variable_Capacity", LpMinimize)
decision_vars = {}
harvest_tracker = {}
site_week_combinations = set()
```

## 🔄 Build Variables and Harvest Map
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

        week = (harvest_day - datetime(2020, 1, 1)).days // 7
        site_week_combinations.add((site, week))
        if (site, week) not in harvest_tracker:
            harvest_tracker[(site, week)] = []
        harvest_tracker[(site, week)].append((var, qty))
```

## 🔧 Capacity Variables and Deviation
```python
capacity_vars = {}
deviations = {}
for (site, week) in site_week_combinations:
    cap = LpVariable(f"cap_{site}_{week}", 0)
    deviation = LpVariable(f"dev_{site}_{week}", 0)
    capacity_vars[(site, week)] = cap
    deviations[(site, week)] = deviation

    total_harvest = lpSum([v * q for v, q in harvest_tracker[(site, week)]])
    model += total_harvest - cap <= deviation
    model += cap - total_harvest <= deviation
```

## 🎯 Objective Function
```python
model += lpSum(deviations.values()), "Total_Deviation_From_Capacity"
```

## 📏 Planting Constraints
```python
for pop in decision_vars:
    model += lpSum([decision_vars[pop][d][0] for d in decision_vars[pop]]) == 1
```

## 🚀 Solve
```python
model.solve(PULP_CBC_CMD(msg=1))
print(f"Status: {LpStatus[model.status]}")
```

## 📊 Output & Validation
```python
planting_plan = []
harvest_totals = []

for pop in decision_vars:
    for date in decision_vars[pop]:
        var, h_day = decision_vars[pop][date]
        if var.varValue == 1:
            site = df1[df1['Population'] == pop]['site'].values[0]
            qty = df1[df1['Population'] == pop]['scenario_2_harvest_quantity'].values[0]
            week = (h_day - datetime(2020, 1, 1)).days // 7
            planting_plan.append([pop, 2, site, date.date()])
            harvest_totals.append([2, site, week, qty, value(capacity_vars[(site, week)])])

planting_df = pd.DataFrame(planting_plan, columns=["population", "scenario", "site", "planting_date"])
harvest_df = pd.DataFrame(harvest_totals, columns=["scenario", "site", "week", "harvest_quantity", "capacity"])

# Validation
assert planting_df['population'].nunique() == df1['Population'].nunique(), "Not all populations planted."
assert (harvest_df['harvest_quantity'] <= harvest_df['capacity']).all(), "Harvest exceeds capacity in some weeks."
```

---

✅ **Scenario 2 optimization model completed.** Let me know if you'd like both scenarios combined or visualized!

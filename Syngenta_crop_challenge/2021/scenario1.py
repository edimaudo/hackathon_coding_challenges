# # 🌽 Planting Schedule Optimization - Scenario 1 (Fixed Capacity)

## 🔧 Setup
```python
import pandas as pd
import numpy as np
from pulp import *
from datetime import datetime, timedelta

# Load datasets
df1 = pd.read_csv('/mnt/data/Dataset_1.csv')
df2 = pd.read_csv('/mnt/data/Dataset_2.csv')

# Convert date fields
df1['early_planting_date'] = pd.to_datetime(df1['early_planting_date'])
df1['late_planting_date'] = pd.to_datetime(df1['late_planting_date'])
df2['date'] = pd.to_datetime(df2['date'])

# Fixed site capacities
site_capacity = {0: 7000, 1: 6000}
```

## 📈 Cumulative GDU Calculation
```python
# Pivot Dataset 2 and compute cumulative GDU
gdu_data = df2.set_index('date')
gdu_cum = gdu_data.cumsum()
```

## 📦 Model Initialization
```python
# Initialize model
model = LpProblem("Planting_Schedule_Optimization", LpMinimize)

# Decision variables
decision_vars = {}
harvest_weeks = {}
weekly_harvest = {}
```

## 🔄 Build Planting and Harvest Mapping
```python
for index, row in df1.iterrows():
    pop = row['Population']
    site = row['site']
    required_gdu = row['required_gdus']
    quantity = row['scenario_1_harvest_quantity']
    early = row['early_planting_date']
    late = row['late_planting_date']
    
    decision_vars[pop] = {}

    for day in pd.date_range(early, late):
        future = gdu_cum.loc[day:, f"site_{site}"]
        try:
            harvest_day = future[future - future.iloc[0] >= required_gdu].index[0]
        except IndexError:
            continue

        var = LpVariable(f"x_{pop}_{day.date()}", 0, 1, LpBinary)
        decision_vars[pop][day] = (var, harvest_day)

        week = (harvest_day - datetime(2020, 1, 1)).days // 7
        if (site, week) not in weekly_harvest:
            weekly_harvest[(site, week)] = []
        weekly_harvest[(site, week)].append((var, quantity))
```

## 🎯 Objective Function
```python
# Minimize deviation from weekly capacity
deviations = {}
for (site, week), items in weekly_harvest.items():
    deviation = LpVariable(f"deviation_{site}_{week}", 0)
    total_harvest = lpSum([v * q for v, q in items])
    model += total_harvest - site_capacity[site] <= deviation
    model += site_capacity[site] - total_harvest <= deviation
    deviations[(site, week)] = deviation

model += lpSum(deviations.values()), "Total_Deviation"
```

## 📏 Constraints
```python
# Each population must be planted exactly once
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
# Extract planting schedule and weekly harvest
planting_schedule = []
harvest_output = {}

for pop in decision_vars:
    for day in decision_vars[pop]:
        var, harvest_day = decision_vars[pop][day]
        if var.varValue == 1:
            site = df1[df1['Population'] == pop]['site'].values[0]
            quantity = df1[df1['Population'] == pop]['scenario_1_harvest_quantity'].values[0]
            week = (harvest_day - datetime(2020, 1, 1)).days // 7
            planting_schedule.append([pop, 1, site, day.date()])
            harvest_output[(1, site, week)] = harvest_output.get((1, site, week), 0) + quantity

planting_df = pd.DataFrame(planting_schedule, columns=["population", "scenario", "site", "planting_date"])
harvest_df = pd.DataFrame([
    {"scenario": s, "site": si, "week": w, "harvest_quantity": q, "capacity": site_capacity[si]}
    for (s, si, w), q in harvest_output.items()
])

# Validation Steps
assert planting_df['population'].nunique() == df1['Population'].nunique(), "Not all populations planted."
assert (harvest_df['harvest_quantity'] <= harvest_df['capacity']).all(), "Capacity exceeded in some weeks."
```

---

✅ **Scenario 1 complete. Proceeding to Scenario 2 next...**

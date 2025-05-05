# # 🌽 Scenario 9 Optimization (Multi-Objective: Quantity Balance + Peak Reduction)

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
model = LpProblem("Scenario_9_Multi_Objective", LpMinimize)
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

## 🔗 One Planting per Population
```python
for pop in decision_vars:
    model += lpSum([v[0] for v in decision_vars[pop].values()]) == 1
```

## 🧮 Define Harvest Sums and Weekly Deviation Variables
```python
avg_weekly = df1.groupby('site')['scenario_2_harvest_quantity'].sum() / 52
site_weeks = set(harvest_tracker.keys())

deviation_vars = {}
max_vars = {}

for site in df1['site'].unique():
    max_vars[site] = LpVariable(f"max_harvest_{site}", lowBound=0)

for (site, week) in site_weeks:
    dev = LpVariable(f"dev_{site}_{week}", lowBound=0)
    total = lpSum([v * q for v, q in harvest_tracker[(site, week)]])
    deviation_vars[(site, week)] = dev
    model += total - avg_weekly[site] <= dev
    model += avg_weekly[site] - total <= dev
    model += total <= max_vars[site]  # also enforce peak weekly harvest
```

## 🎯 Objective: Minimize Combined Objective
```python
model += lpSum(deviation_vars.values()) + 0.1 * lpSum(max_vars.values()), "Multi_Objective_Deviation_and_Peak"
```

## 🚀 Solve
```python
model.solve(PULP_CBC_CMD(msg=1))
print(f"Status: {LpStatus[model.status]}")
for site in max_vars:
    print(f"Max weekly harvest at {site}: {max_vars[site].varValue:.0f}")
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
            planting_plan.append([pop, 9, site, plant_day.date()])
            harvest_summary.append([9, site, week, qty])

planting_df = pd.DataFrame(planting_plan, columns=["population", "scenario", "site", "planting_date"])
harvest_df = pd.DataFrame(harvest_summary, columns=["scenario", "site", "week", "harvest_quantity"])

# Validation: Check constraints
for (site, week), group in harvest_df.groupby(['site', 'week']):
    total = group.harvest_quantity.sum()
    assert total <= max_vars[site].varValue + 1e-5, f"Exceeded max at {site} week {week}"
    deviation = abs(total - avg_weekly[site])
    assert deviation <= deviation_vars[(site, week)].varValue + 1e-5, f"Deviation error at {site} week {week}"
```

---

✅ Scenario 9 complete: this **multi-objective optimization** balances weekly harvests around the average while reducing the **maximum harvest spikes** across sites.

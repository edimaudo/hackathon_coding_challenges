# Required Python libraries
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Data Integration
# Load event and tracking data
events_data = pd.read_csv('events.csv')
tracking_data = pd.read_csv('tracking.csv')

# Filter relevant events for forechecking analysis
forechecking_events = events_data[events_data["Event"].isin(["Puck Recovery", "Zone Entry"])]

# Merge tracking and event data based on period and clock
merged_data = pd.merge(
    forechecking_events,
    tracking_data,
    how="inner",
    left_on=["Period", "Clock"],
    right_on=["Period", "Game Clock"]
)
print(merged_data.head())


# Spatial analysis
# Plot spatial distribution of events
plt.figure(figsize=(12, 6))
plt.scatter(
    merged_data[merged_data["Event"] == "Puck Recovery"]["X_Coordinate"],
    merged_data[merged_data["Event"] == "Puck Recovery"]["Y_Coordinate"],
    color="blue", alpha=0.5, label="Puck Recovery"
)
plt.scatter(
    merged_data[merged_data["Event"] == "Zone Entry"]["X_Coordinate"],
    merged_data[merged_data["Event"] == "Zone Entry"]["Y_Coordinate"],
    color="red", alpha=0.5, label="Zone Entry"
)
plt.axhline(0, color="black", linestyle="--", alpha=0.7)
plt.axvline(0, color="black", linestyle="--", alpha=0.7)
plt.title("Spatial Distribution of Forechecking Events")
plt.xlabel("X Coordinate (Rink Length)")
plt.ylabel("Y Coordinate (Rink Width)")
plt.legend()
plt.grid(alpha=0.3)
plt.show()

# Timing analysis
# Add time difference between zone entry and puck recovery
merged_data['Time_Difference'] = merged_data['Time_Seconds_recovery'] - merged_data['Time_Seconds_entry']

# Filter recoveries within a 10-second window
successful_recoveries = merged_data[
    (merged_data['Time_Difference'] >= 0) & (merged_data['Time_Difference'] <= 10)
]

# Calculate recovery success rate
recovery_success_rate = len(successful_recoveries) / len(merged_data[merged_data['Event'] == "Zone Entry"]) * 100
print(f"Recovery Success Rate: {recovery_success_rate}%")

# Heatmap of event clusters
# Create a heatmap of event densities
sns.kdeplot(
    data=merged_data[merged_data["Event"] == "Puck Recovery"],
    x="X_Coordinate", y="Y_Coordinate",
    cmap="Blues", fill=True, alpha=0.7, label="Puck Recovery"
)
sns.kdeplot(
    data=merged_data[merged_data["Event"] == "Zone Entry"],
    x="X_Coordinate", y="Y_Coordinate",
    cmap="Reds", fill=True, alpha=0.5, label="Zone Entry"
)
plt.title("Heatmap of Forechecking Event Clusters")
plt.xlabel("X Coordinate")
plt.ylabel("Y Coordinate")
plt.legend()
plt.show()
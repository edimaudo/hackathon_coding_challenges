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
# Analyze success rates and timing for forechecking events
# Calculate time to puck recovery following zone entries
forechecking_events["Time_Seconds"] = forechecking_events["Clock"].apply(
    lambda x: int(x.split(":")[0]) * 60 + int(x.split(":")[1])  # Convert "MM:SS" to seconds
)

# Identify Zone Entries and subsequent Puck Recoveries within a timeframe
zone_entries = forechecking_events[forechecking_events["Event"] == "Zone Entry"]
puck_recoveries = forechecking_events[forechecking_events["Event"] == "Puck Recovery"]

# Merge on periods and filter by time proximity to find successful recoveries after entries
zone_entry_recoveries = pd.merge(
    zone_entries, puck_recoveries, on="Period", suffixes=("_entry", "_recovery")
)
zone_entry_recoveries["Time_Difference"] = (
    zone_entry_recoveries["Time_Seconds_recovery"] - zone_entry_recoveries["Time_Seconds_entry"]
)

# Filter recoveries within 10 seconds of a zone entry (arbitrary threshold for analysis)
successful_recoveries = zone_entry_recoveries[
    (zone_entry_recoveries["Time_Difference"] >= 0) & (zone_entry_recoveries["Time_Difference"] <= 10)
]

# Calculate the recovery success rate
recovery_success_rate = len(successful_recoveries) / len(zone_entries) * 100

# Summary of timing distribution for successful recoveries
timing_distribution = successful_recoveries["Time_Difference"].describe()

recovery_success_rate, timing_distribution

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
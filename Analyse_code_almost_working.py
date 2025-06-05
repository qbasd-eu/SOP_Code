#Chat_code to analyse it
import csv
import matplotlib.pyplot as plt

# Name of the text file containing the CSV data
filename = "Experiment_values.txt"

# Lists to store the data
times = []        # elapsed time (ms)
water_levels = [] # distance values in cm
flow_rates = []   # flow rate in L/min

# Open and read the file
with open(filename, 'r') as file:
    csv_reader = csv.reader(file)
    for row in csv_reader:
        if len(row) != 3:
            # Skip lines that don't have exactly 3 columns
            continue
        try:
            elapsed = float(row[0])
            distance = float(row[1])
            flow_rate = float(row[2])
        except ValueError:
            # Skip the line if conversion fails (could be a header)
            continue

        times.append(elapsed)
        water_levels.append(distance)
        flow_rates.append(flow_rate)

# --- Plotting the Data ---

# Create a figure with two subplots vertically arranged
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8))

# Plot the water level (distance) vs. time in the first subplot
ax1.plot(times, water_levels, 'b-', label="Distance (cm)")
ax1.set_title("Water Level (Ultrasonic Sensor)")
ax1.set_xlabel("Elapsed Time (ms)")
ax1.set_ylabel("Distance (cm)")
ax1.legend(loc="upper right")
ax1.grid(True)

# Plot the flow rate vs. time in the second subplot
ax2.plot(times, flow_rates, 'r-', label="Flow Rate (L/min)")
ax2.set_title("Flow Rate (YF-S401 Sensor)")
ax2.set_xlabel("Elapsed Time (ms)")
ax2.set_ylabel("Flow Rate (L/min)")
ax2.legend(loc="upper right")
ax2.grid(True)

plt.tight_layout()
plt.show()

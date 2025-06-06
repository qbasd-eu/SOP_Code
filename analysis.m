% Load both CSVs
data1 = readtable('Calibrated_Experiment_1.csv');
data2 = readtable('Calibrated_Experiment_2.csv');

% Extract relevant columns
time1 = data1.Time_sec;
flow1 = data1.FlowSensor_Calibrated_L_per_min;
vol1  = data1.Volume_Calibrated_mL;

time2 = data2.Time_sec;
flow2 = data2.FlowSensor_Calibrated_L_per_min;
vol2  = data2.Volume_Calibrated_mL;

% Common time base
start_time = max(min(time1), min(time2));
end_time = min(max(time1), max(time2));
common_time = linspace(start_time, end_time, 200);

% Interpolate measured data
flow1_interp = interp1(time1, flow1, common_time, 'linear', 'extrap');
flow2_interp = interp1(time2, flow2, common_time, 'linear', 'extrap');
vol1_interp  = interp1(time1, vol1, common_time, 'linear', 'extrap');
vol2_interp  = interp1(time2, vol2, common_time, 'linear', 'extrap');

% Combine and average
flow_all = [flow1_interp', flow2_interp'];
flow_mean = mean(flow_all, 2);
flow_stderr = std(flow_all, 0, 2) ./ sqrt(size(flow_all, 2));

% Average volume in mL → m³
vol_mean_m3 = mean([vol1_interp; vol2_interp], 1) / 1e6;

% Interpolate Distance data (in cm)
dist1 = data1.Distance_cm;
dist2 = data2.Distance_cm;

dist1_interp = interp1(time1, dist1, common_time, 'linear', 'extrap');
dist2_interp = interp1(time2, dist2, common_time, 'linear', 'extrap');

% Average interpolated distances
dist_mean_cm = mean([dist1_interp; dist2_interp], 1);

% Convert to height, then to meters
distance_max_cm = max([dist1; dist2]);  % max across both datasets
h = (distance_max_cm - dist_mean_cm) / 100;  % in meters

% Constants
g = 9.81;
A_outlet = pi * (0.004/2)^2;     % ≈ 2.83e-5 m²
A_tank   = pi * (0.065/2)^2;     % ≈ 3.32e-3 m²
C_d = 1;                       % optional discharge coefficient

% Initial height from initial distance (in meters)
initial_dist_cm = mean([dist1(1), dist2(1)]);
dist_max_cm = max([dist1; dist2]);
h0 = (dist_max_cm - initial_dist_cm) / 100;  % in meters

% Theoretical height over time
term = (A_outlet / (2 * A_tank)) * sqrt(2 * g);  % constant factor
sqrt_h = sqrt(h0) - term * common_time;
h_theoretical = max(sqrt_h, 0).^2;  % avoid imaginary or negative heights

% Theoretical flow rate
v_theoretical = sqrt(2 * g * h_theoretical);
Q_theoretical = C_d * A_outlet * v_theoretical;  % m³/s
Q_theoretical_L_per_min = Q_theoretical * 60 * 1000;

% Plot
hfig = figure;
hold on;

% Measured data with error bars
errorbar(common_time, flow_mean, flow_stderr, 'o-', 'LineWidth', 1.5, 'DisplayName', 'Measured Mean $\pm$ SE');

% Theoretical flow
plot(common_time, Q_theoretical_L_per_min, 'r--', 'LineWidth', 2, 'DisplayName', 'Theoretical Flow (Bernoulli)');

xlabel('Time (s)');
ylabel('Flow Rate (L/min)');
title('Measured vs Theoretical Flow Rate');
fname = 'Measured_vs_Theoretical_Flow_Rate';
legend('Location', 'best');
grid on;

picturewidth = 20; % set this parameter and keep it forever
hw_ratio = 0.65; % feel free to play with this ratio
set(findall(hfig,'-property','FontSize'),'FontSize',17) % adjust fontsize to your document

set(findall(hfig,'-property','Box'),'Box','off') % optional
set(findall(hfig,'-property','Interpreter'),'Interpreter','latex') 
set(findall(hfig,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(hfig,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
pos = get(hfig,'Position');
set(hfig,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
print(hfig, fname,'-dpng','-vector')
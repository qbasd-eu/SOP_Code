% Enhanced calibration script - includes flow rate analysis and comparison
clear; clc; close all;

% Reservoir parameters
reservoir_diameter = 6.5; % cm
reservoir_radius = reservoir_diameter / 2; % cm
reservoir_area = pi * reservoir_radius^2; % cm²

% Known starting volume for calibration (Dataset 1)
known_starting_volume = 500; % ml

% Read Dataset 1 for calibration
data1 = readmatrix('Experiment_values_1.txt');
time1 = data1(:,1);      % Time in milliseconds
distance1 = data1(:,2);  % Distance in cm
flow_sensor1 = data1(:,3); % Flow rate in L/min

% Convert time to seconds
time1_sec = time1 / 1000;

% Calculate uncalibrated volume
max_distance1 = max(distance1);
water_height1 = max_distance1 - distance1; % cm
volume1_uncal_ml = reservoir_area * water_height1; % Convert cm³ to mL

% Calculate calibration factor
uncalibrated_first_volume1 = volume1_uncal_ml(1);
calibration_factor = known_starting_volume / uncalibrated_first_volume1;

% Apply calibration
volume1_ml = volume1_uncal_ml * calibration_factor;

% Calculate average flow rate from distance sensor using total volume/time
start_time = time1_sec(1);
end_time = time1_sec(end);
elapsed_time_sec = end_time - start_time;

start_volume = volume1_ml(1);
end_volume = volume1_ml(end);
delta_volume_ml = start_volume - end_volume; % Ensure positive flow

avg_flow_rate_distance = (delta_volume_ml / elapsed_time_sec) * 60 / 1000; % L/min

% Calculate average flow rate from flow sensor (excluding zero readings)
flow_sensor_nonzero = flow_sensor1(flow_sensor1 > 0);
avg_flow_rate_sensor = mean(flow_sensor_nonzero);

% Calculate flow sensor calibration factor
% Use the average flow rate from distance sensor as reference
flow_sensor_calibration_factor = avg_flow_rate_distance / avg_flow_rate_sensor;

% Apply calibration to flow sensor data
flow_sensor_calibrated = flow_sensor1 * flow_sensor_calibration_factor;
avg_flow_rate_sensor_calibrated = mean(flow_sensor_calibrated(flow_sensor_calibrated > 0));

% Display calibration and flow rate results
fprintf('Distance Sensor Calibration Results:\n');
fprintf('===================================\n');
fprintf('Known starting volume: %.2f mL\n', known_starting_volume);
fprintf('Uncalibrated first measurement: %.2f mL\n', uncalibrated_first_volume1);
fprintf('Distance calibration factor: %.6f\n', calibration_factor);
fprintf('Calibrated first measurement: %.2f mL\n\n', volume1_ml(1));

fprintf('Flow Sensor Calibration Results:\n');
fprintf('===============================\n');
fprintf('Average flow rate (distance sensor - reference): %.3f L/min\n', avg_flow_rate_distance);
fprintf('Average flow rate (flow sensor - original): %.3f L/min\n', avg_flow_rate_sensor);
fprintf('Flow sensor calibration factor: %.6f\n', flow_sensor_calibration_factor);
fprintf('Average flow rate (flow sensor - calibrated): %.3f L/min\n', avg_flow_rate_sensor_calibrated);
fprintf('Difference after calibration: %.3f L/min\n', abs(avg_flow_rate_distance - avg_flow_rate_sensor_calibrated));
fprintf('Relative error after calibration: %.1f%%\n\n', abs(avg_flow_rate_distance - avg_flow_rate_sensor_calibrated) / avg_flow_rate_distance * 100);

% Create original volume calibration plot
hfig1 = figure;

plot(time1_sec, volume1_uncal_ml, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Uncalibrated');
hold on;
plot(time1_sec, volume1_ml, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Calibrated');
yline(known_starting_volume, 'k--', 'LineWidth', 1.5, 'DisplayName', 'Known Reference');
xlabel('Time (seconds)');
ylabel('Volume (mL)');
fname = 'Volume_Calibration';
title(sprintf('Volume Calibration, factor: %.3f', calibration_factor));
legend('Location', 'best');
grid on;

picturewidth = 20; % set this parameter and keep it forever
hw_ratio = 0.65; % feel free to play with this ratio
set(findall(hfig1,'-property','FontSize'),'FontSize',17) % adjust fontsize to your document

set(findall(hfig1,'-property','Box'),'Box','off') % optional
set(findall(hfig1,'-property','Interpreter'),'Interpreter','latex') 
set(findall(hfig1,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(hfig1,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
pos = get(hfig1,'Position');
set(hfig1,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
print(hfig1, fname,'-dpng','-vector')

% Create flow rate comparison figure
hfig2 = figure('Position', [100, 100, 1000, 600]);

% Plot the three flow rate curves
plot(time1_sec, flow_sensor1, 'r-', 'LineWidth', 2, 'DisplayName', 'Original Flow Sensor');
hold on;
plot(time1_sec, flow_sensor_calibrated, 'g-', 'LineWidth', 2, 'DisplayName', 'Calibrated Flow Sensor');

% Add horizontal line for average flow rate from distance sensor
yline(avg_flow_rate_distance, 'b--', 'LineWidth', 2.5, 'DisplayName', sprintf('Distance Sensor Avg: %.3f L/min', avg_flow_rate_distance));

xlabel('Time (seconds)');
ylabel('Flow Rate (L/min)');
title(sprintf('Flow Rate Calibration, factor: %.3f', flow_sensor_calibration_factor));
legend('Location', 'best');
grid on;

% Set y-axis limits for better visualization
max_flow = max([max(flow_sensor1), max(flow_sensor_calibrated), avg_flow_rate_distance]);
ylim([0, max_flow * 1.1]);

picturewidth = 20; % set this parameter and keep it forever
hw_ratio = 0.65; % feel free to play with this ratio
set(findall(hfig2,'-property','FontSize'),'FontSize',17) % adjust fontsize to your document

set(findall(hfig2,'-property','Box'),'Box','off') % optional
set(findall(hfig2,'-property','Interpreter'),'Interpreter','latex') 
set(findall(hfig2,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(hfig2,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
pos = get(hfig2,'Position');
set(hfig2,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])

% Save the figure
fname = 'Flow_Rate_Calibration_Comparison';
print(hfig2, fname, '-dpng', '-vector');

% Create table of calibrated data
calibrated_data = table();
calibrated_data.Time_sec = time1_sec;
calibrated_data.Distance_cm = distance1;
calibrated_data.Volume_Calibrated_mL = volume1_ml;
calibrated_data.FlowSensor_Calibrated_L_per_min = flow_sensor_calibrated;

% Write to file
output_filename = 'Calibrated_Experiment_1.csv';
writetable(calibrated_data, output_filename);

fprintf('Calibrated data has been written to "%s"\n', output_filename);

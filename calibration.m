% Simplified calibration script - outputs calibration factor and comparison graph only
clear; clc; close all;

% Reservoir parameters
reservoir_diameter = 6.5; % cm
reservoir_radius = reservoir_diameter / 2; % cm
reservoir_area = pi * reservoir_radius^2; % cm²

% Known starting volume for calibration (Dataset 1)
known_starting_volume = 500; % ml

% Read Dataset 1 for calibration
data1 = readmatrix('Experiment_values.txt');
time1 = data1(:,1);      % Time in milliseconds
distance1 = data1(:,2);  % Distance in cm

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

% Display calibration results
fprintf('Calibration Results:\n');
fprintf('===================\n');
fprintf('Known starting volume: %.2f mL\n', known_starting_volume);
fprintf('Uncalibrated first measurement: %.2f mL\n', uncalibrated_first_volume1);
fprintf('Calibration factor: %.6f\n', calibration_factor);
fprintf('Calibrated first measurement: %.2f mL\n\n', volume1_ml(1));

% Create calibration comparison plot
hfig = figure;

plot(time1_sec, volume1_uncal_ml, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Uncalibrated');
hold on;
plot(time1_sec, volume1_ml, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Calibrated');
yline(known_starting_volume, 'k--', 'LineWidth', 1.5, 'DisplayName', 'Known Reference');
xlabel('Time (seconds)');
ylabel('Volume (mL)');
fname = 'Volume_Calibration';
title('Volume Calibration');
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
%print(hfig,fname,'-dpdf','-painters','-fillpage')
print(hfig, fname,'-dpng','-vector')
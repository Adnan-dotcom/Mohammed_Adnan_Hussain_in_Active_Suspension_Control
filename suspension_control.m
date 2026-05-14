%% ULTIMATE Active Suspension: Live Animation & Advanced Analysis
% Features: Interactive Menu, Live Car Animation, Stochastic Road Profile, 6-Graph Analysis
% Author: Mohammed Adnan Hussain

clear; clc; close all;

%% 1. Interactive Input Menu
fprintf('--- Mohammed Adnan Hussain: Active Suspension Controller ---\n');
disp('Select Road Scenario for Animation:');
disp('1. The Pothole (Step Impact)');
disp('2. The Speed Table (Pulse Bump)');
disp('3. Random Rough Road (Stochastic Profile)');
choice = input('Enter choice (1-3): ');

if isempty(choice) || choice < 1 || choice > 3; choice = 1; end

%% 2. System Definition
% Nominal Plant: G(s) = 1 / (ms^2 + cs + k)
m = 1.0; c = 3; k = 2;
G = tf(1, [m c k]);

% Robustness Plant (+20% mass)
G_heavy = tf(1, [1.2 c k]);

% Controllers
C_comf = tf([8 15], [1]);   % Comfort
C_sport = tf([15 100], [1]); % Sport
C_bal = tf([5 30], [1]);     % Balanced

% Closed-Loops
sys_comf = feedback(C_comf*G, 1);
sys_sport = feedback(C_sport*G, 1);
sys_bal = feedback(C_bal*G, 1);
sys_heavy = feedback(C_bal*G_heavy, 1);

%% 3. Generate Simulation Data
t = 0:0.02:5;
if choice == 1
    u_road = ones(size(t)); % Pothole
    scenario_name = 'Scenario: The Pothole';
elseif choice == 2
    u_road = (t >= 1 & t <= 2); % Speed Table
    scenario_name = 'Scenario: The Speed Table';
else
    % Random Road Roughness (Filtered White Noise)
    u_road = cumsum(randn(size(t))*0.1); 
    u_road = u_road - mean(u_road); % Center it
    scenario_name = 'Scenario: Random Rough Road';
end

[y_comf] = lsim(sys_comf, u_road, t);
[y_sport] = lsim(sys_sport, u_road, t);
[y_bal] = lsim(sys_bal, u_road, t);

%% 4. LIVE ANIMATION (The "Wow" Factor)
figure('Color', 'k', 'Position', [100 100 800 400], 'Name', 'Live Suspension Animation');
set(gcf, 'DoubleBuffer', 'on');

for i = 1:length(t)
    clf; hold on; grid off; axis off;
    set(gca, 'Color', 'k');
    
    % Draw Ground/Road
    plot([0 10], [0 0], 'w', 'LineWidth', 2);
    
    % Road Surface (Visual)
    road_x = linspace(2, 8, 100);
    road_y = interp1(t + 2, u_road, road_x, 'linear', 0);
    plot(road_x, road_y, 'gray', 'LineWidth', 1.5);
    
    % Car Body (Rectangle)
    car_y = y_bal(i); 
    rectangle('Position', [4, car_y + 0.5, 2, 1], 'Curvature', 0.2, 'FaceColor', [0 0.5 1], 'EdgeColor', 'w');
    
    % Wheels
    viscircles([4.5, car_y + 0.5], 0.2, 'EdgeColor', 'w');
    viscircles([5.5, car_y + 0.5], 0.2, 'EdgeColor', 'w');
    
    % Suspension Spring (Visual)
    plot([5 5], [road_y(50) car_y + 0.5], 'y', 'LineWidth', 2);
    
    title(['Live Simulation: ', scenario_name], 'Color', 'w', 'FontSize', 14);
    text(2.5, 2, sprintf('Time: %.2fs', t(i)), 'Color', 'w');
    text(2.5, 1.8, sprintf('Body Displacement: %.3fm', car_y), 'Color', [0 0.5 1], 'FontWeight', 'bold');
    
    xlim([2 8]); ylim([-1 3]);
    pause(0.01);
end

%% 5. COMPREHENSIVE 6-GRAPH DASHBOARD
figure('Color', 'w', 'Position', [150 150 1200 800], 'Name', 'Engineering Performance Dashboard');

% --- A. Comfort vs Sport ---
subplot(3,2,1);
hold on; grid on;
step(sys_comf, 'g', sys_sport, 'b', 5);
title('A. Comfort vs Sport (Step Response)');
legend('Comfort', 'Sport');

% --- B. Robustness (+20% Mass) ---
subplot(3,2,2);
hold on; grid on;
step(sys_bal, 'k', sys_heavy, 'r--', 5);
title('B. Robustness: Extra Weight Test');
legend('Nominal', 'Heavy (+20%)');

% --- C. Scenario Comparison ---
subplot(3,2,3);
hold on; grid on;
plot(t, u_road, 'k--', 'LineWidth', 1);
plot(t, y_bal, 'm', 'LineWidth', 2);
title(['C. Current ', scenario_name]);
legend('Road Profile', 'Car Body');

% --- D. Control Effort ---
Tu_bal = feedback(C_bal, G);
subplot(3,2,4);
hold on; grid on;
step(Tu_bal, 'k', 5);
yline(80, 'r--', 'Limit');
title('D. Actuator Force (Control Effort)');

% --- E. Frequency Response (Bode) ---
subplot(3,2,5);
bode(sys_bal);
grid on;
title('E. Frequency Response (Bandwidth)');

% --- F. Settling Time Comparison ---
subplot(3,2,6);
i_c = stepinfo(sys_comf); i_s = stepinfo(sys_sport); i_h = stepinfo(sys_heavy);
bar([i_c.SettlingTime, i_s.SettlingTime, i_h.SettlingTime]);
set(gca, 'XTickLabel', {'Comfort', 'Sport', 'Heavy'});
ylabel('Seconds'); title('F. Settling Time KPIs');

sgtitle(['Mohammed Adnan Hussain: ', scenario_name, ' Analysis'], 'FontSize', 16, 'FontWeight', 'bold');

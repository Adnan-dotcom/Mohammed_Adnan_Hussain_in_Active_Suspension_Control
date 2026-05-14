%% ULTIMATE Active Suspension: Analysis & Animation (Reverted & Upgraded)
% Features: 1-2-3 Menu, Live Animation, 6-Graph Analysis, LQR Optimal Control
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

%% 2. System Definition & LQR Design
m = 1.0; c = 3.0; k = 2.0;
A = [0 1; -k/m -c/m]; B = [0; 1/m]; C = [1 0]; D = 0;
sys_ss = ss(A, B, C, D);

% LQR Design (The "Pro" Math)
Q = [500 0; 0 10]; R = 0.01;
try
    [K_lqr] = lqr(A, B, Q, R);
    sys_lqr = feedback(sys_ss, K_lqr);
    has_lqr = true;
catch
    has_lqr = false;
end

% PID Controllers
sys_comf = feedback(tf([8 15], [1]) * tf(1, [m c k]), 1);
sys_sport = feedback(tf([15 100], [1]) * tf(1, [m c k]), 1);
sys_bal = feedback(tf([5 30], [1]) * tf(1, [m c k]), 1);

%% 3. Generate Simulation Data
t = 0:0.02:5;
if choice == 1
    u_road = ones(size(t)); scenario_name = 'The Pothole';
elseif choice == 2
    u_road = (t >= 1 & t <= 2); scenario_name = 'The Speed Table';
else
    u_road = cumsum(randn(size(t))*0.1); u_road = u_road - mean(u_road);
    scenario_name = 'Random Rough Road';
end

[y_bal] = lsim(sys_bal, u_road, t);

%% 4. LIVE ANIMATION
fig = figure('Color', 'k', 'Position', [100 100 800 400], 'Name', 'Live Suspension Animation');

for i = 1:length(t)
    if ~ishandle(fig); break; end
    clf; hold on; axis off;
    set(gca, 'Color', 'k', 'XLim', [2 8], 'YLim', [-1 3]);
    
    % Road
    plot([2 8], [0 0], 'w', 'LineWidth', 2);
    current_u = u_road(i);
    plot(linspace(2,8,50), ones(1,50)*current_u, 'w', 'LineWidth', 1);
    
    % Car Model (Improved)
    cy = y_bal(i) + 0.8;
    fill([4.2 5.8 5.7 4.3], [cy cy cy+0.6 cy+0.6], [0 0.5 1], 'EdgeColor', 'w'); % Body
    fill([4.5 5.5 5.4 4.6], [cy+0.3 cy+0.3 cy+0.55 cy+0.55], [0.8 0.9 1], 'FaceAlpha', 0.5); % Window
    
    % Wheels
    th = linspace(0, 2*pi, 20);
    plot(4.5 + 0.2*cos(th), cy - 0.2 + 0.2*sin(th), 'w', 'LineWidth', 2);
    plot(5.5 + 0.2*cos(th), cy - 0.2 + 0.2*sin(th), 'w', 'LineWidth', 2);
    
    % Spring
    plot([5 5], [current_u cy], 'y', 'LineWidth', 2);
    
    title(['Live Simulation: ', scenario_name], 'Color', 'w', 'FontSize', 14);
    text(2.2, 2.5, sprintf('Time: %.2fs', t(i)), 'Color', 'w');
    drawnow; pause(0.01);
end

%% 5. THE 6-GRAPH PERFORMANCE DASHBOARD
figure('Color', 'w', 'Position', [150 150 1200 800], 'Name', 'Engineering Performance Dashboard');

subplot(3,2,1); step(sys_comf, 'g', sys_sport, 'b', 5); grid on; title('A. Comfort vs Sport');
subplot(3,2,2); 
if has_lqr; step(sys_bal, 'k', sys_lqr, 'm', 5); title('B. PID vs LQR (Optimal Control)'); legend('PID', 'LQR');
else; step(sys_bal, 'k', 5); title('B. Balanced System Response'); end; grid on;

subplot(3,2,3); plot(t, u_road, 'k--', t, y_bal, 'm', 'LineWidth', 2); grid on; title(['C. ', scenario_name, ' Response']);
subplot(3,2,4); step(feedback(tf([5 30], [1]), tf(1, [m c k])), 'k', 5); yline(80, 'r--'); grid on; title('D. Control Effort');
subplot(3,2,5); bode(sys_bal); grid on; title('E. Frequency Response');
subplot(3,2,6); i_c = stepinfo(sys_comf); i_s = stepinfo(sys_sport); 
bar([i_c.SettlingTime, i_s.SettlingTime]); set(gca, 'XTickLabel', {'Comfort', 'Sport'}); ylabel('Seconds'); title('F. Settling Time Comparison');

sgtitle(['Mohammed Adnan Hussain: ', scenario_name, ' Analysis'], 'FontSize', 16, 'FontWeight', 'bold');

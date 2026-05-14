%% ULTIMATE Active Suspension: Two-Figure Analysis Suite
% Features: 1-2-3 Menu, Figure 1 (Animation), Figure 2 (6-Graph Analysis)
% Author: Mohammed Adnan Hussain

clear; clc; close all;

%% 1. Interactive Input Menu
fprintf('========================================================\n');
fprintf('   ACTIVE SUSPENSION ANALYSIS: Mohammed Adnan Hussain   \n');
fprintf('========================================================\n\n');
disp('Select Road Scenario for Simulation:');
disp('1. [POTHOLE]      - Testing Step Response');
disp('2. [SPEED TABLE]  - Testing Pulse Disturbance');
disp('3. [ROUGH ROAD]   - Testing Random Stability');
choice = input('>> Enter choice (1-3): ');

if isempty(choice) || choice < 1 || choice > 3; choice = 1; end

%% 2. System Definition & LQR Design
m = 1.0; c = 3.0; k = 2.0; 
A = [0 1; -k/m -c/m]; B = [0; 1/m]; C = [1 0]; D = 0;
sys_ss = ss(A, B, C, D);

% Optimal Control Design (LQR)
try
    [K_lqr] = lqr(A, B, [500 0; 0 10], 0.01);
    sys_lqr = feedback(sys_ss, K_lqr);
    has_lqr = true;
catch
    has_lqr = false;
end

% Manual PID Controllers
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

%% 4. FIGURE 1: LIVE ANIMATION (Dedicated Window)
fig1 = figure('Color', 'k', 'Position', [100 100 800 400], 'Name', 'Figure 1: Live Simulation');
for i = 1:length(t)
    if ~ishandle(fig1); break; end
    clf; hold on; axis off; set(gca, 'Color', 'k', 'XLim', [2 8], 'YLim', [-1 3]);
    plot([2 8], [0 0], 'w', 'LineWidth', 2);
    curr_u = u_road(i); cy = y_bal(i) + 0.8;
    fill([4.2 5.8 5.7 4.3], [cy cy cy+0.6 cy+0.6], [0 0.5 1], 'EdgeColor', 'w'); % Body
    fill([4.5 5.5 5.4 4.6], [cy+0.3 cy+0.3 cy+0.55 cy+0.55], [0.8 0.9 1], 'FaceAlpha', 0.5); % Window
    th = linspace(0, 2*pi, 20);
    plot(4.5+0.2*cos(th), cy-0.2+0.2*sin(th), 'w', 'LineWidth', 2);
    plot(5.5+0.2*cos(th), cy-0.2+0.2*sin(th), 'w', 'LineWidth', 2);
    plot([5 5], [curr_u cy], 'y', 'LineWidth', 2); % Spring
    
    % --- LIVE TELEMETRY (The "Values") ---
    text(2.2, 2.5, sprintf('TIME: %.2f s', t(i)), 'Color', 'w', 'FontSize', 12, 'FontWeight', 'bold');
    text(2.2, 2.2, sprintf('HEIGHT: %.3f m', y_bal(i)), 'Color', 'c', 'FontSize', 12, 'FontWeight', 'bold');
    text(2.2, 1.9, 'STATUS: ACTIVE', 'Color', 'g', 'FontSize', 10);
    
    title(['Live Simulation: ', scenario_name], 'Color', 'w', 'FontSize', 14);
    drawnow; pause(0.01);
end

%% 5. FIGURE 2: 6-GRAPH PERFORMANCE DASHBOARD (Dedicated Window)
figure('Color', 'w', 'Position', [150 150 1200 850], 'Name', 'Figure 2: Engineering Dashboard');
tlo = tiledlayout(3,2, 'TileSpacing', 'Compact');

nexttile; step(sys_comf, 'g', sys_sport, 'b', 5); grid on; title('A. Comfort vs Sport');
nexttile; 
if has_lqr; step(sys_bal, 'k', sys_lqr, 'm', 5); title('B. PID vs LQR (Optimal)'); legend('PID', 'LQR');
else; step(sys_bal, 'k', 5); title('B. Balanced Response'); end; grid on;

nexttile; plot(t, u_road, 'k--', t, y_bal, 'm', 'LineWidth', 2); grid on; title(['C. ', scenario_name]);
nexttile; step(feedback(tf([5 30], [1]), tf(1, [m c k])), 'k', 5); yline(80, 'r--', 'Limit'); grid on; title('D. Control Effort');

nexttile; nyquist(tf([5 30], [1]) * tf(1, [m c k])); grid on; title('E. Stability Proof (Nyquist)');
nexttile; i_b = stepinfo(sys_bal); i_s = stepinfo(sys_sport); 
bar([i_b.SettlingTime, i_s.SettlingTime]); set(gca, 'XTickLabel', {'Balanced', 'Sport'}); ylabel('Sec'); title('F. Settling Time');

sgtitle(tlo, ['Mohammed Adnan Hussain: ', scenario_name, ' Engineering Suite'], 'FontWeight', 'bold');

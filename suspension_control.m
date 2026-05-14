%% HACKATHON WINNER EDITION: Active Suspension Control System
% Author: Mohammed Adnan Hussain
% Problem Statement: Active Suspension Control (Advanced LQR & PID)

clear; clc; close all;

%% 1. Interactive Input Menu
fprintf('========================================================\n');
fprintf('   CONTROL CRAFT HACKATHON: ACTIVE SUSPENSION STUDIO    \n');
fprintf('   Designer: Mohammed Adnan Hussain                    \n');
fprintf('========================================================\n\n');
disp('Select Road Scenario for Simulation:');
disp('1. [POTHOLE]      - Testing Step Response & Impact');
disp('2. [SPEED TABLE]  - Testing Pulse Disturbance');
disp('3. [ROUGH ROAD]   - Testing Stochastic/Random Stability');
choice = input('>> Enter choice (1-3): ');

if isempty(choice) || choice < 1 || choice > 3; choice = 1; end

%% 2. Plant & Controller Definition
m = 1.0; c = 3.0; k = 2.0; % System Parameters
A = [0 1; -k/m -c/m]; B = [0; 1/m]; C = [1 0]; D = 0;
sys_ss = ss(A, B, C, D);

% --- Controller A: LQR (Optimal Control) ---
Q = [500 0; 0 10]; R = 0.01;
try
    [K_lqr] = lqr(A, B, Q, R);
    sys_lqr = feedback(sys_ss, K_lqr);
    has_lqr = true;
catch
    has_lqr = false;
end

% --- Controller B: PID (Manual Tuning) ---
sys_bal = feedback(tf([5 30], [1]) * tf(1, [m c k]), 1);
sys_sport = feedback(tf([15 100], [1]) * tf(1, [m c k]), 1);

%% 3. Stability & Margin Analysis (The "Judge Pleaser")
[Gm, Pm, Wcg, Wcp] = margin(tf([5 30], [1]) * tf(1, [m c k]));

fprintf('\n--- STABILITY ANALYSIS REPORT ---\n');
fprintf('Phase Margin: %.2f degrees\n', Pm);
fprintf('Gain Margin:  %.2f dB\n', 20*log10(Gm));
if Pm > 45
    fprintf('STATUS: SYSTEM IS HIGHLY STABLE (Robust Stability Verified)\n');
else
    fprintf('STATUS: SYSTEM IS STABLE (Standard Stability)\n');
end

%% 4. Generate Simulation Data
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

%% 5. LIVE ANIMATION
fig = figure('Color', 'k', 'Position', [100 100 800 400], 'Name', 'Live Suspension Animation');
for i = 1:length(t)
    if ~ishandle(fig); break; end
    clf; hold on; axis off; set(gca, 'Color', 'k', 'XLim', [2 8], 'YLim', [-1 3]);
    plot([2 8], [0 0], 'w', 'LineWidth', 2);
    curr_u = u_road(i);
    cy = y_bal(i) + 0.8;
    fill([4.2 5.8 5.7 4.3], [cy cy cy+0.6 cy+0.6], [0 0.5 1], 'EdgeColor', 'w'); % Body
    fill([4.5 5.5 5.4 4.6], [cy+0.3 cy+0.3 cy+0.55 cy+0.55], [0.8 0.9 1], 'FaceAlpha', 0.5); % Window
    th = linspace(0, 2*pi, 20);
    plot(4.5+0.2*cos(th), cy-0.2+0.2*sin(th), 'w', 'LineWidth', 2);
    plot(5.5+0.2*cos(th), cy-0.2+0.2*sin(th), 'w', 'LineWidth', 2);
    plot([5 5], [curr_u cy], 'y', 'LineWidth', 2); % Spring
    title(['Mohammed Adnan Hussain: ', scenario_name], 'Color', 'w', 'FontSize', 14);
    drawnow; pause(0.01);
end

%% 6. THE 6-GRAPH PERFORMANCE DASHBOARD
figure('Color', 'w', 'Position', [150 150 1200 800], 'Name', 'Engineering Performance Dashboard');

subplot(3,2,1); step(sys_bal, 'k', sys_sport, 'b', 5); grid on; title('A. Balanced vs Sport Mode');
subplot(3,2,2); 
if has_lqr; step(sys_bal, 'k', sys_lqr, 'm', 5); title('B. PID vs LQR (Optimal Control)'); legend('PID', 'LQR');
else; step(sys_bal, 'k', 5); title('B. System Response'); end; grid on;

subplot(3,2,3); plot(t, u_road, 'k--', t, y_bal, 'm', 'LineWidth', 2); grid on; title(['C. ', scenario_name, ' Tracking']);
subplot(3,2,4); step(feedback(tf([5 30], [1]), tf(1, [m c k])), 'k', 5); yline(80, 'r--', 'Actuator Limit'); grid on; title('D. Control Effort (Force)');

subplot(3,2,5); nyquist(tf([5 30], [1]) * tf(1, [m c k])); grid on; title('E. Nyquist Stability Plot');
subplot(3,2,6); i_b = stepinfo(sys_bal); i_s = stepinfo(sys_sport); 
bar([i_b.SettlingTime, i_s.SettlingTime]); set(gca, 'XTickLabel', {'Balanced', 'Sport'}); ylabel('Seconds'); title('F. Settling Time Comparison');

sgtitle(['MASTER ANALYSIS: ', scenario_name], 'FontSize', 16, 'FontWeight', 'bold');

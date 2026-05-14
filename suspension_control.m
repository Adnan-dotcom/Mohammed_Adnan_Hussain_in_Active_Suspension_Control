%% Advanced Active Suspension: Robustness & Trade-off Analysis
% Features: Multi-mode control, Passenger Weight Robustness, Control Effort
% Goal: Demonstrate engineering-grade sensitivity and performance analysis

clear; clc; close all;

%% 1. System Definition (Mass-Spring-Damper)
% Nominal Plant: G(s) = 1 / (ms^2 + cs + k) -> m=1, c=3, k=2
m_nom = 1.0; c = 3; k = 2;
G_nom = tf(1, [m_nom c k]);

% Robustness Scenario: +20% Mass (Passenger Weight)
% Simulates the effect of three heavy passengers on controller performance
m_heavy = 1.2;
G_heavy = tf(1, [m_heavy c k]);

%% 2. Controller Designs
% Mode A: Comfort (Lower gains, smooth response, higher damping)
Kp_comf = 15; Kd_comf = 8;
C_comfort = tf([Kd_comf Kp_comf], [1]);

% Mode B: Sport (High gains, aggressive response, fast settling)
Kp_sport = 100; Kd_sport = 15;
C_sport = tf([Kd_sport Kp_sport], [1]);

% Mode C: Balanced (Original Design)
Kp_bal = 30; Kd_bal = 5;
C_balanced = tf([Kd_bal Kp_bal], [1]);

%% 3. Closed-Loop System Simulations
t = 0:0.01:5;

% Comfort Mode Performance
sys_comfort = feedback(C_comfort * G_nom, 1);

% Sport Mode Performance
sys_sport = feedback(C_sport * G_nom, 1);

% Robustness Test: Balanced Mode on Nominal vs Heavy Car
sys_bal_nom = feedback(C_balanced * G_nom, 1);
sys_bal_heavy = feedback(C_balanced * G_heavy, 1);

% Control Effort Systems (Transfer function from Ref Input to Control Signal U)
% Tu = C / (1 + CG)
Tu_comfort = feedback(C_comfort, G_nom);
Tu_sport = feedback(C_sport, G_nom);
Tu_bal = feedback(C_balanced, G_nom);

%% 4. Visualization & Professional Comparison
figure('Color', 'w', 'Position', [100 100 1100 800]);

% --- Plot 1: Performance Trade-off (Comfort vs Sport) ---
subplot(2,2,1);
hold on; grid on;
[y_c, t_c] = step(sys_comfort, t);
[y_s, t_s] = step(sys_sport, t);
plot(t_c, y_c, 'Color', [0.4660 0.6740 0.1880], 'LineWidth', 2.5); % Green
plot(t_s, y_s, 'Color', [0 0.4470 0.7410], 'LineWidth', 2.5);   % Blue
title('A. Comfort vs. Sport Response', 'FontSize', 12);
ylabel('Body Displacement (m)');
legend('Comfort Mode (Soft)', 'Sport Mode (Stiff)', 'Location', 'SouthEast');
ylim([0 1.5]);

% --- Plot 2: Robustness Test (The Passenger Effect) ---
subplot(2,2,2);
hold on; grid on;
[y_nom, t_nom] = step(sys_bal_nom, t);
[y_heavy, t_heavy] = step(sys_bal_heavy, t);
plot(t_nom, y_nom, 'k', 'LineWidth', 2);
plot(t_heavy, y_heavy, 'r--', 'LineWidth', 2.5);
title('B. Robustness Test: Extra Weight (+20% Mass)', 'FontSize', 12);
ylabel('Body Displacement (m)');
legend('Nominal Car', 'Fully Loaded Car', 'Location', 'SouthEast');
ylim([0 1.5]);

% --- Plot 3: Actuator Control Effort (Realism Check) ---
subplot(2,2,3);
hold on; grid on;
[u_c, tu_c] = step(Tu_comfort, t);
[u_s, tu_s] = step(Tu_sport, t);
[u_b, tu_b] = step(Tu_bal, t);
plot(tu_c, u_c, 'Color', [0.4660 0.6740 0.1880], 'LineWidth', 2);
plot(tu_s, u_s, 'Color', [0 0.4470 0.7410], 'LineWidth', 2);
plot(tu_b, u_b, 'k:', 'LineWidth', 2);
% Saturation limit line
yline(80, 'r--', 'Actuator Limit', 'LineWidth', 1.5, 'LabelHorizontalAlignment','left');
title('C. Actuator Control Effort (Required Force)', 'FontSize', 12);
ylabel('Control Signal (u)');
xlabel('Time (s)');
legend('Comfort Effort', 'Sport Effort', 'Balanced Effort');

% --- Plot 4: KPI Summary (The "Engineer's Dashboard") ---
subplot(2,2,4);
info_c = stepinfo(sys_comfort);
info_s = stepinfo(sys_sport);
info_n = stepinfo(sys_bal_nom);
info_h = stepinfo(sys_bal_heavy);
bars = [info_c.SettlingTime, info_s.SettlingTime, info_h.SettlingTime];
b = bar(bars, 'FaceColor', 'flat');
b.CData(1,:) = [0.4660 0.6740 0.1880];
b.CData(2,:) = [0 0.4470 0.7410];
b.CData(3,:) = [0.8500 0.3250 0.0980];
set(gca, 'XTickLabel', {'Comfort', 'Sport', 'Heavy (Bal)'});
title('D. Settling Time Comparison', 'FontSize', 12);
ylabel('Time (Seconds)');
grid on;

sgtitle('Advanced Performance Analysis: Active Suspension Control', 'FontSize', 16, 'FontWeight', 'bold');

%% 5. Conclusion Printout
fprintf('--- Simulation Summary ---\n');
fprintf('Sport Mode Settling Time: %.2f s (Fastest)\n', info_s.SettlingTime);
fprintf('Comfort Mode Overshoot: %.2f %% (Smoothest)\n', info_c.Overshoot);
fprintf('Robustness Test: Settling time increased by %.1f%% with extra weight.\n', ...
    (info_h.SettlingTime - info_n.SettlingTime)/info_n.SettlingTime * 100);

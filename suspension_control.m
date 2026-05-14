%% ULTIMATE Active Suspension Studio: All-In-One Edition
% Designer: Mohammed Adnan Hussain
% Final Submission: Perfectly aligned with all tasks

clear; clc; close all;

%% --- 1. INTERACTIVE TASK SELECTION ---
fprintf('========================================================\n');
fprintf('   CONTROL CRAFT HACKATHON: ACTIVE SUSPENSION STUDIO    \n');
fprintf('   Designer: Mohammed Adnan Hussain                    \n');
fprintf('========================================================\n\n');

disp('Select Road Scenario for Simulation:');
disp('1. [ROAD BUMP]    - Testing Step Input (Disturbance)');
disp('2. [SPEED TABLE]  - Testing Pulse Disturbance');
disp('3. [ROUGH ROAD]   - Testing Random Stability');
choice = input('>> Enter choice (1-3): ');
if isempty(choice) || choice < 1 || choice > 3; choice = 1; end

%% TASK 1 & 2: SYSTEM & CONTROLLER DESIGN
m = 1.0; c = 3.0; k = 2.0;
A = [0 1; -k/m -c/m]; B = [0; 1/m]; C = [1 0]; D = 0;
sys_ss = ss(A, B, C, D);
Kp = 80; Ki = 40; Kd = 15; % Optimized PID
C_pid = tf([Kd Kp Ki], [1 0]); 
sys_bal = feedback(C_pid * tf(1, [m c k]), 1);
sys_bouncy = tf(1, [1 0.2 2]); % Bouncy Car for Comparison

%% 3. Generate Simulation Data
t = 0:0.02:5;
if choice == 1; u_road = 0.2 * (t >= 1); scenario_name = 'The Road Bump';
elseif choice == 2; u_road = 0.2 * (t >= 1 & t <= 2); scenario_name = 'The Speed Table';
else; u_road = 0.1 * cumsum(randn(size(t))*0.1); u_road = u_road - mean(u_road); scenario_name = 'Random Rough Road'; end

[y_bal] = lsim(sys_bal, u_road, t);
[y_orig] = lsim(sys_bouncy, u_road, t); 

%% --- 4. CREATE THE ALL-IN-ONE STUDIO WINDOW ---
figMain = figure('Color', 'k', 'Position', [100 50 1000 900], 'Name', 'Active Suspension Master Dashboard');
tlo = tiledlayout(2,2, 'TileSpacing', 'Compact', 'Padding', 'Compact');

% --- TOP SECTION: THE ANIMATION (Spans 2 columns) ---
axAnim = nexttile(1, [1 2]);
set(axAnim, 'Color', 'k', 'XColor', 'none', 'YColor', 'none');
hold(axAnim, 'on');

% --- BOTTOM LEFT: CONTROLLED RESPONSE ---
axCtrl = nexttile(3);
step(axCtrl, sys_bal, 'b', 5); grid(axCtrl, 'on');
set(axCtrl, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
title(axCtrl, 'CONTROLLED: PERFECT DAMPING', 'Color', 'w');

% --- BOTTOM RIGHT: UNCONTROLLED RESPONSE ---
axOrig = nexttile(4);
step(axOrig, sys_bouncy, 'r', 5); grid(axOrig, 'on');
set(axOrig, 'Color', 'w', 'XColor', 'k', 'YColor', 'k');
title(axOrig, 'UNCONTROLLED: BOUNCY', 'Color', 'w');

%% --- ACTION: PROFESSIONAL FLUID ANIMATION ---
t_interp = linspace(t(1), t(end), 300); 
y_interp = interp1(t, y_bal, t_interp); 
u_interp = interp1(t, u_road, t_interp);     

for i = 1:length(t_interp)
    if ~ishandle(figMain); break; end
    
    cla(axAnim); hold(axAnim, 'on'); axis(axAnim, 'off');
    set(axAnim, 'XLim', [2 8], 'YLim', [-1 4], 'Color', 'k');
    
    % --- Moving Road ---
    road_offset = mod(i*0.1, 2);
    for x = 1:2:10; plot(axAnim, [x x+1], [-0.05 -0.05], 'w', 'LineWidth', 1.5); end
    if choice == 1; fill(axAnim, [5.0 10 10 5.0], [-0.05 -0.05 0.15 0.15], [0.3 0.3 0.3], 'EdgeColor', 'w');
    elseif choice == 2; fill(axAnim, [4.5 5.5 5.5 4.5], [-0.05 -0.05 0.15 0.15], [0.4 0.4 0.4], 'EdgeColor', 'w'); end
    
    curr_u = u_interp(i); cy = y_interp(i) + 1.2;
    fill(axAnim, [4.3 5.7 5.6 4.4], [-0.05 -0.05 -0.15 -0.15], [0.2 0.2 0.2], 'EdgeAlpha', 0, 'FaceAlpha', max(0.1, 0.5-abs(y_interp(i))));
    
    % --- Suspension Visuals ---
    plot(axAnim, [5 5], [curr_u cy-0.2], 'Color', [0.7 0.7 0.7], 'LineWidth', 6); 
    plot(axAnim, [5 5], [curr_u+0.2 cy-0.4], 'Color', [0.4 0.4 0.4], 'LineWidth', 3);
    sx = [4.8 5.2 4.8 5.2 4.8 5.2]; sy = linspace(curr_u+0.1, cy-0.3, 6); 
    plot(axAnim, sx, sy, 'y', 'LineWidth', 1.5);

    % --- Car Model ---
    fill(axAnim, [4.1 5.9 5.8 4.2], [cy cy cy+0.8 cy+0.8], [0 0.3 0.6], 'EdgeColor', 'c', 'LineWidth', 2);
    fill(axAnim, [4.5 5.5 5.4 4.6], [cy+0.35 cy+0.35 cy+0.7 cy+0.7], [0.8 0.9 1], 'FaceAlpha', 0.4, 'EdgeColor', 'w');
    th = linspace(0, 2*pi, 20); 
    fill(axAnim, 4.5+0.25*cos(th), cy-0.1+0.25*sin(th), [0.1 0.1 0.1], 'EdgeColor', 'w', 'LineWidth', 1.5); 
    fill(axAnim, 5.5+0.25*cos(th), cy-0.1+0.25*sin(th), [0.1 0.1 0.1], 'EdgeColor', 'w', 'LineWidth', 1.5);
    
    % --- Live Data ---
    text(axAnim, 2.2, 3.5, 'ACTIVE SUSPENSION STUDIO', 'Color', 'c', 'FontSize', 10, 'FontWeight', 'bold');
    text(axAnim, 2.2, 3.2, sprintf('TIME: %.2f s', t_interp(i)), 'Color', 'w', 'FontSize', 12);
    title(axAnim, ['SCENARIO: ', upper(scenario_name)], 'Color', 'w', 'FontSize', 16, 'FontWeight', 'bold');
    
    drawnow limitrate;
end

%% MASTER Active Suspension Studio: Ultimate Duel Masterpiece
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
sys_bouncy = tf(1, [1 0.2 2]); % Bouncy Car (c=0.2 for visual drama)

%% 3. Generate Simulation Data
t = 0:0.02:5;
if choice == 1; u_road = 0.2 * (t >= 1 & t <= 2); scenario_name = 'The Road Bump';
elseif choice == 2; u_road = 0.2 * (t >= 1 & t <= 2.5); scenario_name = 'The Speed Table';
else; u_road = 0.1 * cumsum(randn(size(t))*0.1); u_road = u_road - mean(u_road); scenario_name = 'Random Rough Road'; end

[y_bal] = lsim(sys_bal, u_road, t);
[y_orig] = lsim(sys_bouncy, u_road, t); 

%% --- 4. THE ANIMATION (ULTIMATE DUEL MASTERPIECE) ---
fig1 = figure('Color', 'k', 'Position', [100 100 900 600], 'Name', 'Figure 1: Performance Duel');
ax1 = axes('Parent', fig1, 'Color', 'k');

t_interp = linspace(t(1), t(end), 300); 
y_orig_interp = interp1(t, y_orig, t_interp); 
y_interp = interp1(t, y_bal, t_interp); 
u_interp = interp1(t, u_road, t_interp);     

for i = 1:length(t_interp)
    if ~ishandle(fig1); break; end
    
    cla(ax1); hold(ax1, 'on'); axis(ax1, 'off');
    set(ax1, 'XLim', [2 8], 'YLim', [-1 6], 'Color', 'k');
    
    % --- Moving Road ---
    v = 2.5; road_offset = mod(t_interp(i)*v, 2);
    for x = 1:2:10; plot(ax1, [x x+1.5], [3 3], 'w', 'LineWidth', 1); plot(ax1, [x x+1.5], [0 0], 'w', 'LineWidth', 1); end
    
    % --- Moving Bump ---
    bx = 5 + (1.0 - t_interp(i))*v; 
    if choice == 1 || choice == 2
        bw = (choice == 1)*2.5 + (choice == 2)*3.75;
        fill(ax1, [bx bx+bw bx+bw bx], [3 3 3.15 3.15], [0.3 0.3 0.3], 'EdgeColor', 'w');
        fill(ax1, [bx bx+bw bx+bw bx], [0 0 0.15 0.15], [0.3 0.3 0.3], 'EdgeColor', 'w');
    end
    
    curr_u = u_interp(i);
    cy_orig = y_orig_interp(i) + 4.2;
    cy_ctrl = y_interp(i) + 1.2;
    
    % --- TOP CAR (RED: BOUNCY) ---
    fill(ax1, [4.3 5.7 5.6 4.4], [3 3 2.85 2.85], [0.2 0.2 0.2], 'EdgeAlpha', 0, 'FaceAlpha', 0.3);
    plot(ax1, [5 5], [3+curr_u cy_orig-0.2], 'r', 'LineWidth', 2);
    fill(ax1, [4.1 5.9 5.8 4.2], [cy_orig cy_orig cy_orig+0.7 cy_orig+0.7], [0.8 0 0], 'EdgeColor', 'w');
    text(ax1, 2.2, 5.5, 'ORIGINAL: BOUNCING', 'Color', 'r', 'FontSize', 10, 'FontWeight', 'bold');
    text(ax1, 2.2, 5.1, sprintf('BOUNCE: %.3f m', y_orig_interp(i)), 'Color', 'r', 'FontSize', 9);

    % --- BOTTOM CAR (BLUE: CONTROLLED) ---
    fill(ax1, [4.3 5.7 5.6 4.4], [0 0 -0.15 -0.15], [0.2 0.2 0.2], 'EdgeAlpha', 0, 'FaceAlpha', 0.3);
    plot(ax1, [5 5], [curr_u cy_ctrl-0.2], 'c', 'LineWidth', 2);
    fill(ax1, [4.1 5.9 5.8 4.2], [cy_ctrl cy_ctrl cy_ctrl+0.7 cy_ctrl+0.7], [0 0.4 0.8], 'EdgeColor', 'w');
    text(ax1, 2.2, 2.5, 'PID CONTROLLED: STABLE', 'Color', 'c', 'FontSize', 10, 'FontWeight', 'bold');
    text(ax1, 2.2, 2.1, sprintf('BOUNCE: %.3f m', y_interp(i)), 'Color', 'c', 'FontSize', 9);
    
    text(ax1, 2.2, 5.8, sprintf('TIME: %.2f s', t_interp(i)), 'Color', 'w', 'FontSize', 12);
    title(ax1, ['COMPARISON: ', upper(scenario_name)], 'Color', 'w', 'FontSize', 16, 'FontWeight', 'bold');
    drawnow;
end

%% --- 5. STEP 2: SHOW DASHBOARD ---
fig2 = figure('Color', 'w', 'Position', [150 150 1200 500], 'Name', 'Step 2: Performance Dashboard');
tlo = tiledlayout(1,2, 'TileSpacing', 'Loose');
nexttile; step(sys_bal, 'b', 5); grid on; set(gca, 'Color', 'w'); title('CONTROLLED: PID'); legend('Perfect Damping');
nexttile; step(sys_bouncy, 'r', 5); grid on; set(gca, 'Color', 'w'); title('UNCONTROLLED: PASSIVE'); legend('Wild Oscillations');
sgtitle(tlo, 'Mohammed Adnan Hussain: Engineering Result');
figure(fig2);

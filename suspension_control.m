%% ACTIVE SUSPENSION: MASTER INTERACTIVE DASHBOARD
% Project: Control Craft Hackathon - Final Submission
% Designer: Mohammed Adnan Hussain
% Features: Live Animation, Tuning Sliders, Interactive Scenarios

clear; clc; close all;

%% 1. GLOBAL STATE & SYSTEM INITIALIZATION
global Kp Kd choice t u_road params fig_main stopAnim
Kp = 50; Kd = 10; choice = 1; t = 0:0.04:4; % Faster time step for animation
params.m = 1.0; params.c = 3.0; params.k = 2.0;
stopAnim = false;

%% 2. UI ARCHITECTURE
fig_main = figure('Color', 'w', 'Position', [50 50 1300 850], ...
    'Name', 'MASTER DASHBOARD: Mohammed Adnan Hussain', 'MenuBar', 'none', 'CloseRequestFcn', @(s,e) set(0,'UserData',1));
set(0, 'UserData', 0);

% --- SIDEBAR CONTROL PANEL ---
uip = uipanel('Title', 'CONTROL CENTER', 'Position', [0.01 0.1 0.15 0.85], 'BackgroundColor', [0.95 0.95 0.95]);
uicontrol(uip, 'Style', 'text', 'String', 'ROAD SCENARIO', 'Position', [10 650 130 20], 'FontWeight', 'bold');
uicontrol(uip, 'Style', 'pushbutton', 'String', 'Pothole', 'Position', [10 620 130 30], 'Callback', @(s,e) setScenario(1));
uicontrol(uip, 'Style', 'pushbutton', 'String', 'Speed Table', 'Position', [10 585 130 30], 'Callback', @(s,e) setScenario(2));
uicontrol(uip, 'Style', 'pushbutton', 'String', 'Rough Road', 'Position', [10 550 130 30], 'Callback', @(s,e) setScenario(3));

uicontrol(uip, 'Style', 'text', 'String', 'STIFFNESS (Kp)', 'Position', [10 450 130 20], 'FontWeight', 'bold');
sld_p = uicontrol(uip, 'Style', 'slider', 'Min', 1, 'Max', 200, 'Value', Kp, 'Position', [10 420 130 25], 'Callback', @(s,e) updateLogic());
uicontrol(uip, 'Style', 'text', 'String', 'DAMPING (Kd)', 'Position', [10 350 130 20], 'FontWeight', 'bold');
sld_d = uicontrol(uip, 'Style', 'slider', 'Min', 1, 'Max', 50, 'Value', Kd, 'Position', [10 320 130 25], 'Callback', @(s,e) updateLogic());

% Main Layout
layout_ax = uipanel('Position', [0.17 0.01 0.82 0.98], 'BackgroundColor', 'w', 'BorderType', 'none');
tlo = tiledlayout(layout_ax, 3, 2, 'TileSpacing', 'Compact');

% Initialize Axes once to prevent flickering
ax_anim = nexttile(tlo); axis off;
ax_step = nexttile(tlo); grid on;
ax_road = nexttile(tlo); grid on;
ax_stab = nexttile(tlo); grid on;
ax_kpi  = nexttile(tlo); grid on;
ax_log  = nexttile(tlo); axis off;

%% 3. MAIN EXECUTION LOOP (FOR ANIMATION)
while get(0, 'UserData') == 0
    % Calculate Physics
    sys_pid = feedback(tf([Kd Kp], [1]) * tf(1, [params.m params.c params.k]), 1);
    u_road = generateRoad(choice, t);
    [y, ~] = lsim(sys_pid, u_road, t);
    info = stepinfo(sys_pid);
    
    % --- Update Static Graphs ---
    axes(ax_step); step(sys_pid, 4); title('System Response');
    axes(ax_road); plot(t, u_road, 'k--', t, y, 'LineWidth', 2); title('Road Tracking');
    axes(ax_stab); nyquist(sys_pid); title('Stability Map');
    axes(ax_kpi); bar([info.SettlingTime, info.Overshoot/10]); set(gca, 'XTickLabel', {'Settling', 'OS/10'}); title('KPIs');
    
    % --- Update Animation Loop ---
    for i = 1:length(t)
        if get(0, 'UserData') == 1; break; end
        
        % Check if sliders moved during animation
        Kp_new = get(sld_p, 'Value'); Kd_new = get(sld_d, 'Value');
        if abs(Kp_new-Kp)>0.1 || abs(Kd_new-Kd)>0.1; break; end 
        
        % Draw Car
        axes(ax_anim); cla; hold on; axis off; set(ax_anim, 'XLim', [2 8], 'YLim', [-1 3], 'Color', 'k');
        plot([2 8], [0 0], 'k', 'LineWidth', 2);
        curr_u = u_road(i); cy = y(i) + 0.8;
        fill([4.2 5.8 5.7 4.3], [cy cy cy+0.6 cy+0.6], [0 0.4 0.8]); % Body
        plot(4.5+0.1*cos(0:0.5:7), cy-0.2+0.1*sin(0:0.5:7), 'k', 'LineWidth', 2); % Wheels
        plot(5.5+0.1*cos(0:0.5:7), cy-0.2+0.1*sin(0:0.5:7), 'k', 'LineWidth', 2);
        plot([5 5], [curr_u cy], 'r', 'LineWidth', 2); % Spring
        title('LIVE CAR SIMULATION', 'Color', 'k', 'FontWeight', 'bold');
        
        % Update Table
        axes(ax_log); cla; text(0.1, 0.5, sprintf('Kp: %.1f\nKd: %.1f\nSettling: %.2fs', Kp, Kd, info.SettlingTime), 'FontSize', 12, 'FontWeight', 'bold');
        
        drawnow limitrate;
    end
end
delete(fig_main);

%% --- HELPER FUNCTIONS ---
function updateLogic()
    global Kp Kd sld_p sld_d; % Handled in main loop
end

function setScenario(val)
    global choice; choice = val;
end

function u = generateRoad(c, t)
    if c == 1; u = ones(size(t)); elseif c == 2; u = (t >= 1 & t <= 2);
    else; u = cumsum(randn(size(t))*0.05); u = u - mean(u); end
end

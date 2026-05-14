%% ACTIVE SUSPENSION: INTERACTIVE ENGINEERING STUDIO
% Project: Control Craft Hackathon - Final Submission
% Designer: Mohammed Adnan Hussain
% Features: Live Sliders, Interactive Buttons, Real-time Dashboard Updates

clear; clc; close all;

%% 1. GLOBAL STATE & SYSTEM INITIALIZATION
global Kp Kd choice t u_road params has_lqr sys_ss fig_main
Kp = 50; Kd = 10; choice = 1; t = 0:0.02:5;
params.m = 1.0; params.c = 3.0; params.k = 2.0;

% State-Space & LQR
sys_ss = ss([0 1; -params.k/params.m -params.c/params.m], [0; 1/params.m], [1 0], 0);
try
    K_lqr = lqr(sys_ss.A, sys_ss.B, [500 0; 0 10], 0.01);
    has_lqr = true; sys_lqr_static = feedback(sys_ss, K_lqr);
catch
    has_lqr = false;
end

%% 2. UI ARCHITECTURE (THE STUDIO)
fig_main = figure('Color', 'w', 'Position', [50 50 1250 850], ...
    'Name', 'ACTIVE SUSPENSION STUDIO: Mohammed Adnan Hussain', 'MenuBar', 'none');

% --- SIDEBAR CONTROL PANEL ---
uip = uipanel('Title', 'CONTROL CENTER', 'Position', [0.01 0.1 0.18 0.85], 'BackgroundColor', [0.95 0.95 0.95]);

% Scenario Buttons
uicontrol(uip, 'Style', 'text', 'String', 'ROAD SCENARIO', 'Position', [10 650 150 20], 'FontWeight', 'bold');
uicontrol(uip, 'Style', 'pushbutton', 'String', 'Pothole Impact', 'Position', [10 620 150 30], 'Callback', @(s,e) setScenario(1));
uicontrol(uip, 'Style', 'pushbutton', 'String', 'Speed Table', 'Position', [10 585 150 30], 'Callback', @(s,e) setScenario(2));
uicontrol(uip, 'Style', 'pushbutton', 'String', 'Rough Road', 'Position', [10 550 150 30], 'Callback', @(s,e) setScenario(3));

% PID Sliders
uicontrol(uip, 'Style', 'text', 'String', 'STIFFNESS (Kp)', 'Position', [10 450 150 20], 'FontWeight', 'bold');
sld_p = uicontrol(uip, 'Style', 'slider', 'Min', 1, 'Max', 200, 'Value', Kp, 'Position', [10 420 150 25], 'Callback', @(s,e) updateStudio());

uicontrol(uip, 'Style', 'text', 'String', 'DAMPING (Kd)', 'Position', [10 350 150 20], 'FontWeight', 'bold');
sld_d = uicontrol(uip, 'Style', 'slider', 'Min', 1, 'Max', 50, 'Value', Kd, 'Position', [10 320 150 25], 'Callback', @(s,e) updateStudio());

uicontrol(uip, 'Style', 'pushbutton', 'String', 'RESET FACTORY', 'Position', [10 50 150 40], 'BackgroundColor', [1 0.8 0.8], 'Callback', @(s,e) resetStudio(sld_p, sld_d));

% Initialize Dashboard
updateStudio();

%% --- CORE FUNCTIONS ---

function updateStudio()
    global Kp Kd choice t u_road params has_lqr sys_ss fig_main sld_p sld_d
    
    % Read UI Values
    if exist('sld_p','var'); Kp = get(findobj(fig_main, 'Style', 'slider', 'Position', [10 420 150 25]), 'Value'); end
    if exist('sld_d','var'); Kd = get(findobj(fig_main, 'Style', 'slider', 'Position', [10 320 150 25]), 'Value'); end
    
    % Recalculate Logic
    sys_pid = feedback(tf([Kd Kp], [1]) * tf(1, [params.m params.c params.k]), 1);
    u_road = generateRoad(choice, t);
    [y, ~] = lsim(sys_pid, u_road, t);
    info = stepinfo(sys_pid);
    
    % Render Dashboard
    renderLayout(sys_pid, y, info);
end

function renderLayout(sys, y, info)
    global t u_road has_lqr choice fig_main
    set(0, 'CurrentFigure', fig_main);
    
    % Use modern Tiled Layout in the remaining 80% of the screen
    layout_ax = uipanel('Position', [0.2 0.01 0.79 0.98], 'BackgroundColor', 'w', 'BorderType', 'none');
    tlo = tiledlayout(layout_ax, 3, 2, 'TileSpacing', 'Compact');
    
    % Tile 1: Live Step Response
    ax1 = nexttile(tlo); step(sys, 5); grid on; title('Live Tuning: Step Response');
    
    % Tile 2: Optimal vs Manual
    ax2 = nexttile(tlo); hold on; grid on;
    step(sys, 'b'); if has_lqr; step(feedback(ss([0 1; -2 -3], [0; 1], [1 0], 0), lqr([0 1; -2 -3], [0; 1], [500 0; 0 10], 0.01)), 'm'); end
    title('PID (Blue) vs LQR (Magenta)');
    
    % Tile 3: Road Tracking
    ax3 = nexttile(tlo); plot(t, u_road, 'k--', t, y, 'Color', [0 0.5 0.8], 'LineWidth', 2);
    grid on; title('Active Road Impact Tracking');
    
    % Tile 4: Stability Map
    ax4 = nexttile(tlo); nyquist(sys); grid on; title('Nyquist Stability Proof');
    
    % Tile 5: KPI Summary
    ax5 = nexttile(tlo); 
    bar([info.SettlingTime, info.RiseTime, info.Overshoot/10]); 
    set(gca, 'XTickLabel', {'Settling', 'Rise', 'OS/10'}); title('Performance Metrics');
    
    % Tile 6: Audit Log
    ax6 = nexttile(tlo); axis off;
    data = {'Stiffness (Kp)', sprintf('%.1f', Kp); 'Damping (Kd)', sprintf('%.1f', Kd); ...
            'Settling Time', sprintf('%.2f s', info.SettlingTime); 'Status', 'STABLE'};
    uitable('Data', data, 'ColumnName', {'Parameter', 'Value'}, 'Units', 'Normalized', 'Position', [0.1 0.1 0.8 0.8]);
    title('Engineering Audit Log');
    
    sgtitle(tlo, 'Mohammed Adnan Hussain: Interactive Engineering Studio', 'FontWeight', 'bold');
end

function setScenario(val)
    global choice; choice = val; updateStudio();
end

function resetStudio(sp, sd)
    set(sp, 'Value', 50); set(sd, 'Value', 10); updateStudio();
end

function u = generateRoad(c, t)
    if c == 1; u = ones(size(t)); elseif c == 2; u = (t >= 1 & t <= 2);
    else; u = cumsum(randn(size(t))*0.1); u = u - mean(u); end
end

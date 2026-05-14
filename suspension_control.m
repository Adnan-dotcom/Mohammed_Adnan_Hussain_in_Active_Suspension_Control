%% CONTROL CRAFT: MASTERPIECE EDITION (LQR + INTERACTIVE STUDIO)
% Author: Mohammed Adnan Hussain
% Features: LQR Optimal Control, State-Space Analysis, Interactive Live Tuning

clear; clc; close all;

%% 1. Advanced System Definition (State-Space)
% Plant: m*x'' + c*x' + k*x = u
m = 1.0; c = 3.0; k = 2.0;

% State-Space Representation: x = [pos; vel]
A = [0 1; -k/m -c/m];
B = [0; 1/m];
C = [1 0]; % We measure position
D = 0;
sys_ss = ss(A, B, C, D);

%% 2. LQR Optimal Controller Design
% J = integral(x'Qx + u'Ru)
Q = [500 0; 0 10]; % Penalize position error heavily
R = 0.01;          % Allow high control effort for "Sport" feel
try
    [K_lqr, ~, ~] = lqr(A, B, Q, R);
    sys_lqr = feedback(sys_ss, K_lqr);
    has_lqr = true;
catch
    has_lqr = false;
    disp('LQR Toolbox not found, using High-Performance PID instead.');
end

%% 3. Interactive Studio Setup
t = 0:0.02:10;
u_road = sin(t*2) .* exp(-0.2*t) + 0.5*randn(size(t)).*(t<2); % Complex road impact

% Global variables for live tuning
global Kp Kd
Kp = 50; Kd = 10;

fig = figure('Color', [0.1 0.1 0.1], 'Position', [50 50 1200 700], 'Name', 'CONTROL CRAFT: INTERACTIVE STUDIO');

% --- Create Sliders ---
uicontrol('Style', 'text', 'String', 'STIFFNESS (Kp)', 'Position', [20 350 100 20], 'ForegroundColor', 'w', 'BackgroundColor', [0.1 0.1 0.1]);
sld_p = uicontrol('Style', 'slider', 'Min', 1, 'Max', 200, 'Value', 50, 'Position', [20 100 30 250], 'Callback', @(src, event) update_p(src));

uicontrol('Style', 'text', 'String', 'DAMPING (Kd)', 'Position', [120 350 100 20], 'ForegroundColor', 'w', 'BackgroundColor', [0.1 0.1 0.1]);
sld_d = uicontrol('Style', 'slider', 'Min', 1, 'Max', 50, 'Value', 10, 'Position', [120 100 30 250], 'Callback', @(src, event) update_d(src));

% --- Animation & Plotting Axes ---
ax_sim = axes('Position', [0.25 0.55 0.7 0.4], 'Color', 'k');
ax_plot = axes('Position', [0.25 0.1 0.7 0.35], 'Color', [0.15 0.15 0.15], 'XColor', 'w', 'YColor', 'w');

%% 4. Live Execution Loop
while ishandle(fig)
    % Recalculate Controller with current Slider values
    C_pid = tf([Kd Kp], [1]);
    sys_pid = feedback(C_pid * tf(1, [m c k]), 1);
    
    [y_pid] = lsim(sys_pid, u_road, t);
    if has_lqr; [y_lqr] = step(sys_lqr, t); end
    
    % Animation Loop (Internal)
    for i = 1:5:length(t)
        if ~ishandle(fig); break; end
        
        % --- Update Animation ---
        axes(ax_sim); clf(ax_sim); hold on; axis off;
        set(ax_sim, 'Color', 'k', 'XLim', [2 8], 'YLim', [-1 4]);
        
        % Road
        plot([2 8], [0 0], 'w', 'LineWidth', 2);
        curr_u = u_road(i);
        plot([4 6], [curr_u curr_u], 'y', 'LineWidth', 3); % The Bump
        
        % Car Body (Masterpiece Model)
        cy = y_pid(i) + 1.2;
        % Body
        fill([4.1 5.9 5.8 4.2], [cy cy+0.7 cy+0.7 cy], [0 0.4 0.8], 'EdgeColor', 'c', 'LineWidth', 2);
        % Windows
        fill([4.4 5.6 5.5 4.5], [cy+0.3 cy+0.3 cy+0.6 cy+0.6], [0.8 0.9 1], 'FaceAlpha', 0.5);
        % Wheels
        th = linspace(0, 2*pi, 20);
        fill(4.5+0.25*cos(th), cy-0.2+0.25*sin(th), [0.3 0.3 0.3], 'EdgeColor', 'w');
        fill(5.5+0.25*cos(th), cy-0.2+0.25*sin(th), [0.3 0.3 0.3], 'EdgeColor', 'w');
        % Spring
        plot([5 5], [curr_u cy], 'y', 'LineWidth', 2);
        
        title('LIVE ACTIVE SUSPENSION STUDIO', 'Color', 'c', 'FontSize', 16);
        text(2.5, 3.5, sprintf('Kp: %.1f | Kd: %.1f', Kp, Kd), 'Color', 'w', 'FontSize', 12);
        
        % --- Update Performance Plot ---
        axes(ax_plot); hold off;
        plot(t, y_pid, 'c', 'LineWidth', 2); hold on;
        plot(t(i), y_pid(i), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
        grid on; ylabel('Displacement'); xlabel('Time (s)');
        title('Real-time Controller Response', 'Color', 'w');
        
        drawnow;
    end
    
    if ~ishandle(fig); break; end
    pause(0.1); % Small break before restarting loop
end

%% Helper Functions for Sliders
function update_p(hObj)
    global Kp
    Kp = get(hObj, 'Value');
end

function update_d(hObj)
    global Kd
    Kd = get(hObj, 'Value');
end

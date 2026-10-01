%% impedance_studies.m
% Fault impedance and grounding sensitivity studies

clear;
clc;
close all;

%% Load system parameters

net = parameters;

%% Build original sequence networks

[Y0,Y1,Y2,Z0,Z1,Z2] = build_networks(net);

%% General parameters

k = 3;                  % Fault at Bus 3
Vf = net.Vf;

%% =========================================================
% STUDY 1: Fault current versus fault impedance
% ==========================================================

% Fault impedance range
Zf_values = linspace(0,0.5,101);

I_3ph = zeros(size(Zf_values));
I_LG   = zeros(size(Zf_values));
I_LL   = zeros(size(Zf_values));
I_LLG  = zeros(size(Zf_values));

for n = 1:length(Zf_values)

    Zf = Zf_values(n);

    %% 3-phase

    r = fault_at_bus(k,'3ph',Z0,Z1,Z2,Vf,Zf);
    I_3ph(n) = max(abs(r.Iabc));

    %% LG

    r = fault_at_bus(k,'LG',Z0,Z1,Z2,Vf,Zf);
    I_LG(n) = max(abs(r.Iabc));

    %% LL

    r = fault_at_bus(k,'LL',Z0,Z1,Z2,Vf,Zf);
    I_LL(n) = max(abs(r.Iabc));

    %% LLG

    r = fault_at_bus(k,'LLG',Z0,Z1,Z2,Vf,Zf);
    I_LLG(n) = max(abs(r.Iabc));

end

%% Plot fault current versus Zf

figure;

plot(Zf_values,I_3ph,'LineWidth',1.5);
hold on;

plot(Zf_values,I_LG,'LineWidth',1.5);

plot(Zf_values,I_LL,'LineWidth',1.5);

plot(Zf_values,I_LLG,'LineWidth',1.5);

grid on;

xlabel('Fault Impedance Z_f (pu)');
ylabel('Maximum Phase Current (pu)');

title('Fault Current vs Fault Impedance');

legend('3-phase','LG','LL','LLG', ...
    'Location','northeast');

%% Save figure

saveas(gcf,'Fault_Current_vs_Zf.png');


%% =========================================================
% STUDY 2: LG fault current versus neutral impedance
% ==========================================================

Zn_values = linspace(0,0.5,101);

I_LG_bus1 = zeros(size(Zn_values));
I_LG_bus3 = zeros(size(Zn_values));

for n = 1:length(Zn_values)

    Zn = Zn_values(n);

    %% Create modified network parameters

    net_test = net;

    net_test.Zn = [Zn Zn];

    %% Rebuild sequence networks

    [~,~,~,Z0_test,Z1_test,Z2_test] = ...
        build_networks(net_test);

    %% LG fault at Bus 1

    r1 = fault_at_bus(1,'LG', ...
        Z0_test,Z1_test,Z2_test,Vf,0);

    I_LG_bus1(n) = max(abs(r1.Iabc));

    %% LG fault at Bus 3

    r3 = fault_at_bus(3,'LG', ...
        Z0_test,Z1_test,Z2_test,Vf,0);

    I_LG_bus3(n) = max(abs(r3.Iabc));

end

%% Plot neutral impedance study

figure;

plot(Zn_values,I_LG_bus1,'LineWidth',1.5);
hold on;

plot(Zn_values,I_LG_bus3,'LineWidth',1.5);

grid on;

xlabel('Generator Neutral Impedance Z_n (pu)');
ylabel('LG Fault Current (pu)');

title('LG Fault Current vs Generator Neutral Impedance');

legend('LG fault at Bus 1', ...
       'LG fault at Bus 3', ...
       'Location','northeast');

%% Save figure

saveas(gcf,'LG_Current_vs_Neutral_Impedance.png');


%% ============================================================
%  STUDY 3: TRANSFORMER CONNECTION COMPARISON
%  LG fault current at all buses
%  Delta-Yg vs Yg-Yg
% =============================================================

fprintf('\n');
fprintf('============================================================\n');
fprintf('       TRANSFORMER CONNECTION COMPARISON\n');
fprintf('============================================================\n');

%% General network quantities

nb = net.nb;
Ibase = net.Ibase;

%% Store original transformer connection

original_conn = net.conn;


%% ------------------------------------------------------------
% Delta-Yg case
% ------------------------------------------------------------

net.conn = 'DeltaYg';

[~,~,~,Z0_delta,Z1_delta,Z2_delta] = ...
    build_networks(net);

I_delta_pu = zeros(nb,1);
I_delta_kA = zeros(nb,1);

for k = 1:nb

    r = fault_at_bus(k, ...
                     'LG', ...
                     Z0_delta, ...
                     Z1_delta, ...
                     Z2_delta, ...
                     Vf, ...
                     0);

    % Maximum phase current
    I_delta_pu(k) = max(abs(r.Iabc));

    % Convert using current base of faulted bus
    I_delta_kA(k) = I_delta_pu(k) * Ibase(k) / 1000;

end


%% ------------------------------------------------------------
% Yg-Yg case
% ------------------------------------------------------------

net.conn = 'YgYg';

[~,~,~,Z0_yg,Z1_yg,Z2_yg] = ...
    build_networks(net);

I_yg_pu = zeros(nb,1);
I_yg_kA = zeros(nb,1);

for k = 1:nb

    r = fault_at_bus(k, ...
                     'LG', ...
                     Z0_yg, ...
                     Z1_yg, ...
                     Z2_yg, ...
                     Vf, ...
                     0);

    % Maximum phase current
    I_yg_pu(k) = max(abs(r.Iabc));

    % Convert using current base of faulted bus
    I_yg_kA(k) = I_yg_pu(k) * Ibase(k) / 1000;

end


%% ------------------------------------------------------------
% Restore original transformer connection
% ------------------------------------------------------------

net.conn = original_conn;


%% ------------------------------------------------------------
% Percentage difference
% ------------------------------------------------------------

percent_difference = ...
    100 * (I_delta_pu - I_yg_pu) ./ I_delta_pu;


%% ------------------------------------------------------------
% Display results
% ------------------------------------------------------------

fprintf('\nLG Fault Current Comparison:\n\n');

fprintf(['Bus    Delta-Yg (pu)    Yg-Yg (pu)    ' ...
         'Delta-Yg (kA)    Yg-Yg (kA)\n']);

fprintf(['----------------------------------------------------------------' ...
         '-------\n']);

for k = 1:nb

    fprintf('%d      %8.4f         %8.4f       %8.4f        %8.4f\n', ...
            k, ...
            I_delta_pu(k), ...
            I_yg_pu(k), ...
            I_delta_kA(k), ...
            I_yg_kA(k));

end


%% ------------------------------------------------------------
% Display percentage difference
% ------------------------------------------------------------

fprintf('\nPercentage difference (Delta-Yg vs Yg-Yg):\n\n');

fprintf('Bus        Difference (%%)\n');
fprintf('--------------------------\n');

for k = 1:nb

    fprintf('%d          %8.3f %%\n', ...
            k, ...
            percent_difference(k));

end


%% ============================================================
% Plot 1: Per-unit comparison
% ============================================================

figure;

bar(1:nb,[I_delta_pu I_yg_pu]);

grid on;

xlabel('Bus Number');
ylabel('LG Fault Current (pu)');

title('Effect of Transformer Connection on LG Fault Current');

legend('Delta-Yg','Yg-Yg', ...
       'Location','best');

xticks(1:nb);


%% ============================================================
% Plot 2: Actual current comparison
% ============================================================

figure;

bar(1:nb,[I_delta_kA I_yg_kA]);

grid on;

xlabel('Bus Number');
ylabel('LG Fault Current (kA)');

title('LG Fault Current: Delta-Yg vs Yg-Yg');

legend('Delta-Yg','Yg-Yg', ...
       'Location','best');

xticks(1:nb);


%% ------------------------------------------------------------
% Save results as MATLAB table
% ------------------------------------------------------------

transformer_table = table( ...
    (1:nb)', ...
    I_delta_pu, ...
    I_yg_pu, ...
    I_delta_kA, ...
    I_yg_kA, ...
    percent_difference, ...
    'VariableNames', { ...
    'Bus', ...
    'DeltaYg_pu', ...
    'YgYg_pu', ...
    'DeltaYg_kA', ...
    'YgYg_kA', ...
    'Difference_percent'});

fprintf('\n');
disp(transformer_table);
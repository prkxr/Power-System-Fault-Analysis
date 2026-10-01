%% voltage_profile_study.m
% Post-fault voltage profile for faults at Bus 3
%
% Faults:
%   1. Three-phase
%   2. A-G
%   3. B-C
%   4. B-C-G

clear;
clc;
close all;

%% Load system parameters

net = parameters;

%% Build sequence networks

[Y0,Y1,Y2,Z0,Z1,Z2] = build_networks(net);

%% Fault parameters

k = 3;              % Fault at Bus 3
Vf = net.Vf;
Zf = 0;             % Solid fault

%% Fault types

fault_types = {'3ph','LG','LL','LLG'};

fault_names = { ...
    'Three-Phase', ...
    'A-Ground (LG)', ...
    'B-C (LL)', ...
    'B-C-Ground (LLG)'};

%% Bus numbers

buses = 1:net.nb;

%% Calculate voltage profiles

for f = 1:length(fault_types)

    type = fault_types{f};

    %% Run fault calculation

    r = fault_at_bus(k,type,Z0,Z1,Z2,Vf,Zf);

    %% Extract phase voltages

    Va = abs(r.Vabc(1,:));
    Vb = abs(r.Vabc(2,:));
    Vc = abs(r.Vabc(3,:));

    %% Display numerical values

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf('%s Fault at Bus %d\n', fault_names{f}, k);
    fprintf('============================================================\n');

    fprintf('\n');
    fprintf('%6s %12s %12s %12s\n', ...
        'Bus','|Va| pu','|Vb| pu','|Vc| pu');

    fprintf('------------------------------------------------------------\n');

    for b = 1:net.nb

        fprintf('%6d %12.4f %12.4f %12.4f\n', ...
            b,Va(b),Vb(b),Vc(b));

    end

    %% Plot voltage profile

    figure;

    plot(buses,Va,'-o','LineWidth',1.5);
    hold on;

    plot(buses,Vb,'-s','LineWidth',1.5);

    plot(buses,Vc,'-^','LineWidth',1.5);

    grid on;

    xlabel('Bus Number');
    ylabel('Voltage Magnitude (pu)');

    title(sprintf('%s Fault at Bus %d', ...
        fault_names{f},k));

    legend('|V_a|','|V_b|','|V_c|', ...
        'Location','best');

    xticks(buses);

    ylim([0 1.1]);

end
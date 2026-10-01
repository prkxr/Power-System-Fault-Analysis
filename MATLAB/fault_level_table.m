%% fault_level_table.m
% Fault level calculation for all buses and all fault types

clear;
clc;

%% Load parameters

net = parameters;

%% Build sequence networks

[Y0,Y1,Y2,Z0,Z1,Z2] = build_networks(net);

%% System parameters

nb = net.nb;
Vf = net.Vf;
Zf = 0;

fault_types = {'3ph','LG','LL','LLG'};

%% Preallocate results

Ipu = zeros(nb,4);
IkA = zeros(nb,4);

%% Calculate fault currents

for k = 1:nb

    for f = 1:length(fault_types)

        type = fault_types{f};

        r = fault_at_bus(k,type,Z0,Z1,Z2,Vf,Zf);

        % Maximum phase current
        Ipu(k,f) = max(abs(r.Iabc));

        % Convert to kA
        IkA(k,f) = Ipu(k,f)*net.Ibase(k)/1000;

    end

end

%% Three-phase fault MVA

% Fault MVA = sqrt(3) * V(kV) * I(kA)

MVA_3ph = sqrt(3) .* net.Vbase .* IkA(:,1);

%% LG / 3-phase current ratio

LG_ratio = Ipu(:,2) ./ Ipu(:,1);

%% Display table

fprintf('\n');
fprintf('==========================================================================\n');
fprintf('                    FAULT LEVEL TABLE\n');
fprintf('==========================================================================\n');

fprintf('\n');
fprintf('%4s %12s %12s %12s %12s %12s %12s\n', ...
    'Bus', ...
    '3ph (pu)', ...
    '3ph (kA)', ...
    'LG (kA)', ...
    'LL (kA)', ...
    'LLG (kA)', ...
    '3ph MVA');

fprintf('--------------------------------------------------------------------------\n');

for k = 1:nb

    fprintf('%4d %12.4f %12.4f %12.4f %12.4f %12.4f %12.2f\n', ...
        k, ...
        Ipu(k,1), ...
        IkA(k,1), ...
        IkA(k,2), ...
        IkA(k,3), ...
        IkA(k,4), ...
        MVA_3ph(k));

end

fprintf('==========================================================================\n');

%% Display LG / 3-phase ratio

fprintf('\nLG / 3-phase current ratio:\n');
fprintf('--------------------------------\n');

for k = 1:nb

    fprintf('Bus %d : %.4f\n', k, LG_ratio(k));

end

%% Create MATLAB table

FaultTable = table( ...
    (1:nb)', ...
    Ipu(:,1), ...
    IkA(:,1), ...
    IkA(:,2), ...
    IkA(:,3), ...
    IkA(:,4), ...
    MVA_3ph, ...
    LG_ratio, ...
    'VariableNames', { ...
    'Bus', ...
    'I3ph_pu', ...
    'I3ph_kA', ...
    'ILG_kA', ...
    'ILL_kA', ...
    'ILLG_kA', ...
    'Fault_MVA', ...
    'LG_to_3ph'});

fprintf('\nComplete MATLAB table:\n\n');

disp(FaultTable);
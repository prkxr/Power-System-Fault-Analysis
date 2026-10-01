%% outage_study.m
% Line 2-4 outage study
% Rebuild sequence networks and compare fault levels
% before and after the outage.

clear;
clc;
close all;

%% ============================================================
% Load system parameters
% =============================================================

net = parameters;

nb   = net.nb;
Vf   = net.Vf;
Ibase = net.Ibase;
Sbase = net.Sbase;

%% ============================================================
% BASE CASE
% =============================================================

fprintf('\n');
fprintf('============================================================\n');
fprintf('                    BASE CASE\n');
fprintf('============================================================\n');

% Build original networks

[~,~,~,Z0_base,Z1_base,Z2_base] = ...
    build_networks(net);

%% Fault types

types = {'3ph','LG','LL','LLG'};

type_names = {'3-phase','LG','LL','LLG'};

%% Storage

I_base_pu = zeros(nb,4);
I_base_kA = zeros(nb,4);

%% Calculate base-case fault currents

for k = 1:nb

    for t = 1:4

        r = fault_at_bus(k, ...
                         types{t}, ...
                         Z0_base, ...
                         Z1_base, ...
                         Z2_base, ...
                         Vf, ...
                         0);

        % Maximum phase current
        I_base_pu(k,t) = max(abs(r.Iabc));

        % Convert to actual current
        I_base_kA(k,t) = ...
            I_base_pu(k,t) * Ibase(k) / 1000;

    end

end


%% ============================================================
% LINE 2-4 OUTAGE
% =============================================================

fprintf('\n');
fprintf('============================================================\n');
fprintf('                  LINE 2-4 OUTAGE\n');
fprintf('============================================================\n');

%% Identify line 2-4

outage_line = find( ...
    net.line(:,1) == 2 & ...
    net.line(:,2) == 4);

if isempty(outage_line)

    error('Line 2-4 was not found in net.line.');

elseif length(outage_line) > 1

    error('Multiple 2-4 lines found. Check net.line.');

end

fprintf('\nRemoving line 2-4 (row %d of net.line)...\n', ...
        outage_line);

%% Create modified network

net_outage = net;

net_outage.line(outage_line,:) = [];

%% Rebuild sequence networks

[~,~,~,Z0_out,Z1_out,Z2_out] = ...
    build_networks(net_outage);


%% ============================================================
% CALCULATE OUTAGE-CASE FAULT CURRENTS
% =============================================================

I_out_pu = zeros(nb,4);
I_out_kA = zeros(nb,4);

for k = 1:nb

    for t = 1:4

        r = fault_at_bus(k, ...
                         types{t}, ...
                         Z0_out, ...
                         Z1_out, ...
                         Z2_out, ...
                         Vf, ...
                         0);

        % Maximum phase current
        I_out_pu(k,t) = max(abs(r.Iabc));

        % Convert to actual current
        I_out_kA(k,t) = ...
            I_out_pu(k,t) * Ibase(k) / 1000;

    end

end


%% ============================================================
% 3-PHASE FAULT MVA
% =============================================================

MVA_base = zeros(nb,1);
MVA_out  = zeros(nb,1);

for k = 1:nb

    MVA_base(k) = ...
        Sbase * Vf / abs(Z1_base(k,k));

    MVA_out(k) = ...
        Sbase * Vf / abs(Z1_out(k,k));

end


%% ============================================================
% PERCENTAGE CHANGE
% =============================================================

percent_change_pu = ...
    100 * (I_out_pu - I_base_pu) ./ I_base_pu;

percent_change_kA = ...
    100 * (I_out_kA - I_base_kA) ./ I_base_kA;

percent_change_MVA = ...
    100 * (MVA_out - MVA_base) ./ MVA_base;


%% ============================================================
% DISPLAY BASE-CASE RESULTS
% =============================================================

fprintf('\n');
fprintf('============================================================\n');
fprintf('             BASE-CASE FAULT LEVELS\n');
fprintf('============================================================\n');

fprintf('\n');
fprintf(['Bus    3ph (kA)    LG (kA)    LL (kA)    ' ...
         'LLG (kA)    3ph MVA\n']);

fprintf(['----------------------------------------------------------------' ...
         '-------\n']);

for k = 1:nb

    fprintf('%d      %8.4f    %8.4f    %8.4f    %8.4f    %8.2f\n', ...
        k, ...
        I_base_kA(k,1), ...
        I_base_kA(k,2), ...
        I_base_kA(k,3), ...
        I_base_kA(k,4), ...
        MVA_base(k));

end


%% ============================================================
% DISPLAY OUTAGE RESULTS
% =============================================================

fprintf('\n');
fprintf('============================================================\n');
fprintf('           LINE 2-4 OUTAGE FAULT LEVELS\n');
fprintf('============================================================\n');

fprintf('\n');
fprintf(['Bus    3ph (kA)    LG (kA)    LL (kA)    ' ...
         'LLG (kA)    3ph MVA\n']);

fprintf(['----------------------------------------------------------------' ...
         '-------\n']);

for k = 1:nb

    fprintf('%d      %8.4f    %8.4f    %8.4f    %8.4f    %8.2f\n', ...
        k, ...
        I_out_kA(k,1), ...
        I_out_kA(k,2), ...
        I_out_kA(k,3), ...
        I_out_kA(k,4), ...
        MVA_out(k));

end


%% ============================================================
% DISPLAY CHANGE
% =============================================================

fprintf('\n');
fprintf('============================================================\n');
fprintf('       PERCENTAGE CHANGE DUE TO LINE 2-4 OUTAGE\n');
fprintf('============================================================\n');

fprintf('\n');
fprintf(['Bus    3ph (%%)    LG (%%)    LL (%%)    ' ...
         'LLG (%%)    3ph MVA (%%)\n']);

fprintf(['----------------------------------------------------------------' ...
         '-------\n']);

for k = 1:nb

    fprintf('%d      %+8.3f   %+8.3f   %+8.3f   %+8.3f    %+8.3f\n', ...
        k, ...
        percent_change_kA(k,1), ...
        percent_change_kA(k,2), ...
        percent_change_kA(k,3), ...
        percent_change_kA(k,4), ...
        percent_change_MVA(k));

end


%% ============================================================
% PLOT 1: 3-PHASE FAULT CURRENT
% =============================================================

figure;

bar(1:nb,[I_base_kA(:,1) I_out_kA(:,1)]);

grid on;

xlabel('Bus Number');
ylabel('3-Phase Fault Current (kA)');

title('Effect of Line 2-4 Outage on 3-Phase Fault Current');

legend('Base Case','Line 2-4 Outage', ...
       'Location','best');

xticks(1:nb);

saveas(gcf,'Outage_3ph_Fault_Current.png');


%% ============================================================
% PLOT 2: ALL FAULT TYPES
% =============================================================

figure;

for t = 1:4

    subplot(2,2,t);

    bar(1:nb,[I_base_kA(:,t) I_out_kA(:,t)]);

    grid on;

    xlabel('Bus Number');
    ylabel('Fault Current (kA)');

    title([type_names{t} ' Fault']);

    legend('Base','Line 2-4 Outage', ...
           'Location','best');

    xticks(1:nb);

end

saveas(gcf,'Outage_All_Fault_Types.png');


%% ============================================================
% SAVE RESULTS
% =============================================================

outage_table = table( ...
    (1:nb)', ...
    I_base_kA(:,1), ...
    I_out_kA(:,1), ...
    I_base_kA(:,2), ...
    I_out_kA(:,2), ...
    I_base_kA(:,3), ...
    I_out_kA(:,3), ...
    I_base_kA(:,4), ...
    I_out_kA(:,4), ...
    MVA_base, ...
    MVA_out, ...
    'VariableNames', { ...
    'Bus', ...
    'Base_3ph_kA', ...
    'Outage_3ph_kA', ...
    'Base_LG_kA', ...
    'Outage_LG_kA', ...
    'Base_LL_kA', ...
    'Outage_LL_kA', ...
    'Base_LLG_kA', ...
    'Outage_LLG_kA', ...
    'Base_3ph_MVA', ...
    'Outage_3ph_MVA'});

fprintf('\n');
fprintf('============================================================\n');
fprintf('                    RESULT TABLE\n');
fprintf('============================================================\n');

disp(outage_table);

%% Save table

writetable(outage_table,'Line_2_4_Outage_Results.csv');

fprintf('\nResults saved to:\n');
fprintf('  Line_2_4_Outage_Results.csv\n');
fprintf('  Outage_3ph_Fault_Current.png\n');
fprintf('  Outage_All_Fault_Types.png\n');
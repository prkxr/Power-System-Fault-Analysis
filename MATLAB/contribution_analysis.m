%% contribution_analysis.m
% Generator and line contribution to a fault at Bus 3

clear;
clc;

%% Load parameters

net = parameters;

%% Build sequence networks

[Y0,Y1,Y2,Z0,Z1,Z2] = build_networks(net);

%% Fault parameters

k = 3;              % Fault at Bus 3
Vf = net.Vf;
Zf = 0;

%% Calculate 3-phase fault

r = fault_at_bus(k,'3ph',Z0,Z1,Z2,Vf,Zf);

%% Positive-sequence bus voltages

V1 = r.V1;

%% ---------------------------------------------------------
% Generator contributions
% ----------------------------------------------------------

% Generator buses
g1_bus = 1;
g2_bus = 5;

% Generator impedances
Zg1 = net.gen(1,2);       % Positive-sequence G1 impedance
Zg2 = net.gen(2,2);       % Positive-sequence G2 impedance

% Generator internal voltages
Eg1 = Vf;
Eg2 = Vf;

% Generator currents flowing into the network

Ig1 = (Eg1 - V1(g1_bus)) / Zg1;

Ig2 = (Eg2 - V1(g2_bus)) / Zg2;

%% Convert generator currents to kA

Ig1_kA = abs(Ig1) * net.Ibase(g1_bus) / 1000;
Ig2_kA = abs(Ig2) * net.Ibase(g2_bus) / 1000;

%% Display generator contributions

fprintf('\n');
fprintf('============================================================\n');
fprintf('       GENERATOR CONTRIBUTION - BUS 3 FAULT\n');
fprintf('============================================================\n');

fprintf('\nPositive-sequence generator currents:\n');

fprintf('G1: %.4f %+.4fj pu | magnitude = %.4f pu\n', ...
    real(Ig1), imag(Ig1), abs(Ig1));

fprintf('G2: %.4f %+.4fj pu | magnitude = %.4f pu\n', ...
    real(Ig2), imag(Ig2), abs(Ig2));

fprintf('\nGenerator contribution in actual current:\n');

fprintf('G1: %.4f kA\n', Ig1_kA);
fprintf('G2: %.4f kA\n', Ig2_kA);

%% ---------------------------------------------------------
% Line currents
% ----------------------------------------------------------

fprintf('\n');
fprintf('============================================================\n');
fprintf('              LINE CURRENTS\n');
fprintf('============================================================\n');

for m = 1:size(net.line,1)

    i = net.line(m,1);
    j = net.line(m,2);

    Zij = net.line(m,3);

    % Positive-sequence current from i -> j

    Iij = (V1(i)-V1(j))/Zij;

    % Actual current base
    % Both ends of the transmission line are 132 kV

    Iij_kA = abs(Iij)*net.Ibase(i)/1000;

    fprintf('\nLine %d-%d:\n',i,j);

    fprintf('I(%d -> %d) = %.4f %+.4fj pu\n', ...
        i,j,real(Iij),imag(Iij));

    fprintf('|I(%d -> %d)| = %.4f pu\n', ...
        i,j,abs(Iij));

    fprintf('|I(%d -> %d)| = %.4f kA\n', ...
        i,j,Iij_kA);

end

%% ---------------------------------------------------------
% Fault current
% ----------------------------------------------------------

Ifault = r.I1;

fprintf('\n');
fprintf('============================================================\n');
fprintf('                 FAULT CURRENT\n');
fprintf('============================================================\n');

fprintf('\nI_fault = %.4f %+.4fj pu\n', ...
    real(Ifault),imag(Ifault));

fprintf('|I_fault| = %.4f pu\n',abs(Ifault));

fprintf('|I_fault| = %.4f kA\n', ...
    abs(Ifault)*net.Ibase(k)/1000);

fprintf('\n============================================================\n');
function net = parameters
% PARAMETERS
% Defines the custom 5-bus power system used for fault analysis.
%
% System base:
%   Sbase = 100 MVA
%
% Bus voltage bases:
%   Bus 1,5 = 11 kV
%   Bus 2,3,4 = 132 kV

%% System Base Values

net.Sbase = 100;       % MVA
net.Vf = 1.0;          % Prefault voltage, pu
net.nb = 5;            % Number of buses

%% Bus Voltage Bases

net.Vbase = [11 132 132 132 11];    % kV

%% Current Bases

net.Ibase = net.Sbase*1e6 ./ ...
            (sqrt(3)*net.Vbase*1e3);

%% Generator Data
%
% Columns:
% Bus   Z1       Z2       Z0

net.gen = [ ...
    1   1j*0.15   1j*0.17   1j*0.05;
    5   1j*0.20   1j*0.22   1j*0.06
];

%% Transformer Data
%
% Columns:
% LV bus   HV bus   Leakage impedance

net.xfmr = [ ...
    1   2   1j*0.10;
    5   4   1j*0.12
];

%% Transmission Line Data
%
% Columns:
% From   To   Z1              Z0

net.line = [ ...
    2   3   0.02 + 1j*0.10   0.06 + 1j*0.30;
    3   4   0.02 + 1j*0.08   0.06 + 1j*0.24;
    2   4   0.03 + 1j*0.12   0.09 + 1j*0.36
];

%% Generator Neutral Grounding

net.Zn = [0 0];

%% Transformer Connection

net.conn = 'DeltaYg';

end
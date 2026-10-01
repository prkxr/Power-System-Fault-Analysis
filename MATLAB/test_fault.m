%% test_fault.m
% Validation of fault calculations at Bus 3
%
% Faults tested:
%   1. Three-phase
%   2. A-G (LG)
%   3. B-C (LL)
%   4. B-C-G (LLG)

clear;
clc;

%% Load system parameters

net = parameters;

%% Build sequence networks

[Y0,Y1,Y2,Z0,Z1,Z2] = build_networks(net);

%% Fault parameters

k = 3;              % Fault at Bus 3
Vf = net.Vf;        % Prefault voltage
Zf = 0;              % Solid fault

Ibase = net.Ibase(k);

%% Fault types

fault_types = {'3ph','LG','LL','LLG'};

fprintf('\n');
fprintf('============================================================\n');
fprintf('          FAULT VALIDATION - BUS %d\n', k);
fprintf('============================================================\n');

%% Run all faults

for n = 1:length(fault_types)

    type = fault_types{n};

    r = fault_at_bus(k,type,Z0,Z1,Z2,Vf,Zf);

    fprintf('\n------------------------------------------------------------\n');

    switch type
        case '3ph'
            fprintf('THREE-PHASE FAULT\n');

        case 'LG'
            fprintf('A-GROUND FAULT (LG)\n');

        case 'LL'
            fprintf('B-C FAULT (LL)\n');

        case 'LLG'
            fprintf('B-C-GROUND FAULT (LLG)\n');
    end

    fprintf('------------------------------------------------------------\n');

    %% Sequence currents

    fprintf('\nSequence currents:\n');

    fprintf('I0 = %8.4f %+.4fj pu | |I0| = %.4f pu\n', ...
        real(r.I0), imag(r.I0), abs(r.I0));

    fprintf('I1 = %8.4f %+.4fj pu | |I1| = %.4f pu\n', ...
        real(r.I1), imag(r.I1), abs(r.I1));

    fprintf('I2 = %8.4f %+.4fj pu | |I2| = %.4f pu\n', ...
        real(r.I2), imag(r.I2), abs(r.I2));

    %% Phase currents

    fprintf('\nPhase currents:\n');

    fprintf('Ia = %8.4f %+.4fj pu | |Ia| = %.4f pu\n', ...
        real(r.Iabc(1)), imag(r.Iabc(1)), abs(r.Iabc(1)));

    fprintf('Ib = %8.4f %+.4fj pu | |Ib| = %.4f pu\n', ...
        real(r.Iabc(2)), imag(r.Iabc(2)), abs(r.Iabc(2)));

    fprintf('Ic = %8.4f %+.4fj pu | |Ic| = %.4f pu\n', ...
        real(r.Iabc(3)), imag(r.Iabc(3)), abs(r.Iabc(3)));

    %% Phase current angles

    fprintf('\nPhase angles:\n');

    fprintf('Ia = %8.2f degrees\n', ...
        angle(r.Iabc(1))*180/pi);

    fprintf('Ib = %8.2f degrees\n', ...
        angle(r.Iabc(2))*180/pi);

    fprintf('Ic = %8.2f degrees\n', ...
        angle(r.Iabc(3))*180/pi);

    %% Maximum phase current

    Ifault_pu = max(abs(r.Iabc));

    Ifault_kA = Ifault_pu * Ibase / 1000;

    fprintf('\nFault current:\n');
    fprintf('|I| max = %.4f pu\n', Ifault_pu);
    fprintf('|I| max = %.4f kA\n', Ifault_kA);

    %% Boundary-condition checks

    fprintf('\nBoundary-condition checks:\n');

    tolerance = 1e-8;

    switch type

        case '3ph'

            % Equal phase-current magnitudes
            check1 = max(abs(abs(r.Iabc) - abs(r.Iabc(1)))) ...
                     < tolerance;

            % Zero-sequence current
            check2 = abs(r.I0) < tolerance;

            % Negative-sequence current
            check3 = abs(r.I2) < tolerance;

            fprintf('Equal phase-current magnitudes : %s\n', passfail(check1));
            fprintf('I0 = 0                         : %s\n', passfail(check2));
            fprintf('I2 = 0                         : %s\n', passfail(check3));


        case 'LG'

            % For A-G:
            % Ib = 0
            % Ic = 0
            check1 = abs(r.Iabc(2)) < tolerance;
            check2 = abs(r.Iabc(3)) < tolerance;

            % I0 = I1 = I2
            check3 = abs(r.I0-r.I1) < tolerance;
            check4 = abs(r.I1-r.I2) < tolerance;

            fprintf('Ib = 0                         : %s\n', passfail(check1));
            fprintf('Ic = 0                         : %s\n', passfail(check2));
            fprintf('I0 = I1                        : %s\n', passfail(check3));
            fprintf('I1 = I2                        : %s\n', passfail(check4));


        case 'LL'

            % For B-C:
            % Ia = 0
            % Ib = -Ic
            % I0 = 0

            check1 = abs(r.Iabc(1)) < tolerance;
            check2 = abs(r.Iabc(2)+r.Iabc(3)) < tolerance;
            check3 = abs(r.I0) < tolerance;

            fprintf('Ia = 0                         : %s\n', passfail(check1));
            fprintf('Ib = -Ic                       : %s\n', passfail(check2));
            fprintf('I0 = 0                         : %s\n', passfail(check3));


        case 'LLG'

            % For B-C-G:
            % Ia = 0
            % Ib + Ic = 3I0

            check1 = abs(r.Iabc(1)) < tolerance;
            check2 = abs(r.Iabc(2)+r.Iabc(3)-3*r.I0) ...
                     < tolerance;

            fprintf('Ia = 0                         : %s\n', passfail(check1));
            fprintf('Ib + Ic = 3I0                  : %s\n', passfail(check2));

    end

end

fprintf('\n============================================================\n');
fprintf('Fault validation complete.\n');
fprintf('============================================================\n');


%% Local function
function result = passfail(condition)

    if condition
        result = 'PASS';
    else
        result = 'FAIL';
    end

end
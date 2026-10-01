clear;
clc;

%% Load network parameters

net = parameters;

%% ============================================================
% Delta-Yg case
% =============================================================

net.conn = 'DeltaYg';

[Y0_DYg,Y1_DYg,Y2_DYg,Z0_DYg,Z1_DYg,Z2_DYg] = ...
    build_networks(net);

fprintf('\n============================================================\n');
fprintf('DELTA-Yg ZERO-SEQUENCE YBUS\n');
fprintf('============================================================\n');

disp(Y0_DYg);


%% ============================================================
% Yg-Yg case
% =============================================================

net.conn = 'YgYg';

[Y0_YgYg,Y1_YgYg,Y2_YgYg,Z0_YgYg,Z1_YgYg,Z2_YgYg] = ...
    build_networks(net);

fprintf('\n============================================================\n');
fprintf('Yg-Yg ZERO-SEQUENCE YBUS\n');
fprintf('============================================================\n');

disp(Y0_YgYg);


%% ============================================================
% Transformer connection check
% =============================================================

fprintf('\n============================================================\n');
fprintf('TRANSFORMER CONNECTION CHECK\n');
fprintf('============================================================\n');

fprintf('\nDelta-Yg:\n');

fprintf('Y0(1,2) = %.4f %+.4fi\n', ...
    real(Y0_DYg(1,2)), imag(Y0_DYg(1,2)));

fprintf('Y0(2,1) = %.4f %+.4fi\n', ...
    real(Y0_DYg(2,1)), imag(Y0_DYg(2,1)));

fprintf('Y0(4,5) = %.4f %+.4fi\n', ...
    real(Y0_DYg(4,5)), imag(Y0_DYg(4,5)));

fprintf('Y0(5,4) = %.4f %+.4fi\n', ...
    real(Y0_DYg(5,4)), imag(Y0_DYg(5,4)));


fprintf('\nYg-Yg:\n');

fprintf('Y0(1,2) = %.4f %+.4fi\n', ...
    real(Y0_YgYg(1,2)), imag(Y0_YgYg(1,2)));

fprintf('Y0(2,1) = %.4f %+.4fi\n', ...
    real(Y0_YgYg(2,1)), imag(Y0_YgYg(2,1)));

fprintf('Y0(4,5) = %.4f %+.4fi\n', ...
    real(Y0_YgYg(4,5)), imag(Y0_YgYg(4,5)));

fprintf('Y0(5,4) = %.4f %+.4fi\n', ...
    real(Y0_YgYg(5,4)), imag(Y0_YgYg(5,4)));
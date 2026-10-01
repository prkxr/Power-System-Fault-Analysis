clc;
clear;
close all;

%% Load parameters

parameters;

%% Build sequence networks

[Y0,Y1,Y2,Z0,Z1,Z2] = build_networks(net);

nb = 5;
tol = 1e-10;

fprintf('\n============================================\n');
fprintf('Zbus Verification\n');
fprintf('============================================\n');

%% Ybus symmetry

err_Y0 = norm(Y0 - Y0.');
err_Y1 = norm(Y1 - Y1.');
err_Y2 = norm(Y2 - Y2.');

fprintf('\nYbus symmetry errors:\n');
fprintf('Y0: %.3e\n',err_Y0);
fprintf('Y1: %.3e\n',err_Y1);
fprintf('Y2: %.3e\n',err_Y2);

assert(err_Y0 < tol);
assert(err_Y1 < tol);
assert(err_Y2 < tol);

fprintf('Ybus symmetry: PASS\n');

%% Zbus symmetry

err_Z0 = norm(Z0 - Z0.');
err_Z1 = norm(Z1 - Z1.');
err_Z2 = norm(Z2 - Z2.');

fprintf('\nZbus symmetry errors:\n');
fprintf('Z0: %.3e\n',err_Z0);
fprintf('Z1: %.3e\n',err_Z1);
fprintf('Z2: %.3e\n',err_Z2);

assert(err_Z0 < tol);
assert(err_Z1 < tol);
assert(err_Z2 < tol);

fprintf('Zbus symmetry: PASS\n');

%% Ybus * Zbus

err_YZ0 = norm(Y0*Z0 - eye(nb));
err_YZ1 = norm(Y1*Z1 - eye(nb));
err_YZ2 = norm(Y2*Z2 - eye(nb));

fprintf('\nYbus * Zbus errors:\n');
fprintf('Y0*Z0: %.3e\n',err_YZ0);
fprintf('Y1*Z1: %.3e\n',err_YZ1);
fprintf('Y2*Z2: %.3e\n',err_YZ2);

assert(err_YZ0 < tol);
assert(err_YZ1 < tol);
assert(err_YZ2 < tol);

fprintf('Y0*Z0 = I: PASS\n');
fprintf('Y1*Z1 = I: PASS\n');
fprintf('Y2*Z2 = I: PASS\n');

%% Independent bus-3 Thevenin check

Itest = zeros(nb,1);
Itest(3) = 1;

Vtest = Y1 \ Itest;

Zth_bus3 = Vtest(3);

fprintf('\nBus 3 Positive-Sequence Thevenin Check\n');
fprintf('---------------------------------------\n');

fprintf('Zth from Ybus = ');
disp(Zth_bus3);

fprintf('Z1(3,3)       = ');
disp(Z1(3,3));

difference = abs(Zth_bus3 - Z1(3,3));

fprintf('Difference     = %.3e\n',difference);

assert(difference < tol);

fprintf('Bus 3 Thevenin check: PASS\n');

%% Matrix validity

assert(all(isfinite(Z0(:))));
assert(all(isfinite(Z1(:))));
assert(all(isfinite(Z2(:))));

assert(isequal(size(Z0),[5 5]));
assert(isequal(size(Z1),[5 5]));
assert(isequal(size(Z2),[5 5]));

fprintf('\nFinite-value check: PASS\n');
fprintf('Matrix dimension check: PASS\n');

%% Display driving-point impedances

fprintf('\nPositive-sequence driving-point impedances:\n');

for k = 1:nb
    fprintf('Bus %d: ',k);
    disp(Z1(k,k));
end

fprintf('\nZero-sequence driving-point impedances:\n');

for k = 1:nb
    fprintf('Bus %d: ',k);
    disp(Z0(k,k));
end

%% Sparsity plots

figure;
spy(Y1);
title('Positive-Sequence Ybus Sparsity Pattern');

figure;
spy(Y0);
title('Zero-Sequence Ybus Sparsity Pattern');
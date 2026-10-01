clc;
clear;
close all;

%% Symmetrical Component Transformation

% Operator a
a = exp(1j*2*pi/3);

%% Verify properties of operator a

fprintf('\nOperator checks:\n');

fprintf('a^3 = ');
disp(a^3);

fprintf('1 + a + a^2 = ');
disp(1 + a + a^2);

% Transformation matrix
A = [1  1    1;
     1  a^2  a;
     1  a    a^2];


% Inverse transformation matrix
Ainv = inv(A);

disp('Operator a:')
disp(a)

disp('Transformation matrix A:')
disp(A)

disp('Inverse transformation matrix A^-1:')
disp(Ainv)

%% Verify inverse transformation

Ainv_expected = (1/3) * ...
    [1  1    1;
     1  a    a^2;
     1  a^2  a];

fprintf('\nDifference between calculated and expected inverse:\n');
disp(Ainv - Ainv_expected);

assert(norm(Ainv - Ainv_expected) < 1e-12);

fprintf('Inverse transformation check passed.\n');

assert(norm(A*Ainv - eye(3)) < 1e-12);
assert(norm(Ainv*A - eye(3)) < 1e-12);

fprintf('A*Ainv = I check passed.\n');

%% Test 1: Balanced positive-sequence system

V0 = 0;
V1 = 1;
V2 = 0;

Vseq = [V0; V1; V2];

Vabc = A * Vseq;

fprintf('\nTest 1: Positive-sequence system\n');

disp('Phase voltages:')
disp(Vabc);

fprintf('\nMagnitude and angle:\n');

phase_names = {'Va','Vb','Vc'};

for k = 1:3
    fprintf('%s: %.4f pu, %.2f degrees\n', ...
        phase_names{k}, abs(Vabc(k)), angle(Vabc(k))*180/pi);
end

%% Test reverse transformation

Vseq_recovered = Ainv * Vabc;

fprintf('\nRecovered sequence components:\n');

fprintf('V0 = ');
disp(Vseq_recovered(1));

fprintf('V1 = ');
disp(Vseq_recovered(2));

fprintf('V2 = ');
disp(Vseq_recovered(3));

%% Test 2: Unbalanced phase voltages

Va = 1.00 * exp(1j*deg2rad(0));
Vb = 0.85 * exp(1j*deg2rad(-125));
Vc = 1.10 * exp(1j*deg2rad(115));

Vabc_original = [Va; Vb; Vc];

% Phase -> sequence
Vseq = Ainv * Vabc_original;

% Sequence -> phase
Vabc_reconstructed = A * Vseq;

fprintf('\nTest 2: Unbalanced system\n');

disp('Original phase voltages:')
disp(Vabc_original);

disp('Sequence components:')
disp(Vseq);

disp('Reconstructed phase voltages:')
disp(Vabc_reconstructed);

error = norm(Vabc_original - Vabc_reconstructed);

fprintf('Reconstruction error = %.3e\n', error);

assert(error < 1e-12);

fprintf('Unbalanced transformation test passed.\n');

%% Plot balanced positive-sequence phasors

figure;

compass(Vabc);

title('Balanced Positive-Sequence Phase Voltages');

legend('V_a','V_b','V_c');
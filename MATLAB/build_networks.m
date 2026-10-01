function [Y0,Y1,Y2,Z0,Z1,Z2] = build_networks(net)

nb = 5;

Y0 = zeros(nb);
Y1 = zeros(nb);
Y2 = zeros(nb);

%% Transmission Lines

for k = 1:size(net.line,1)

    i = net.line(k,1);
    j = net.line(k,2);

    z1 = net.line(k,3);
    z0 = net.line(k,4);

    % Positive sequence
    Y1 = addbranch(Y1,i,j,z1);

    % Negative sequence
    Y2 = addbranch(Y2,i,j,z1);

    % Zero sequence
    Y0 = addbranch(Y0,i,j,z0);

end

%% Add transformers

for k = 1:size(net.xfmr,1)

    lv = net.xfmr(k,1);
    hv = net.xfmr(k,2);
    z  = net.xfmr(k,3);

    % Positive sequence
    Y1 = addbranch(Y1,lv,hv,z);

    % Negative sequence
    Y2 = addbranch(Y2,lv,hv,z);

    % Zero sequence
    if strcmp(net.conn,'DeltaYg')

        % Delta side blocks zero sequence.
        % Line-side (Yg) bus is connected to ground
        % through transformer leakage impedance.
        Y0 = addshunt(Y0,hv,z);

    elseif strcmp(net.conn,'YgYg')

        % Both sides are grounded-wye.
        % Zero sequence can pass through transformer.
        Y0 = addbranch(Y0,lv,hv,z);

    else

        error('Unknown transformer connection: %s',net.conn);

    end

end

%% Generators

for k = 1:size(net.gen,1)

    b = net.gen(k,1);

    z1 = net.gen(k,2);
    z2 = net.gen(k,3);
    z0 = net.gen(k,4);

    % Positive sequence
    Y1 = addshunt(Y1,b,z1);

    % Negative sequence
    Y2 = addshunt(Y2,b,z2);

    % Zero sequence
    Y0 = addshunt(Y0,b,z0 + 3*net.Zn(k));

end

%% Calculate Zbus

Z0 = inv(Y0);
Z1 = inv(Y1);
Z2 = inv(Y2);

%% Display Results

%disp('Positive-sequence Ybus:');
%disp(Y1);

%disp('Negative-sequence Ybus:');
%disp(Y2);

%disp('Zero-sequence Ybus:');
%disp(Y0);

%disp('Positive-sequence Zbus:');
%disp(Z1);

%disp('Negative-sequence Zbus:');
%disp(Z2);

%disp('Zero-sequence Zbus:');
%disp(Z0);

end


%% ============================================================
% Helper function: Add series branch to Ybus
% =============================================================

function Y = addbranch(Y,i,j,z)

    y = 1/z;

    Y(i,i) = Y(i,i) + y;
    Y(j,j) = Y(j,j) + y;

    Y(i,j) = Y(i,j) - y;
    Y(j,i) = Y(j,i) - y;

end


%% ============================================================
% Helper function: Add shunt impedance to ground
% =============================================================

function Y = addshunt(Y,i,z)

    Y(i,i) = Y(i,i) + 1/z;

end
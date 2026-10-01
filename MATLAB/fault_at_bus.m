function r = fault_at_bus(k,type,Z0,Z1,Z2,Vf,Zf)

%% Input validation

if k < 1 || k > size(Z1,1) || k ~= round(k)
    error('Invalid bus number. Bus must be an integer from 1 to %d.', ...
        size(Z1,1));
end

valid_types = {'3ph','LG','LL','LLG'};

if ~ismember(type,valid_types)
    error('Invalid fault type. Use 3ph, LG, LL, or LLG.');
end

%% Faulted-bus sequence impedances

z0 = Z0(k,k);
z1 = Z1(k,k);
z2 = Z2(k,k);

%% Calculate sequence currents

switch type

    case '3ph'
        % Three-phase fault
        I1 = Vf/(z1 + Zf);
        I2 = 0;
        I0 = 0;

    case 'LG'
        % Phase A-to-ground fault
        I0 = Vf/(z0 + z1 + z2 + 3*Zf);
        I1 = I0;
        I2 = I0;

    case 'LL'
        % Phase B-C fault
        I1 = Vf/(z1 + z2 + Zf);
        I2 = -I1;
        I0 = 0;

    case 'LLG'
        % Phase B-C-to-ground fault

        zp = z2*(z0 + 3*Zf) / ...
             (z2 + z0 + 3*Zf);

        I1 = Vf/(z1 + zp);

        I2 = -I1*(z0 + 3*Zf) / ...
             (z2 + z0 + 3*Zf);

        I0 = -I1*z2 / ...
             (z2 + z0 + 3*Zf);

end

%% Sequence-to-phase transformation

a = exp(1j*2*pi/3);

A = [1 1 1;
     1 a^2 a;
     1 a a^2];

Iseq = [I0; I1; I2];

Iabc = A * Iseq;

%% Post-fault sequence voltages at all buses

V1 = Vf - Z1(:,k)*I1;

V2 = -Z2(:,k)*I2;

V0 = -Z0(:,k)*I0;

%% Convert sequence voltages to phase voltages

Vabc = A * [V0.'; V1.'; V2.'];

%% Store results

r.bus = k;
r.type = type;
r.Zf = Zf;

% Individual sequence currents
r.I0 = I0;
r.I1 = I1;
r.I2 = I2;

% Sequence current vector
r.Iseq = Iseq;

% Phase currents
r.Iabc = Iabc;

% Sequence voltages
r.V0 = V0;
r.V1 = V1;
r.V2 = V2;

% Phase voltages
r.Vabc = Vabc;

end
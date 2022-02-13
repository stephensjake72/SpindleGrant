function [NCgains, R2, Fnc, Ync, Fc, Yc] = getFYgains(data, parameters)
% constraints
init = parameters(1, :);
lower = parameters(2, :);
upper = parameters(3, :);

F = data.Fmt;
Y = data.ymt;
L = data.Lf;
V = data.vf;
time = data.time;
spiketimes = data.spiketimes;
IFR = data.IFR;

% interpolate to spiketimes
type = 'linear';
F_st = interp1(time, F, spiketimes, type);
Y_st = interp1(time, Y, spiketimes, type);
L_st = interp1(time, L, spiketimes, type);
V_st = interp1(time, V, spiketimes, type);

% cost
cost = @(gains) fy_cost(F_st, Y_st, L_st, V_st, IFR, gains);

% restrain to non-negative fiber force
nc_nlcon = @(gains) nlcon(F, L, F_st, L_st, gains);

% run optimization
options = optimoptions('fmincon', 'Display', 'off');
[NCgains, SSR] = fmincon(cost, init, [], [], [], [], lower, upper, nc_nlcon, options);

Fnc = NCgains(1)*exp(NCgains(2)*(L - NCgains(3))) + NCgains(4)*(L - NCgains(3));
Ync = NCgains(1)*NCgains(2)*V.*exp(NCgains(2)*(L - NCgains(3))) + NCgains(4)*V;
Fc = F - Fnc;
Yc = Y - Ync;
% Fc(Fc < 0) = 0;
% Yc(Yc < 0) = 0;
SST = sum((IFR - mean(IFR)).^2);
R2 = 1 - SSR/SST;

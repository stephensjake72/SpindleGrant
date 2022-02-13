function [LVAgains, R2] = getLVAgains(data, parameters, opt)
% constraints
init = parameters(1, :);
lower = parameters(2, :);
upper = parameters(3, :);

if strcmp(opt, 'MTU')
    L = data.Lmt;
    V = data.vmt;
    A = data.amt;
elseif strcmp(opt, 'FAS')
    L = data.Lf;
    V = data.vf;
    A = data.af;
end
time = data.time;
spiketimes = data.spiketimes;
IFR = data.IFR;

% interpolate to spiketimes
type = 'linear';
L_st = interp1(time, L, spiketimes, type);
V_st = interp1(time, V, spiketimes, type);
A_st = interp1(time, A, spiketimes, type);

% cost
cost = @(gains) lva_cost(L_st, V_st, A_st, IFR, gains);

% run optimization
options = optimoptions('fmincon', 'Display', 'off');
[LVAgains, SSR] = fmincon(cost, init, [], [], [], [], lower, upper, [], options);

SST = sum((IFR - mean(IFR)).^2);
R2 = 1 - SSR/SST;

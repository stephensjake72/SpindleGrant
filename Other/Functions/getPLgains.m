function [PLgains, R2] = getPLgains(data, parameters, opt)
% constraints
init = parameters(1, :);
lower = parameters(2, :);
upper = parameters(3, :);

if strcmp(opt, 'MTU')
    V = data.vmt;
elseif strcmp(opt, 'FAS')
    V = data.vf;
end
time = data.time;
spiketimes = data.spiketimes;
IFR = data.IFR;

% interpolate to spiketimes
type = 'linear';
V_st = interp1(time, V, spiketimes, type);

% cost
cost = @(gains) pl_cost(V_st, IFR, gains);

% run optimization
options = optimoptions('fmincon', 'Display', 'off');
[PLgains, SSR] = fmincon(cost, init, [], [], [], [], lower, upper, [], options);

SST = sum((IFR - mean(IFR)).^2);
R2 = 1 - SSR/SST;

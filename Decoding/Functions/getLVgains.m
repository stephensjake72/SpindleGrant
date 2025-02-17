function fit = getLVgains(data, parameters)

L = data.Lf;
V = data.dLf;

% constraints
init = parameters(1, :);
lower = parameters(2, :);
upper = parameters(3, :);

% time and spike data
time = data.time;
spiketimes = data.spiketimes;
ifr = data.ifr;

cost = @(gains) lv_cost(L, V, time, spiketimes, ifr, gains);
 
% run optimization
options = optimoptions('fmincon', 'Display', 'off');
[LVgains, ~] = fmincon(cost, init, [], [], [], [], lower, upper, [], options);
 
% time series fitting data
fit.time = data.time;
fit.spiketimes = data.spiketimes;
fit.ifr = data.ifr;
fit.L = L;
fit.V = V;

% coefficients
fit.kL = LVgains(1);
fit.kV = LVgains(2);
 
% currents
rL = fit.kL*fit.L;
rV = fit.kV*fit.V;
rL(rL < 0) = 0;
rV(rV < 0) = 0;

fit.Lcomp = rL;
fit.Vcomp = rV;

% predictor
fit.predictor = rL + rV;

% error metrics
p = interp1(time, fit.predictor, spiketimes); %interpolated predictor
C = corrcoef(p, ifr); % correlation coefficients
fit.R = C(2, 1); % corr. coeff. of predictor and IFR
fit.R2 = C(2, 1)^2; % square corr. coeff.
fit.resid = ifr - p; % residual errors
n = length(ifr);
k = length(LVgains(LVgains ~=0));
fit.R2adj = 1 - (1 - fit.R2)*(n - 1)/(n - k - 1); % adjusted R2
fit.VAF = 1-(var(fit.resid)/var(ifr)); % variance accounted for
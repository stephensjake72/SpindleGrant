function fit = getLVgainsMTU(data, parameters)

L = data.Lmt;
V = data.dLmt;

% constraints
init = parameters(1, :);
lower = parameters(2, :);
upper = parameters(3, :);

% time and spike data
time = data.time;
spiketimes = data.spiketimes(data.spiketimes > time(1));
ifr = data.ifr;

cost = @(gains) lv_cost(L, V, time, spiketimes, ifr, gains);
 
% run optimization
options = optimoptions('fmincon', 'Display', 'off');
[LVgains, ~] = fmincon(cost, init, [], [], [], [], lower, upper, [], options);
 
% time series fitting data
fit.time = data.time;
fit.spiketimes = data.spiketimes(data.spiketimes > fit.time(1));
fit.ifr = data.ifr(data.spiketimes > fit.time(1));
fit.L = L;
fit.V = V;

% coefficients
fit.kL = LVgains(1);
fit.kV = LVgains(2);
fit.b = LVgains(3);
 
% currents
fit.Lcomp = fit.kL*fit.L;
fit.Vcomp = fit.kV*fit.V;

% predictor
p = fit.Lcomp + fit.Vcomp + fit.b;
p(p < 0) = 0;
fit.predictor = p;

% error metrics
pst = interp1(fit.time, fit.predictor, fit.spiketimes); % interpolated predictor
C = corrcoef(pst, fit.ifr); % correlation coefficients

fit.R = C(2, 1); % corr. coeff. of predictor and IFR
fit.R2 = C(2, 1)^2; % square corr. coeff.
fit.resid = fit.ifr - pst; % residual errors

n = length(fit.ifr);
k = length(LVgains(LVgains ~=0));
fit.R2adj = 1 - (1 - fit.R2)*(n - 1)/(n - k - 1); % adjusted R2
fit.VAF = 1-(var(fit.resid)/var(fit.ifr)); % variance accounted for
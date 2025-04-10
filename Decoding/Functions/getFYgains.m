function fit = getFYgains(data, NC, parameters)

% constraints
init = parameters(1, :);
lower = parameters(2, :);
upper = parameters(3, :);

% time and spike data
time = data.time;
spiketimes = data.spiketimes;
ifr = data.ifr;

% cost
cost = @(gains) fy_cost(data.Fmt, data.dFmt, data.Lmt, data.dLmt, NC, time, spiketimes, ifr, gains);
 
% run optimization
options = optimoptions('fmincon', 'Display', 'off');
[FYgains, ~] = fmincon(cost, init, [], [], [], [], lower, upper, [], options);

% pull out constants
fit.kF = FYgains(1);
fit.kdF = FYgains(2);
fit.b = FYgains(3);
fit.L0 = FYgains(4);

fit.A = NC.A;
fit.kexp = NC.kexp;
fit.klin = NC.klin;
fit.lambda = 0;

% compute nc components
expcomp = NC.A*exp(NC.kexp*(data.Lmt - fit.L0));
fit.Fnc =  expcomp + NC.klin*(data.Lmt - fit.L0);
fit.dFnc = NC.kexp*data.dLmt.*expcomp + NC.klin*data.dLmt;
fit.Fc = data.Fmt - fit.Fnc;
fit.dFc = data.dFmt - fit.dFnc;
fit.Fmt = data.Fmt;
fit.dFmt = data.dFmt;

% time series fitting data
fit.time = data.time;
fit.Lmt = data.Lmt;
fit.spiketimes = data.spiketimes(data.spiketimes > time(1));
fit.ifr = data.ifr(data.spiketimes > time(1));
 
% currents
fit.rF = fit.kF*fit.Fc;
fit.rdF = fit.kdF*fit.dFc;

% predictor
pred = fit.rF + fit.rdF + fit.b;
pred(pred < 0) = 0;
fit.predictor = pred;

% error metrics
pst = interp1(fit.time, fit.predictor, fit.spiketimes); %interpolated predictor
fit.pred_s = pst;

C = corrcoef(pst, fit.ifr); % correlation coefficients
fit.R = C(2, 1); % corr. coeff. of predictor and IFR
fit.R2 = C(2, 1)^2; % square corr. coeff.
fit.resid = fit.ifr - pst; % residual errors

n = length(fit.ifr);
k = length(FYgains(FYgains ~=0));
fit.R2adj = 1 - (1 - fit.R2)*(n - 1)/(n - k - 1); % adjusted R2
fit.VAF = 1-(var(fit.resid)/var(fit.ifr)); % variance accounted for



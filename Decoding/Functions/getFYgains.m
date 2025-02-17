function fit = getFYgains(data, NC, parameters)

% compute NC force and yank
expcomp = NC.A*exp(NC.kexp*(data.Lmt - NC.L0));
Fnc = expcomp + NC.klin*(data.Lmt - NC.L0);
Ync = NC.kexp*data.dLmt.*expcomp + NC.klin*data.dLmt;

Fc = data.Fmt - Fnc;
Yc = data.dFmt - Ync;

% constraints
init = parameters(1, :);
lower = parameters(2, :);
upper = parameters(3, :);

% time and spike data
time = data.time;
spiketimes = data.spiketimes;
ifr = data.ifr;

% interpolate ifr to time to create a curve rather than discrete points
% need to add "anchor points" at time t = -5, t = 0 and t = 2 to keep
% extrapolation from going insane
% ifrint = interp1([min(time); 0; spiketimes; max(time)], [0; 0; ifr; 0], time, 'pchip', 'extrap');
% ifrint = ifrint';
% ifrint = smooth
% cost
cost = @(gains) fy_cost(Fc, Yc, time, spiketimes, ifr, gains);
 
% run optimization
options = optimoptions('fmincon', 'Display', 'off');
[FYgains, ~] = fmincon(cost, init, [], [], [], [], lower, upper, [], options);
 
% time series fitting data
fit.time = data.time;
fit.spiketimes = data.spiketimes;
fit.ifr = data.ifr;
fit.Fc = Fc;
fit.Yc = Yc;
fit.Fmt = data.Fmt;
fit.dFmt = data.dFmt;
fit.Lmt = data.Lmt;

% coefficients
fit.A = NC.A;
fit.kexp = NC.kexp;
fit.L0 = NC.L0;
fit.klin = NC.klin;
fit.kF = FYgains(1);
fit.kY = FYgains(2);
fit.bF = FYgains(3);
fit.bY = FYgains(4);
fit.lambda = 0;
 
% currents
rF = fit.kF*(fit.Fc + fit.bF);
rY = fit.kY*(fit.Yc + fit.bY);
rF(rF < 0) = 0;
rY(rY < 0) = 0;

fit.Fcomp = rF;
fit.Ycomp = rY;

% predictor
fit.predictor = rF + rY;

% error metrics
p = interp1(time, fit.predictor, spiketimes); %interpolated predictor
C = corrcoef(p, ifr); % correlation coefficients
fit.R = C(2, 1); % corr. coeff. of predictor and IFR
fit.R2 = C(2, 1)^2; % square corr. coeff.
fit.resid = ifr - p; % residual errors
n = length(ifr);
k = length(FYgains(FYgains ~=0));
fit.R2adj = 1 - (1 - fit.R2)*(n - 1)/(n - k - 1); % adjusted R2
fit.VAF = 1-(var(fit.resid)/var(ifr)); % variance accounted for



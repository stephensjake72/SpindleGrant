function fit = getFYgains_CB(data, spiketimes, ifr, parameters)

% load force data, offset, and scale
Fb = (data.force.bag - data.force.bag(1900))/1e5;
Yb = (data.yank.bag - data.yank.bag(1900))/1e5;
Fc = (data.force.chain - data.force.chain(1900))/1e5;
Yc = (data.yank.chain - data.yank.chain(1900))/1e5;

% time shift for the crossbridge model
data.t = data.t - 2; % time pt of stretch start

% time shift for spiketimes
tstart = .075;
spiketimes = spiketimes - tstart;

% ignore spikes after the end of the sim
stwin = spiketimes < max(data.t);
spiketimes = spiketimes(stwin);
ifr = ifr(stwin);

% interpolate sim traces to spiketimes
Fb_st = interp1(data.t, Fb, spiketimes);
Yb_st = interp1(data.t, Yb, spiketimes);
Fc_st = interp1(data.t, Fc, spiketimes);
Yc_st = interp1(data.t, Yc, spiketimes);

% constraints
init = parameters(1, :);
lower = parameters(2, :);
upper = parameters(3, :);

% cost
cost = @(gains) fy_cost_CB(Fc_st, Fb_st, Yb_st, Yc_st, ifr, gains);

% run optimization
options = optimoptions('fmincon', 'Display', 'iter');
[FYgains, ~] = fmincon(cost, init, [], [], [], [], lower, upper, [], options);
 
% time series fitting data
fit.time = data.t;
fit.spiketimes = spiketimes;
fit.ifr = ifr;
fit.Fc = Fc;
fit.Yc = Yc;
fit.Fb = Fb;
fit.Yb = Yb;

% coefficients
fit.kFc = FYgains(1);
fit.kFb = FYgains(2);
fit.kYb = FYgains(3);
fit.kYc = FYgains(4);

% time shift
fit.lamda = tstart;

% currents
rD = (fit.kFb*fit.Fb) + (fit.kYb*fit.Yb);
rS = (fit.kFc*fit.Fc) + (fit.kYc*fit.Yc);

% predictor
fit.predictor = rD + rS;

% error metrics
p = fit.kFb*Fb_st + fit.kYb*Yb_st + fit.kFc*Fc_st + fit.kYc*Yc_st; %interpolated predictor
C = corrcoef(p, ifr); % correlation coefficients
fit.R = C(2, 1); % corr. coeff. of predictor and IFR
fit.R2 = C(2, 1)^2; % square corr. coeff.
fit.resid = ifr - p; % residual errors
fit.VAF = 1-(var(fit.resid)/var(ifr)); % variance accounted for



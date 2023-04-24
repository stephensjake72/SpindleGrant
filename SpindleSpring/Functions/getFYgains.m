 function fit = getFYgains(data, parameters, type)
% constraints
init = parameters(1, :);
lower = parameters(2, :);
upper = parameters(3, :);

F = data.Fmt;
Y = data.ymt;
if strcmp(type, 'Blum')
    L = data.Lmt;
    V = data.vmt;
elseif strcmp(type, 'Fas')
    L = data.Lf;
    V = data.vf;
end
time = data.time;
spiketimes = data.spiketimes;
ifr = data.ifr;

% cost
cost = @(gains) fy_cost(F, Y, L, V, time, spiketimes, ifr, gains);

% restrain to non-negative fiber force
if lower(1:4) == upper(1:4) % if constants are fixed
    nc_nlcon = [];
else
    nc_nlcon = @(gains) nlcon(F, Y, L, V, time, spiketimes, gains); 
end

% run optimization
options = optimoptions('fmincon', 'Display', 'off');
[FYgains, ~] = fmincon(cost, init, [], [], [], [], lower, upper, nc_nlcon, options);

% time series fitting data
fit.F = F;
fit.Y = Y;
fit.L = L;
fit.V = V;
fit.time = time;
fit.spiketimes = spiketimes;
fit.ifr = ifr;
% coefficients
fit.A = FYgains(1);
fit.k_exp = FYgains(2);
fit.L0 = FYgains(3);
fit.k_lin = FYgains(4);
fit.kF = FYgains(5);
fit.kY = FYgains(6);
fit.bF = FYgains(7);
fit.bY = FYgains(8);
fit.lambda = FYgains(9);
% optimized data
fit.Fnc = fit.A*exp(fit.k_exp*(L - fit.L0)) + fit.k_lin*(L - fit.L0);
fit.Ync = fit.A*fit.k_exp*V.*exp(fit.k_exp*(L - fit.L0)) + fit.k_lin*V;
fit.Fc = fit.F - fit.Fnc;
fit.Yc = fit.Y - fit.Ync;

% currents
rChain = fit.kF*(fit.Fc + fit.bF); % scale
rBag = fit.kY*(fit.Yc + fit.bY);
rChain(rChain < 0) = 0; % rectify
rBag(rBag < 0) = 0;
rT = rChain + rBag; % sum

% occlusion
occChain = 1 + (rChain - rBag).*rT/5e5;
occChain(occChain > 1) = 1;
occBag = 1 + (rBag - rChain).*rT/5e5;
occBag(occBag > 1) = 1;

fit.occChain = occChain;
fit.occBag = occBag;
fit.chainComp = rChain.*occChain;
fit.bagComp = rBag.*occBag;

% cost
fit.predictor = fit.chainComp + fit.bagComp;
% error metrics
p = interp1(time + fit.lambda, fit.predictor, spiketimes); %interpolated predictor
C = corrcoef(p, ifr); % correlation coefficients
fit.R = C(2, 1); % corr. coeff. of predictor and IFR
fit.R2 = C(2, 1)^2; % square corr. coeff.
fit.resid = ifr - p; % residual errors
fit.SSR = sum((ifr - p).^2);
n = length(ifr);
k = length(FYgains(FYgains ~=0));
fit.R2adj = 1 - (1 - fit.R2)*(n - 1)/(n - k - 1); % adjusted R2
fit.VAF = 1-(var(ifr - p)/var(ifr)); % variance accounted for


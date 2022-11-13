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
IFR = data.IFR;

% cost
cost = @(gains) fy_cost(F, Y, L, V, time, spiketimes, IFR, gains);

% restrain to non-negative fiber force
if lower(1:4) == upper(1:4)
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

% % occlusion
% Fcomp = fit.kF*(fit.Fc + fit.bF);
% Ycomp = fit.kY*(fit.Yc + fit.bY);
% Fcomp(Fcomp < 0) = 0;
% Ycomp(Ycomp < 0) = 0;
% occ = smooth(Ycomp - Fcomp, 1);
% occ(occ < 0) = 0;
% occ = occ/max(occ);
% occ = occ.^2;
% occ = occ/2 + 0.5;
% Yocc = occ;
% Focc = 1 - Yocc;
% Fcomp = Fcomp.*Focc;
% Ycomp = Ycomp.*Yocc;
% fit.occlusion = occ;
% fit.Fcomp = Fcomp;
% fit.Ycomp = Ycomp;
% fit.predictor = fit.Fcomp + fit.Ycomp;

% currents
rF = fit.kF*(fit.Fc + fit.bF);
rY = fit.kY*(fit.Yc + fit.bY);
rF(rF < 0) = 0;
rY(rY < 0) = 0;
rT = rF + rY;
% occlusion
sf = 50;
fit.Focclusion = smooth(rF./rT, sf);
fit.Yocclusion = smooth(rY./rT, sf);
% components
fit.Fcomp = rF.*fit.Focclusion;
fit.Ycomp = rY.*fit.Yocclusion;
% predictor
fit.predictor = fit.Fcomp + fit.Ycomp;
% error metrics
p = interp1(time + fit.lambda, fit.predictor, spiketimes); %interpolated predictor
C = corrcoef(p, IFR); % correlation coefficients
fit.R = C(2, 1); % corr. coeff. of predictor and IFR
fit.R2 = C(2, 1)^2; % square corr. coeff.
fit.resid = IFR - p; % residual errors
n = length(IFR);
k = length(FYgains(FYgains ~=0));
fit.R2adj = 1 - (1 - fit.R2)*(n - 1)/(n - k - 1); % adjusted R2
fit.VAF = 1-(var(IFR - p)/var(IFR)); % variance accounted for


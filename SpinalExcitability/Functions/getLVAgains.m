function fit = getLVAgains(data, parameters, opt)
% constraints
init = parameters(1, :);
lower = parameters(2, :);
upper = parameters(3, :);

if strcmp(opt, 'MTU')
    L = data.Lmt;
    V = data.vmt;
    A = data.amt;
elseif strcmp(opt, 'Fas')
    L = data.Lf;
    V = data.vf;
    A = data.af;
end
time = data.time;
spiketimes = data.spiketimes;
IFR = data.IFR;

% cost
cost = @(gains) lva_cost(L, V, A, time, spiketimes, IFR, gains);

% run optimization
options = optimoptions('fmincon', 'Display', 'off');
[LVAgains, ~] = fmincon(cost, init, [], [], [], [], lower, upper, [], options);

% time series fit data
fit.L = L;
fit.V = V;
fit.A = A;
% constants
fit.kL = LVAgains(1);
fit.kV = LVAgains(2);
fit.kA = LVAgains(3);
fit.bL = LVAgains(4);
fit.bV = LVAgains(5);
fit.bA = LVAgains(6);
fit.lambda = LVAgains(7);
% currents
rL = fit.kL*(fit.L + fit.bL);
rV = fit.kV*(fit.V + fit.bV);
rA = fit.kA*(fit.A + fit.bA);
rL(rL < 0) = 0; % rectify
rV(rV < 0) = 0;
rA(rA < 0) = 0;
rT = rL + rV + rA;
% occlusion
fit.Locclusion = rL./rT;
fit.Vocclusion = rV./rT;
fit.Aocclusion = rA./rT;
% components
fit.Lcomp = rL.*fit.Locclusion;
fit.Vcomp = rV.*fit.Vocclusion;
fit.Acomp = rA.*fit.Aocclusion;
% predictor
fit.predictor = fit.Lcomp + fit.Vcomp + fit.Acomp;
% error metrics
p = interp1(time + fit.lambda, fit.predictor, spiketimes);
C = corrcoef(p, IFR);
fit.R = C(2, 1);
fit.R2 = C(2, 1)^2;
fit.resid = IFR - p;
n = length(IFR);
k = length(LVAgains(LVAgains ~=0));
fit.R2adj = 1 - (1 - fit.R2)*(n - 1)/(n - k - 1);
fit.VAF = 1-(var(IFR - p)/var(IFR));


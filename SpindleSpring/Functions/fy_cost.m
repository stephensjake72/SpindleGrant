function MTcost = fy_cost(F, Y, L, V, time, spiketimes, ifr, gains)
A = gains(1);
k_exp = gains(2);
L0 = gains(3);
k_lin = gains(4);
kF = gains(5);
kY = gains(6);
bF = gains(7);
bY = gains(8);
lambda = gains(9);

% interpolate to spiketimes
type = 'linear';
F_st = interp1((time + lambda), F, spiketimes, type);
Y_st = interp1((time + lambda), Y, spiketimes, type);
L_st = interp1((time + lambda), L, spiketimes, type);
V_st = interp1((time + lambda), V, spiketimes, type);

% contractile force and yank
Fc = F_st - A*exp(k_exp*(L_st - L0)) - k_lin*(L_st - L0);
Yc = Y_st - A*k_exp*V_st.*exp(k_exp*(L_st - L0)) - k_lin*V_st;

% currents
rChain = kF*(Fc + bF); % scale
rBag = kY*(Yc + bY);
rChain(rChain < 0) = 0; % rectify
rBag(rBag < 0) = 0;
rT = rChain + rBag; % sum

% occlusion
occChain = 1 + (rChain - rBag).*rT/5e5;
occChain(occChain > 1) = 1;
occBag = 1 + (rBag - rChain).*rT/5e5;
occBag(occBag > 1) = 1;

% components
chainComp = rChain.*occChain;
bagComp = rBag.*occBag;

% cost
predictor = chainComp + bagComp;
residuals = (ifr- predictor).^2;
iberror = residuals(spiketimes < 1.02);
stretcherror = residuals(spiketimes >= 1.02 & spiketimes < 1.15);
staticerror = residuals(spiketimes >= 1.15);

% weight = IFR;
MTcost = sum(iberror) + sum(stretcherror) + sum(staticerror);
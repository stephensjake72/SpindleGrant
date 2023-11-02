function MTcost = lva_cost(L, V, A, time, spiketimes, IFR, gains)
kL = gains(1);
kV = gains(2);
kA = gains(3);
bL = gains(4);
bV = gains(5);
bA = gains(6);
lambda = gains(7);

% interpolate to spiketimes
type = 'linear';
L_st = interp1((time + lambda), L, spiketimes, type);
V_st = interp1((time + lambda), V, spiketimes, type);
A_st = interp1((time + lambda), A, spiketimes, type);

% currents
rL = kL*(L_st + bL);
rV = kV*(V_st + bV);
rA = kA*(A_st + bA);
rL(rL < 0) = 0; % rectify
rV(rV < 0) = 0;
rA(rA < 0) = 0;
rT = rL + rV + rA;

% occlusion
oL = rL./rT;
oV = rV./rT;
oA = rA./rT;

% components
Lcomp = rL.*oL;
Vcomp = rV.*oV;
Acomp = rA.*oA;

predictor = Lcomp + Vcomp + Acomp;
residuals = (predictor - IFR).^2;
swayerror = residuals(spiketimes < 0);
ramperror = residuals(spiketimes >= 0);

MTcost = sum(swayerror) + 10*sum(ramperror);
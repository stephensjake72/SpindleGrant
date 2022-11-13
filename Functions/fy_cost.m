function MTcost = fy_cost(F, Y, L, V, time, spiketimes, IFR, gains)
A = gains(1);
k_exp = gains(2);
L0 = gains(3);
k_lin = gains(4);
kF = gains(5);
kY = gains(6);
bF = gains(7);
bY = gains(8);
lambda = gains(9);
% of = gains(10);

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
rF = kF*(Fc + bF);
rY = kY*(Yc + bY);
rF(rF < 0) = 0;
rY(rY < 0) = 0;
rT = rF + rY;

% occlusion
sf = 50;
oF = smooth(rF./rT, sf);
oY = smooth(rY./rT, sf);

% components
Fcomp = rF.*oF;
Ycomp = rY.*oY;

% Fcomp = kF*(Fc + bF);
% Ycomp = kY*(Yc + bY);
% Fcomp(Fcomp < 0) = 0;
% Ycomp(Ycomp < 0) = 0;
% 
% % occlusion
% occ = smooth(Ycomp - Fcomp, 1);
% occ(occ < 0) = 0;
% occ = occ/max(occ);
% occ = occ.^2;
% occ = occ/2 + 0.5;
% Yocc = occ;
% Focc = 1 - Yocc;
% Fcomp = Fcomp.*Focc;
% Ycomp = Ycomp.*Yocc;

% cost
predictor = Fcomp + Ycomp;
residuals = (predictor - IFR).^2;
swayerror = residuals(spiketimes < 0);
ramperror = residuals(spiketimes >= 0);

% weight = IFR;
MTcost = sum(swayerror) + 10*sum(ramperror);
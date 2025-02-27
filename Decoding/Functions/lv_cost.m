function MTcost = lv_cost(L, V, time, spiketimes, IFR, gains)
kL = gains(1);
kV = gains(2);

% interpolate to spiketimes
type = 'linear';
L_st = interp1(time, L, spiketimes, type);
V_st = interp1(time, V, spiketimes, type);

% currents
rL = kL*L_st;
rV = kV*V_st;
rL(rL < 0) = 0; % rectify
rV(rV < 0) = 0;
rT = rL + rV;

residuals = (rT - IFR).^2;
MTcost = sum(residuals);
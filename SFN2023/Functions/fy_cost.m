function MTcost = fy_cost(F, Y, time, spiketimes, ifr, gains)
kF = gains(1);
kY = gains(2);
bF = gains(3);
lambda = gains(4);

% interpolate to spiketimes
type = 'linear';
F_st = interp1((time + lambda), F, spiketimes, type);
Y_st = interp1((time + lambda), Y, spiketimes, type);
 
% currents
rChain = kF*(F_st + bF); % scale
rBag = kY*Y_st;
rChain(rChain < 0) = 0; % rectify
rBag(rBag < 0) = 0;
 
% cost
predictor = rChain + rBag;
sqRes = (ifr - predictor).^2;
 
% weight = IFR;
MTcost = sum(sqRes);
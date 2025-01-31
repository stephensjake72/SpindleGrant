function MTcost = fy_cost(F, Y, time, spiketimes, ifr, gains)
kF = gains(1);
kY = gains(2);
bF = gains(3);
bY = gains(4);
% lambda = 0;
ifr = ifr(spiketimes > time(1));
spiketimes = spiketimes(spiketimes > time(1));

% currents
rF = kF*(F + bF); % scale
rY = kY*(Y + bY);
rF(rF<0) = 0; % rectify
rY(rY < 0) = 0;

% cost
predictor = rF + rY;
pred_s = interp1(time, predictor, spiketimes);
sqRes = (ifr - pred_s).^2;

% ibsqRes = sqRes(time < .1 & time > .06);

% weight = IFR;
MTcost = sum(sqRes);% + 100*sum(ibsqRes);
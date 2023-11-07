function MTcost = fy_cost(F, Y, time, spiketimes, ifrint, gains)
kF = gains(1);
kY = gains(2);
bF = gains(3);
bY = gains(4);
% lambda = gains(4);

% currents
rChain = kF*(F + bF); % scale
rBag = kY*(Y + bY);
rChain(rChain < 0) = 0; % rectify
rBag(rBag < 0) = 0;

% cost
predictor = rChain + rBag;
sqRes = (ifrint - predictor).^2;

% ibsqRes = sqRes(time < .1 & time > .06);

% weight = IFR;
MTcost = sum(sqRes);% + 100*sum(ibsqRes);
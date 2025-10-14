function MTcost = fy_cost_CB(Fc_st, Fb_st, Yb_st, Yc_st, ifr, gains)
kFc = gains(1);
kFb = gains(2);
kYb = gains(3);
kYc = gains(4);
% lambda = gains(4);

% cost
predictor = (kFc*Fc_st) + (kFb*Fb_st) + (kYc*Yc_st) + (kYb*Yb_st);
sqRes = (ifr - predictor).^2;

% ibsqRes = sqRes(time < .1 & time > .06);

% weight = IFR;
MTcost = sum(sqRes);% + 100*sum(ibsqRes);
function MTcost = pl_cost(V_st, IFR, gains)
kV = gains(1);
kP = gains(2);
bV = gains(3);

predictor = kV*(V_st^kP) + bV;
MTcost = sum((IFR - predictor).^2);
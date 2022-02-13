function MTcost = lva_cost(L_st, V_st, A_st, IFR, gains)
kL = gains(1);
kV = gains(2);
kA = gains(3);
bL = gains(4);
bV = gains(5);
bA = gains(6);

predictor = kL*(L_st + bL) + kV*(V_st + bV) + kA*(A_st + bA);
MTcost = sum((IFR - predictor).^2);
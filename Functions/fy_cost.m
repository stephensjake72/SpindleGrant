function MTcost = fy_cost(F_st, Y_st, L_st, V_st, IFR, gains)
A = gains(1);
k_exp = gains(2);
L0 = gains(3);
kL = gains(4);
kF = gains(5);
kY = gains(6);
bF = gains(7);
bY = gains(8);

% contractile force and yank
Fc = F_st - A*exp(k_exp*(L_st - L0)) - kL*(L_st - L0);
Yc = Y_st - A*k_exp*V_st.*exp(k_exp*(L_st - L0)) - kL*V_st;

% half-wave rectify force and yank
% Fc(Fc < 0) = 0;
% Yc(Yc < 0) = 0;

% cost
predictor = kF*(Fc + bF) + kY*(Yc + bY);
MTcost = sum((IFR - predictor).^2);
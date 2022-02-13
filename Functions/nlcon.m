function [c, ceq] = nlcon(F, L, F_st, L_st, gains)
% use data interpolated at spiketimes to ensure muscle is in tension when
% spiking occurs
Fnc_st = gains(1)*exp(gains(2)*(L_st - gains(3)));
Fc_st = F_st - Fnc_st;
c(1) = -min(Fc_st);

% use normal data to constrain force to be in tension at rest as is
% consistent with experiment design
Fc_rest = F(1) - gains(1)*exp(gains(2)*(L(1) - gains(3)));
c(2) = -Fc_rest;

% no eq constraints
ceq = [];
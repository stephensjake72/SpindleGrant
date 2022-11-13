function [c, ceq] = nlcon(F, Y, L, V, time, spiketimes, gains)
% interpolate to spiketimes
type = 'linear';
F_st = interp1((time + gains(9)), F, spiketimes, type);
L_st = interp1((time + gains(9)), L, spiketimes, type);

% use data interpolated at spiketimes to ensure muscle is in tension when
% spiking occurs
Fnc_st = gains(1)*exp(gains(2)*(L_st - gains(3))) + gains(4)*(L_st - gains(3));
Fnc = gains(1)*exp(gains(2)*(L - gains(3))) + gains(4)*(L - gains(3));
Ync = gains(1)*gains(2)*exp(gains(2)*(L - gains(3))).*V + gains(4)*V;
Fc_st = F_st - Fnc_st;
c(1) = -min(Fc_st);

% use normal data to constrain force to be in tension at rest as is
% consistent with experiment design
Fc_rest = F(1) - gains(1)*exp(gains(2)*(L(1) - gains(3))) - gains(4)*(L(1) - gains(3));
c(2) = -Fc_rest;

% VAF constraints
VAF = 1 - sum((F - Fnc).^2)/sum(F.^2);
c(3) = VAF - .7;
c(4) = .3 - VAF;

% no eq constraints
ceq = [];
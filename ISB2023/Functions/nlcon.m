function [c, ceq] = nlcon(F, L, gains)
Fnc = gains(1)*exp(gains(2)*(L - gains(3))) + gains(4)*(L - gains(3));
c(1) = max(Fnc - F);
c(2) = max(Fnc) - 0.5*max(F);
c(3) = .3*max(F) - max(Fnc);
ceq = [];
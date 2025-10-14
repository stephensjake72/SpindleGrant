function [c, ceq] = nlcon(F, L, gains)
% NC force eq
Fnc = gains(1)*exp(gains(2)*(L - gains(3))) + gains(4)*(L - gains(3));

% FNC must be non-negative
c(1) = -min(Fnc); % min(Fnc) >= 0 -> -min(Fnc) <= 0

% Fc must be non-negative
c(2) = -min(F - Fnc);

% initial NC component is 0
ceq = min(Fnc);
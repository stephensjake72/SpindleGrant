function [c, ceq] = spikeint_nlcon(s1, s2, K)
c = -min(K(1, 1)*s1 + K(1, 2)*s2);
ceq = 0;
end
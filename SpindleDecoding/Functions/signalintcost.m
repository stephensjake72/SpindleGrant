function cost = signalintcost(s1, s2, K)

x1 = K(1, 1)*s1 + K(1, 2)*s2;
x2 = K(2, 1)*s1 + K(2, 2)*s2;

intx2 = cumtrapz(x2) + x1(1);
cost = sum((x1 - intx2).^2);
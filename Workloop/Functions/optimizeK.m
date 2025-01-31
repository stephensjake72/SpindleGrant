function K = optimizeK(s1, s2)

cost = @(K) signalintcost(s1, s2, K);
nlcon = @(K) spikeint_nlcon(s1, s2, K);
init = [-.001, .01; .11, -.1];

options = optimoptions('fmincon', 'Display', 'off');

[K, ~] = fmincon(cost, init, [], [], [], [], [], [], nlcon, options);
function NC = getNCparameters(data)

% A kexp L0 kF
init = [.011 1.42 0.26 100];
lower = [.005 1.00 0.10 20];
upper = [.020 1.75 0.40 200];

cost = @(gains) nc_cost(data, gains);

options = optimoptions('fmincon', 'Display', 'off');
[NCgains, ~] = fmincon(cost, init, [], [], [], [], lower, upper, [], options);

NC.A = NCgains(1);
NC.kexp = NCgains(2);
NC.L0 = NCgains(3);
NC.kF = NCgains(4);
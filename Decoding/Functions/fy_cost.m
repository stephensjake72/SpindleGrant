function MTcost = fy_cost(F, Y, L, V, NC, time, spiketimes, ifr, gains)
kF = gains(1);
kY = gains(2);
b = gains(3);
L0 = gains(4);

% lambda = 0;
ifr = ifr(spiketimes > time(1));
spiketimes = spiketimes(spiketimes > time(1));

% compute NC force and yank
expcomp = NC.A*exp(NC.kexp*(L - L0));
Fnc =  expcomp + NC.klin*(L - L0);
Ync = NC.kexp*V.*expcomp + NC.klin*L;

Fc = F - Fnc;
Yc = Y - Ync;

% currents
rF = kF*Fc; % scale
rY = kY*Yc;
p = rF + rY + b; % sum w offset
p(p < 0) = 0;

% rF(rF<0) = 0; % rectify
% rY(rY < 0) = 0;

% cost
pred_s = interp1(time, p, spiketimes);
sqRes = (ifr - pred_s).^2;

% additionally penalize actvity before spike onset
prewin = time < spiketimes(1);
if sum(prewin) > 1
    prespiket = time(prewin);
    prespikey = p(prewin);
    prespikecost = trapz(prespiket, prespikey);
else
    prespikecost = p(1);
end
% and after
postwin = time > spiketimes(end);
if sum(postwin) > 1
    postspiket = time(postwin);
    postspikey = p(postwin);
    postspikecost = trapz(postspiket, postspikey);
else
    postspikecost = p(end);
end

% ibsqRes = sqRes(time < .1 & time > .06);

% weight = IFR;
MTcost = sum(sqRes) + 7.5e2*(prespikecost + postspikecost);% + 100*sum(ibsqRes);
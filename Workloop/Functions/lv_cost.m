function MTcost = lv_cost(L, V, time, spiketimes, ifr, gains)
kL = gains(1);
kV = gains(2);
b = gains(3);

ifr = ifr(spiketimes > time(1));
spiketimes = spiketimes(spiketimes > time(1));

% currents
rL = kL*L;
rV = kV*V;
p = rL + rV + b;
p(p < 0) = 0; % half  wave rectify

% interpolate to spiketimes
type = 'linear';
pred_s = interp1(time, p, spiketimes, type);

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

residuals = (pred_s - ifr);
MTcost = sum(residuals.^2) + 7.5e2*(prespikecost + postspikecost);
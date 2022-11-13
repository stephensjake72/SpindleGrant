function MTcost = getforcecost(time, Fmt, Lmt, spikerec, gains)
% non-contractile force
Fnc = gains(1)*exp(gains(2)*(Lmt-gains(3)));

% force and yank
Fm = Fmt - Fnc;
[Ytime, Ym] = getfiltyank(time, Fm, 200);

% get IFR
[spiketimes, IFR] = findIFR(time, spikerec);

% downsample to spiketimes
Fm = Fm(spikerec == 1);
Ym = Ym(spikerec == 1);
Ym(Ym < 0) = 0;

% sum
FYsum = Fm*gains(4) + Ym*gains(5);

% get initial burst
IBA = max(IFR(spiketimes < 1));
IBtime = spiketimes(IFR == IBA);

% generate weighting function
weight = genweightfn(time, spiketimes, IFR);

% get fit error
errors = (IFR - FYsum).^2;

% get total weighted error
MTcost = sum(errors.*weight);
function dr = computedynamicresponse(data)
stretchv = floor(max(data.dLmt));
tstart = 0.1;
tstop = tstart + 3/stretchv;
drinds = find(data.spiketimes > tstart & data.spiketimes < tstop);
dr = max(data.ifr(drinds));
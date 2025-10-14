function sr = computestaticresponse(data)
stretchv = floor(max(data.dLmt));
tstart = 3/stretchv + .48;
tstop = 3/stretchv + .52;
srinds = find(data.spiketimes > tstart & data.spiketimes < tstop);
sr = mean(data.ifr(srinds));
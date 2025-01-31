function sc = computeTriSC(spiketimes)
sc = zeros(1, 3);
breaks = [0 1.5 3 4.5];
sc(1) = length(spiketimes(spiketimes >= breaks(1) & spiketimes <= breaks(2)));
sc(2) = length(spiketimes(spiketimes >= breaks(2) & spiketimes <= breaks(3)));
sc(3) = length(spiketimes(spiketimes >= breaks(3) & spiketimes <= breaks(4)));
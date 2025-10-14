function ib = computeinitialburst(data)
ibspikes = find(data.spiketimes <= 0.075);
if isempty(ibspikes)
    ib = 0;
else
    ib = max(data.ifr(ibspikes));
end
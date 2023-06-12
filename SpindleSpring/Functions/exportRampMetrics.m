function ifrMetrics = exportRampMetrics(data)
st = data.spiketimes;
ifr = data.ifr;

% initial burst
ibwin = st > -0.01 & st < 0.01;
ibst = st(ibwin);
ibifr = ifr(ibwin);
[iba, ibi] = max(ibifr); % magnitude and index of IB
ibt = ibst(ibi); % time point of IB

% dynamic response
drwin = st > 0.05 & st < 0.15;
drst = st(drwin);
drifr = ifr(drwin);
% static response
srwin = find(st > 0.64, 3, 'first'); % fix
srst = st(srwin);
srifr = ifr(srwin);

% classify initial burst
if max(ibifr) < drifr(1) % if the IB is less than the rate at the beginning of the DR
    ifrMetrics.IBA = 0; 
else
    ifrMetrics.IBA = max(iba);
end
ifrMetrics.ibt = ibt;
% export rest of the metrics
ifrMetrics.DRA = max(drifr);
ifrMetrics.SRA = median(srifr);
ifrMetrics.DI = ifrMetrics.DRA - ifrMetrics.SRA;
ifrMetrics.ibst = ibst;
ifrMetrics.ibifr = ibifr;
ifrMetrics.drst = drst;
ifrMetrics.drifr = drifr;
ifrMetrics.srst = srst;
ifrMetrics.srifr = srifr;
function ifrMetrics = exportRampMetrics(data)
st = data.spiketimes;
ifr = data.ifr;

vst = interp1(data.time, data.vmt, st);
tstop = find(vst < .1 & st > 1.1, 1, 'first');
stretch = find(st < st(tstop) & st > 1.1);

% initial burst
ibst = st(st > 1 & st < 1.025);
ibifr = ifr(st > 1 & st < 1.025);
% dynamic response
drifr = ifr(stretch);
% static response
srifr = ifr(find(st < 1.65, 5, 'last'));

ifrMetrics.IBA = max(ibifr);
ifrMetrics.DRA = max(drifr);
ifrMetrics.SRA = median(srifr);
ifrMetrics.DI = ifrMetrics.DRA - ifrMetrics.SRA;
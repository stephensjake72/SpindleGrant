function ifrMetrics = exportSineMetrics(data, amp)
Lmt = data.Lmt;
time = data.time;
st = data.spiketimes;
ifr = data.ifr;

[~, locs] = findpeaks(Lmt, ...
    'MinPeakHeight', 0.9*amp + Lmt(1), ...
    'MinPeakProminence', 0.9*amp);
pktimes = time(locs);
cycleT = pktimes(2) - pktimes(1);

ifrpks = locs;
ifrpktimes = locs;
for jj = 1:numel(locs)
    tStart = pktimes(jj) - cycleT/3;
    tStop = pktimes(jj) + cycleT/3;

    win = (st >= tStart & st <= tStop);
    stwin = st(win);
    [ifrpk, id] = max(ifr(win));
    ifrpks(jj) = ifrpk;
    ifrpktimes(jj) = stwin(id);
end

stretchifr = ifr(st >= pktimes(1) - cycleT/2);
meanifr = mean(stretchifr);

ifrMetrics.peakifr = median(ifrpks(2:end));
ifrMetrics.ifrpks = ifrpks;
ifrMetrics.ifrpktimes = ifrpktimes;
ifrMetrics.meanifr = meanifr;
ifrMetrics.spikect = length(data.spiketimes);
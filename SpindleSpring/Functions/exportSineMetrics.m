function ifrMetrics = exportSineMetrics(data)
time = data.time;
st = data.spiketimes;
ifr = data.ifr;

cyclebreaks = 0:0.5:max(time); % start times of each cycle

cyclepeaks = zeros(1, length(cyclebreaks) - 1); % use the peaks to make a vector the right length
cyclepeaktimes = zeros(1, length(cyclebreaks) - 1);
cyclespikect = zeros(1, length(cyclebreaks) - 1);

for jj = 1:numel(cyclebreaks)-1
    tStart = cyclebreaks(jj);
    tStop = cyclebreaks(jj+1);
    
    win = (st >= tStart & st <= tStop);
    stwin = st(win);
    [ifrpk, id] = max(ifr(win));
    if ~isempty(ifrpk)
        cyclepeaks(jj) = ifrpk;
        cyclepeaktimes(jj) = stwin(id);
        cyclespikect(jj) = length(stwin);
    end
end

ifrMetrics.peakifr = mean(cyclepeaks(2:end));
ifrMetrics.ifrpks = cyclepeaks(cyclepeaks ~= 0);
ifrMetrics.ifrpktimes = cyclepeaktimes(cyclepeaktimes ~= 0);
ifrMetrics.meanifr = mean(ifr(st <= cyclebreaks(end)));
ifrMetrics.cyclespikect = mean(cyclespikect(cyclespikect ~= 0));
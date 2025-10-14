function f = getFreq(data)
[~, l] = findpeaks(data.Lmt, 'MinPeakHeight', 1.8, 'MinPeakProminence', 2);
int = diff(data.time(l));
f = round(mean(1./int));
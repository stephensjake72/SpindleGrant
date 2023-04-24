function ifrMetrics = exportTriangleMetrics(data)
% vmt = data.vmt;
st = data.spiketimes;
ifr = data.ifr;
% time = data.time;

% initial burst
% ibst = st(st > .95 & st < 1.05);
ibifr = ifr(st > .95 & st < 1.05);
[iba, ~] = max(ibifr);
% ibt = ibst(m);

s1st = st(st > 1 & st < 2);
s1ifr = ifr(st > 1 & st < 2);
s2st = st(st > 2.5 & st < 3.5);
s2ifr = ifr(st > 2.5 & st < 3.5);

ifrMetrics.triIB = iba;
ifrMetrics.trisc1 = length(s1st);
ifrMetrics.trisc2 = length(s2st);
ifrMetrics.trimifr1 = mean(s1ifr);
ifrMetrics.trimifr2 = mean(s2ifr);
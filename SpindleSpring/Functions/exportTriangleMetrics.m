function ifrMetrics = exportTriangleMetrics(data)
% vmt = data.vmt;
st = data.spiketimes;
ifr = data.ifr;
% time = data.time;

% initial burst
ibwin = st > -0.04 & st < 0.04;
ibst = st(ibwin);
ibifr = ifr(ibwin);
[iba, ibi] = max(ibifr); % index and magitude of IB
ibt = ibst(ibi); % convert index to time

% dynamic response
drwin = st > 0.05 & st < 0.72;
drst = st(drwin);
drifr = ifr(drwin);

% first stretch
s1win = st > -0.05 & st <= 1.4;
s1st = st(s1win);
s1ifr = ifr(s1win);
% second stretch
s2win = st > 1.4 & st <= 2.8;
s2st = st(s2win);
s2ifr = ifr(s2win);

ifrMetrics.ibst = ibst;
ifrMetrics.ibifr = ibifr;
ifrMetrics.drst = drst;
ifrMetrics.drifr = drifr;
ifrMetrics.s1st = s1st;
ifrMetrics.s1ifr = s1ifr;
ifrMetrics.s2st = s2st;
ifrMetrics.s2ifr = s2ifr;
% classify IB
if iba < drifr(1)
    ifrMetrics.triIB = 0;
else
    ifrMetrics.triIB = iba;
end
ifrMetrics.ibt = ibt;
ifrMetrics.trisc1 = length(s1st);
ifrMetrics.trisc2 = length(s2st);
ifrMetrics.trimifr1 = mean(s1ifr);
ifrMetrics.trimifr2 = mean(s2ifr);
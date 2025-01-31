function [startTimes, stopTimes] = findIntervals(time, Lmt)
Lmt = Lmt(1:20:end);
time = time(1:20:end);
fs = diff(time(1:2))^-1;

[~, vmt, ~] = sgolaydiff(Lmt, 2, 25); % take the MTU velocity
vmt = vmt*fs; % divide by sampling rate

vthr = 1.5; % set a velocity threshold to determine stretch periods
stretchtimes = time(abs(vmt) > vthr);

stretchint = stretchtimes(2:end) - stretchtimes(1:end - 1); % find the intervals between stretch
startinds = find(stretchint > 1.5); % take the intervals that are >1.5s
% 
startTimes = [stretchtimes(1); stretchtimes(startinds+1)] - 0.75; % convert to time points corresponding with the start of a stretch
stopTimes = [stretchtimes(startinds); stretchtimes(end)] + 0.75; % time pts corresponding to end of stretch
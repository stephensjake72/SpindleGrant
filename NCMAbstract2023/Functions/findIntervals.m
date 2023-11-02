function [startTimes, stopTimes] = findIntervals(time, Lmt)

% take the MTU velocity
[~, vmt, ~] = sgolaydiff(Lmt, 2, 501);
% divide by sampling rate
vmt = vmt/(time(2) - time(1)); 

% set a velocity threshold to determine stretch periods
vthr = 1.5;

% find time points corresponding to shortening/lengthening
stretchtimes = time(abs(vmt) > vthr);
% find the interval between stretch times
stretchint = stretchtimes(2:end) - stretchtimes(1:end - 1);
% take the intervals that are >1.5s
startinds = find(stretchint > 1.5);

% convert to time points corresponding with the start of a stretch
startTimes = [stretchtimes(1); stretchtimes(startinds+1)] - 0.75;
% time pts corresponding to end of stretch
stopTimes = [stretchtimes(startinds); stretchtimes(end)] + 0.75; 
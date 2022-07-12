clc
clear
close all
addpath(genpath('Functions'))

D = dir('//cosmic.bme.emory.edu/labs/ting/ting-archive/unpublished/2018_Horslen_Spindle_timeXamp/Spike Data files');
d = dir([D(11).folder filesep D(11).name]);


savedir = 'C:\\Users\Jake\Documents\Data\HorslenData';
if ~exist(savedir, 'dir')
    mkdir(savedir)
end

% files 102 103 104 are the postural sway cond's
ids = [102, 103, 104];
for ii = 1:numel(ids)
    data = load([d(ids(ii)).folder filesep d(ids(ii)).name]);
    
    % downsample
    dsf = 20;
    Lmtvals = data.motor_L.values(1:dsf:end);
    Lmttimes = data.motor_L.times(1:dsf:end);
    Lfvals = data.Sonos.values(1:dsf:end);
    Lftimes = data.Sonos.times(1:dsf:end);
    Fmtvals = data.motor_F.values(1:dsf:end);
    Fmttimes = data.motor_F.times(1:dsf:end);
    
    % lowpass
    fs = length(Lmttimes)/max(Lmttimes);
    nyq = fs/2;
    cutoff = 100;
    wcut = cutoff/nyq;
    [b, a] = butter(4, wcut, 'low');
    Lmtvals = filter(b, a, Lmtvals);
    Lfvals = filter(b, a, Lfvals);
    Fmtvals = filter(b, a, Fmtvals);
    
    % align
    start = data.Ramp_up.times;
    Lmttimes = Lmttimes - start;
    Lftimes = Lftimes - start;
    Fmttimes = Fmttimes - start;
    
    % differentiate
    N = 4;
    W = 201;
    [Lmt, vmt, amt] = sgolaydiff(Lmtvals, N, W);
    [Lf, vf, af] = sgolaydiff(Lfvals, N, W);
    [Fmt, ymt, jmt] = sgolaydiff(Fmtvals, N, W);
    vmt = vmt*fs;
    vf = vf*fs;
    ymt = ymt*fs;
    amt = amt*fs^2;
    af = af*fs^2;
    jmt = jmt*fs^2;
    
    spiketimes = data.nw_9.times - start;
    ifr = [0; 1./(spiketimes(2:end) - spiketimes(1:end - 1))];
    
    keep = Lmttimes > -30 & Lmttimes < 5;
    procdata.Lmt = Lmt(keep);
    procdata.vmt = vmt(keep);
    procdata.amt = amt(keep);
    procdata.Lf = Lf(keep);
    procdata.vf = vf(keep);
    procdata.af = af(keep);
    procdata.Fmt = Fmt(keep);
    procdata.ymt = ymt(keep);
    procdata.time = Lmttimes(keep);
    procdata.spiketimes = spiketimes(spiketimes > -30 & spiketimes < 5);
    procdata.IFR = ifr(spiketimes > -30 & spiketimes < 5);
    
    hold on
    subplot(3, 3, 1)
    plot(procdata.time, procdata.Lmt)
    hold on
    subplot(3, 3, 2)
    plot(procdata.time, procdata.vmt)
    hold on
    subplot(3, 3, 3)
    plot(procdata.time, procdata.amt)
    hold on
    subplot(3, 3, 4)
    plot(procdata.time, procdata.Lf)
    hold on
    subplot(3, 3, 5)
    plot(procdata.time, procdata.vf)
    hold on
    subplot(3, 3, 6)
    plot(procdata.time, procdata.af)
    hold on
    subplot(3, 3, 7)
    plot(procdata.time, procdata.Fmt)
    hold on
    subplot(3, 3, 8)
    plot(procdata.time, procdata.ymt)
    hold on
    subplot(3, 3, 9)
    plot(procdata.spiketimes, procdata.IFR, 'LineStyle', 'none', 'Marker', '.')
    
    save([savedir filesep num2str(ii) '.mat'], 'procdata')
end
hold off
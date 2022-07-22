clc
clear
close all
addpath(genpath('Functions'))

D = dir('//cosmic.bme.emory.edu/labs/ting/ting-archive/unpublished/2018_Horslen_Spindle_timeXamp/Spike Data files/20190312/');

savedir = 'C:\\Users\Jake\Documents\Data\HorslenCondAmp';
if ~exist(savedir, 'dir')
    mkdir(savedir)
end
%%
% tabids = 36:39;
% for ii = 2% :numel(tabids)
%     data = load([D(tabids(ii)).folder filesep D(tabids(ii)).name])
% end
%%
for jj = 3:numel(D)
    if contains(D(jj).name, '.mat') && contains(D(jj).name, 'A17') && ~contains(D(jj).name, 'test')
        data = load([D(jj).folder filesep D(jj).name]);
        if ~isfield(data, 'Sonos')
            continue
        end
    else
        continue
    end
    
    % downsample
    dsf = 20;
    Lmtvals = data.motor_L.values(1:dsf:end) - data.motor_L.values(1);
    Lmttimes = data.motor_L.times(1:dsf:end);
    Lfvals = data.Sonos.values(1:dsf:end) - data.Sonos.values(1);
    Lftimes = data.Sonos.times(1:dsf:end);
    Fmtvals = data.motor_F.values(1:dsf:end) - data.motor_F.values(1);
    Fmttimes = data.motor_F.times(1:dsf:end);
    
    % trim vector lengths
    lengths = [length(Lmtvals) length(Lfvals) length(Fmtvals)];
    Lmtvals = Lmtvals(1:min(lengths));
    Lmttimes = Lmttimes(1:min(lengths));
    Lfvals = Lfvals(1:min(lengths));
    Lftimes = Lftimes(1:min(lengths));
    Fmtvals = Fmtvals(1:min(lengths));
    Fmttimes = Fmttimes(1:min(lengths));
    % spiketimes and IFR
    if isfield(data.Spks_pk, 'times')
        spiketimes = data.Spks_pk.times;
    else % get the one trial that had a time series binary vector instead of spike times
        spiketimes = data.motor_L.times(data.Spks_pk.values == 1);
    end
    ifr = [0; 1./(spiketimes(2:end) - spiketimes(1:end - 1))];
%     spiketimes = spiketimes(2:end); 
%     checking the time vectors they're all about the same so make the
%     motor length time vector the experiment time vector
    time = Lmttimes;
    
    
    % lowpass
    fs = length(time)/max(time);
    nyq = fs/2;
    cutoff = 40;
    wcut = cutoff/nyq;
    [b, a] = butter(8, wcut, 'low');
    Lmtvals = filter(b, a, Lmtvals);
    Lfvals = filter(b, a, Lfvals);
    Fmtvals = filter(b, a, Fmtvals);
    
    % differentiate
    N = 4;
    W = 51;
    [Lmt, vmt, amt] = sgolaydiff(Lmtvals, N, W);
    [Lf, vf, af] = sgolaydiff(Lfvals, N, W);
    [Fmt, ymt, jmt] = sgolaydiff(Fmtvals, N, W);
    vmt = vmt*fs;
    vf = vf*fs;
    ymt = ymt*fs;
    amt = amt*fs^2;
    af = af*fs^2;
    jmt = jmt*fs^2;
    
    keep = ~isnan(af) & ~isnan(amt) & ~isnan(ymt);
    procdata.Lmt = Lmt(keep);
    procdata.vmt = vmt(keep);
    procdata.amt = amt(keep);
    procdata.Lf = Lf(keep) + data.Sonos.values(1);
    procdata.vf = vf(keep);
    procdata.af = af(keep);
    procdata.Fmt = Fmt(keep) + data.motor_F.values(1);
    procdata.ymt = ymt(keep);
    procdata.time = time(keep);
    procdata.spiketimes = spiketimes;
    procdata.IFR = ifr;
    
%     plot
    figure
    subplot(3, 3, 1)
    plot(data.motor_L.times, data.motor_L.values, procdata.time, procdata.Lmt)
    subplot(3, 3, 2)
    plot(procdata.time, procdata.vmt)
    subplot(3, 3, 3)
    plot(procdata.time, procdata.amt)
    subplot(3, 3, 4)
    plot(data.Sonos.times, data.Sonos.values, procdata.time, procdata.Lf)
    subplot(3, 3, 5)
    plot(procdata.time, procdata.vf)
    subplot(3, 3, 6)
    plot(procdata.time, procdata.af)
    subplot(3, 3, 7)
    plot(data.motor_F.times, data.motor_F.values, procdata.time, procdata.Fmt)
    subplot(3, 3, 8)
    plot(procdata.time, procdata.ymt)
    subplot(3, 3, 9)
    plot(spiketimes, ifr, '.k')
    expname = D(jj).name;
    expname(expname == '_') = ' ';
    sgtitle([num2str(jj) expname])
    
    spaces = find(expname == ' ');
    parameters.id = expname(1:12);
    parameters.cell = expname(spaces(1)+1:spaces(2)-1);
    parameters.condamp = expname(spaces(3)+1:spaces(4)-1);
    parameters.isi = expname(spaces(4)+1:strfind(expname, '.mat')-1);
%     parameters
%     
    save([savedir filesep num2str(jj) '.mat'], 'procdata', 'parameters')
end
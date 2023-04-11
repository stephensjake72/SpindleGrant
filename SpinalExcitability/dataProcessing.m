% Script to process data
% Author: JDS
% Updated: 4/04/2023
clc
clear
close all
addpath(genpath('Functions'))

% Load data files
source = '/Volumes/labs/ting/shared_ting/Jake/';
path = uigetdir(source);
D = dir(path);
savedir = [path(1:find(path == '/', 1, 'last')) 'procdata'];
if ~exist(savedir, 'dir')
    mkdir(savedir)
end

D = D(3:end);
%%
% loop through experiment files
for ii = 1:numel(D)
%     disp(ii)
    data = load([D(ii).folder filesep D(ii).name]);
    
    % downsampling factor
    dsf = 20;
    % butterworth filter design
    fsample = 1/(dsf*(data.recdata.time(2)-data.recdata.time(1)));
    fstop = 100; % 100Hz cutoff
    n = 2; % fourth order
    Wn = 2*fstop/fsample;
    
    % time
    time = data.recdata.time(1:dsf:end);
    
    % MTU length
    Lmt = data.recdata.Lmt(1:dsf:end) - data.recdata.Lmt(1);
    [b, a] = butter(n, Wn, 'low');
    Lmt = filtfilt(b, a, Lmt);
    
    % MTU force
    Fmt = data.recdata.Fmt(1:dsf:end);
    Fmt = filtfilt(b, a, Fmt);
    
    % EMG
    EMG = data.recdata.EMG(1:dsf:end); % downsample
    nn = 1; % filter order 2*1 = 2nd
    Wnn = [10, 400]/(fsample/2); % bandpass from 10 to 400 Hz
    [d, c] = butter(nn, Wnn, 'bandpass');
    EMG = filtfilt(d, c, EMG);
    EMG = abs(EMG); % full-wave rectify
    
    % smooth and get first derivatives with savitsky-golay filter
    fOrder = 2;
    Width = 21; % 21 samples/893 Hz = 23 ms
%     [Lf, vf, ~] = sgolaydiff(Lf, fOrder, Width);
    [Lmt, vmt, ~] = sgolaydiff(Lmt, fOrder, Width);
    [Fmt, ymt, ~] = sgolaydiff(Fmt, fOrder, Width);
    
    % smooth and get second derivatives
%     [vf, af, ~] = sgolaydiff(vf, fOrder, Width);
%     [vmt, amt, ~] = sgolaydiff(vmt, fOrder, Width);
%     [ymt, ~, ~] = sgolaydiff(yank, fOrder, Width);
    
    % create logical vector to keep real values and exclude nans created by
    % smoothing
    keep = ~isnan(ymt);
    
%     Lf = Lf(keep);
    Lmt = Lmt(keep);
    Fmt = Fmt(keep);
%     vf = vf(keep);
    vmt = vmt(keep)*fsample;
    ymt = ymt(keep)*fsample;
%     af = af(keep);
%     amt = amt(keep);
    EMG = EMG(keep);
    time = time(keep);
    
    spiketimes = data.recdata.spiketimes(data.recdata.spiketimes > time(1) & data.recdata.spiketimes < time(end));
    ifr = data.recdata.ifr(data.recdata.spiketimes > time(1) & data.recdata.spiketimes < time(end));
    
    % set stretch start as time 0
    vthr = 5;
    startind = find(vmt > vthr, 1, 'first');
    startTime = time(startind);
    disp(startTime)
    time = time - startTime;
    spiketimes = spiketimes - startTime;
    
    % set resting length at 0
    setInd = find(time > -.2, 1, 'first');
    Lmt = Lmt - Lmt(setInd);
    
    % package in a structure and save
    parameters = data.parameters;
    procdata.Lmt = Lmt;
    procdata.vmt = vmt;
    procdata.Fmt = Fmt;
    procdata.ymt = ymt;
    procdata.EMG = EMG;
    procdata.time = time;
    procdata.spiketimes = spiketimes;
    procdata.ifr = ifr;
    
    hold on
    plot(procdata.time, procdata.Lmt)
    
    save([savedir filesep D(ii).name(1:end-4)], 'procdata', 'parameters', '-append')
end
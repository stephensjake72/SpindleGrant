% Script to process data
% Author: JDS
% Updated: 10/25/23
clc
clear
close all
addpath(genpath('Functions'))

% Load data files
path = uigetdir();
D = dir(path);
savedir = [path(1:find(path == filesep, 2, 'last')) 'SFN' filesep 'procdata'];
if ~exist(savedir, 'dir')
    mkdir(savedir)
end

D = D(3:end);
%%
% loop through experiment files
for ii = 1:numel(D)
    disp(ii)
    data = load([D(ii).folder filesep D(ii).name]);
    
    % downsampling factor
    dsf = 20;
    % butterworth filter design
    fsample = 1/(dsf*(data.recdata.time(2)-data.recdata.time(1)));
    fstop = 80; % 80Hz cutoff
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
    
    % smooth and get first derivatives with savitsky-golay filter
    fOrder = 2;
    Width = 21; % 51 samples/893 Hz = 57 ms
    [Lmt, vmt, ~] = sgolaydiff(Lmt, fOrder, Width);
    [Fmt, ymt, ~] = sgolaydiff(Fmt, fOrder, Width);
    
    % smooth and get second derivatives
    [vmt, amt, ~] = sgolaydiff(vmt, fOrder, Width);
%     [ymt, ~, ~] = sgolaydiff(yank, fOrder, Width);
    
    % create logical vector to keep real values and exclude nans created by
    % smoothing
    keep = ~isnan(amt);
    
    Lmt = Lmt(keep);
    Fmt = Fmt(keep);
    vmt = vmt(keep)*fsample;
    ymt = ymt(keep)*fsample;
    amt = amt(keep);
    time = time(keep);
    
    Lmt = Lmt - max(Lmt) + 3;
    % set stretch start as time 0
    Lthr = 0.5;
    startind = find(Lmt > Lthr, 1, 'first');
    if isempty(startind)
        continue
    end
    startTime = time(startind(end)) - 0.1;
    disp(startTime)
    time = time - startTime;
    spiketimes = data.recdata.spiketimes - startTime;
    
    keep = time > -0.5;
    % package in a structure and save
    parameters = data.parameters;
    procdata.Lmt = Lmt(keep);
    procdata.vmt = vmt(keep);
    procdata.amt = amt(keep);
    procdata.Fmt = Fmt(keep);
    procdata.ymt = ymt(keep);
    procdata.time = time(keep);
    
    spikewin = spiketimes > min(procdata.time) & spiketimes < max(procdata.time);
    procdata.spiketimes = spiketimes(spikewin);
    procdata.ifr = data.recdata.ifr(spikewin);
    
%     hold on
%     plot(procdata.time, procdata.Lmt)
    
    save([savedir filesep D(ii).name(1:end-4)], 'procdata', 'parameters')
end
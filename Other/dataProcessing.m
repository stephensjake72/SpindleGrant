% Script to process data
% Author: JDS
% Updated: 4/11/2023
clc
clear
close all
addpath(genpath('Functions'))

% Load data files
path = uigetdir();
D = dir(path);
D = D(3:end);
%%

savedir = [path(1:find(path == filesep, 1, 'last')) 'procdata'];
if ~exist(savedir, 'dir')
    mkdir(savedir)
end

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
    
    % Fascicle length
    Lf = data.recdata.Lf(1:dsf:end);
    Lf = filtfilt(b, a, Lf);
    
    % smooth and get first derivatives with savitsky-golay filter
    fOrder = 2;
    Width = 21; % 51 samples/893 Hz = 57 ms
    [Lmt, vmt, ~] = sgolaydiff(Lmt, fOrder, Width);
    [Lf, vf, ~] = sgolaydiff(Lf, fOrder, Width);
    [Fmt, ymt, ~] = sgolaydiff(Fmt, fOrder, Width);
    
    % smooth and get second derivatives
    [vmt, amt, ~] = sgolaydiff(vmt, fOrder, Width);
    [vf, af, ~] = sgolaydiff(vf, fOrder, Width);
%     [ymt, ~, ~] = sgolaydiff(yank, fOrder, Width);
    
    % create logical vector to keep real values and exclude nans created by
    % smoothing
    keepfilt = ~isnan(amt);
    
    Lmt = Lmt(keepfilt);
    Lf = Lf(keepfilt);
    Fmt = Fmt(keepfilt);
    vmt = vmt(keepfilt)*fsample;
    vf = vf(keepfilt)*fsample;
    ymt = ymt(keepfilt)*fsample;
    amt = amt(keepfilt)*fsample^2;
    af = af(keepfilt)*fsample^2;
    time = time(keepfilt);
    
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
    acttimes = data.recdata.acttimes - startTime;
    
    keep = time > -0.5;
    % package in a structure and save
    parameters = data.parameters;
    procdata.Lmt = Lmt(keep);
    procdata.Lf = Lf(keep);
    procdata.vmt = vmt(keep);
    procdata.vf = vf(keep);
    procdata.amt = amt(keep);
    procdata.af = af(keep);
    procdata.Fmt = Fmt(keep);
    procdata.ymt = ymt(keep);
    procdata.time = time(keep);
    
    spikewin = spiketimes > min(procdata.time) & spiketimes < max(procdata.time);
    procdata.spiketimes = spiketimes(spikewin);
    procdata.ifr = data.recdata.ifr(spikewin);
    
    actwin = acttimes > -0.5;
    procdata.acttimes = acttimes(actwin);
    
%     hold on
%     plot(procdata.time, procdata.Lmt)
    
    save([savedir filesep D(ii).name(1:end-4)], 'procdata', 'parameters')
end
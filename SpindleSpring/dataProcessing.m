% Script to process data
% Author: JDS
% Updated: 5/24/23
clc
clear
close all

% access functions
addpath(genpath('Functions'));

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
for ii = 1:numel(D)
    disp(ii)
    % load file
    data = load([path filesep D(ii).name]);
    % downsampling factor
    dsf = 20;
    % load downsampled data
    % multiply by scaling factors
    % subtract initial values for lengths and force (for forces it's only
    % for the sake of preventing filter artefacts, it will be added back
    % later)
    Lf = (data.recdata.Lf(1:dsf:end) - data.recdata.Lf(1))*15; % 15 mm/V
    Lmt = data.recdata.Lmt(1:dsf:end) - data.recdata.Lmt(1); % 1mm/V
    Fmt = data.recdata.Fmt(1:dsf:end) - data.recdata.Fmt(1); % 1N/V
    time = data.recdata.time(1:dsf:end);
    % load spiketimes and IFR
    spiketimes = data.recdata.spiketimes;
    ifr = data.recdata.ifr;
    
    % original sampling frequency
    recfs = 1/(data.recdata.time(2) - data.recdata.time(1));
    % down sampled frequency
    procfs = recfs/dsf;
    % lowpass filter
    fcut = 100; % cutoff frequency
    order = 4; % filter order
    wn = fcut/(procfs/2); % cutoff frequency in rad/sample (cutoff/nyquist)
    [b, a] = butter(order, wn); % filter coefficients
    % apply filter
    Lf = filtfilt(b, a, Lf);
    Lmt = filtfilt(b, a, Lmt);
    Fmt = filtfilt(b, a, Fmt);

    % smooth and get first derivatives with savitsky-golay filter
    fOrder = 2;
    Width = 21;
    disp(Width/procfs) % window width in s
    [Lf, vf, ~] = sgolaydiff(Lf, fOrder, Width);
    [Lmt, vmt, ~] = sgolaydiff(Lmt, fOrder, Width);
    [Fmt, ymt, ~] = sgolaydiff(Fmt, fOrder, Width);
    Fmt = Fmt + data.recdata.Fmt(1); % add initial force value back
    
    % scale derivatives by multiplying by sampling frequency
    vf = vf*procfs;
    vmt = vmt*procfs;
    ymt = ymt*procfs;
    
    % trim off the time points from the double stretches
    switch data.parameters.type
        case 'ramp'
            istart = find(Lmt > 0.1, 1, 'first');
            tstart = time(istart);
            tstop = tstart + 2;
%             subplot(131)
        case 'triangle'
            istart = find(Lmt > 0.1, 1, 'first');
            tstart = time(istart);
            tstop = tstart + 4.8;
%             subplot(132)
        case 'sine'
            istart = find(Lmt < -0.1, 1, 'first');
            tstart = time(istart);
            tstop = time(end);
%             subplot(133)
    end
%     hold on
%     plot(time - tstart, Lmt, 'b')
%     plot(0, 0, '|r', 'MarkerSize', 100)
%     plot(tstop - tstart, 0, '|r', 'MarkerSize', 100)
    
    % shift time so stretch starts at 0
    time = time - tstart;
    % shift spiketimes
    spiketimes = spiketimes - tstart;
    % create logical vector to trim stretches to the same time window
    keep = time > -.5 & time < (tstop - tstart);
    time = time(keep);
    % keep spikes from the same window
    spikekeep = spiketimes > time(1) & spiketimes < time(end);
    
    % save to processed data structure
    procdata.Lf = Lf(keep);
    procdata.Lmt = Lmt(keep);
    procdata.Fmt = Fmt(keep);
    procdata.vf = vf(keep);
    procdata.vmt = vmt(keep);
    procdata.ymt = ymt(keep);
    procdata.time = time;
    procdata.spiketimes = spiketimes(spikekeep);
    procdata.ifr = ifr(spikekeep);
    procdata.act = data.recdata.act - tstart;
    
    % save
    parameters = data.parameters;
%     save([savedir filesep D(ii).name], 'procdata', 'parameters')
    
    % plot to check
    switch parameters.type
        case 'ramp'
            subplot(131)
        case 'triangle'
            subplot(132)
        case 'sine'
            subplot(133)
    end
    hold on
    plot(procdata.spiketimes, procdata.ifr, '.k')
    
    clear tstop tstart
end
% disp([num2str(Width*1000/procfs) ' ms'])
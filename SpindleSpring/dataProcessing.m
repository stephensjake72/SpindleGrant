% Script to process data
% Author: JDS
% Updated: 1/17/23
clc
clear
close all

% access functions
addpath(genpath('Functions'));

% load data
path = '\\cosmic.bme.emory.edu\labs\ting\shared_ting\Jake\SpindleSpring';

date = datetime('today');
savefolder = [path filesep char(date)];
if ~exist(savefolder, 'dir')
    mkdir(savefolder)
end

D = dir([path filesep 'recdata']);
filerows = contains({D.name}', '.mat');
D = D(filerows);
%% set up calibration values
animal = {'A18042-19-10';
    'A18042-19-12';
    'A18042-19-14';
    'A18042-19-16';
    'A18042-19-18';
    'A18042-20-24';
    'A18042-20-25';
    'A18042-20-26';
    'A18042-20-27';
    'A18042-20-28';
    'A18042-20-29';
    'A18042-20-30';
    'A18042-20-31';
    'A18042-20-32'};
Lf0 = {.61; .44; .639; .576; .5893; .6898; .7411; .8084; .6689; 0; .6952; .7175; .7852; .5925};
Lf1 = {.724; .527; .699; .609; .6252; .7707; .7945; .8779; .744; 0; .7747; .8195; .8453; .6349};
F0 = {.1997; .2434; .0981; .2007; .1929; .4645; .1737; .3044; .2049; 0; .209; .2314; .2315; .1302};
LMT0 = {-2.855; 4.207; 1.934; -3.458; 1.074; 0.946; 1.566; 3.190; -.171; 0; -2.170; -.829; -1.590; -2.526};
calTable = table(animal, Lf0, Lf1, F0, LMT0);

%%
for ii = 1:numel(D)
    disp(ii)
    data = load([D(ii).folder filesep D(ii).name]);
%         row = find(strcmp(data.parameters.animal, calTable.animal));

    % downsampling factor
    dsf = 20;

    % load downsampled data
    % multiply by scaling factors
    % subtract initial values
    Lf = (data.recdata.Lf(1:dsf:end) - data.recdata.Lf(1))*15; % 15 mm/V
    Lmt = (data.recdata.Lmt(1:dsf:end) - data.recdata.Lmt(1))*2; % 2mm/V
    Fmt = (data.recdata.Fmt(1:dsf:end) - data.recdata.Fmt(1))*1; % 1N/V
    time = data.recdata.time(1:dsf:end);
    recfs = 1/(data.recdata.time(2) - data.recdata.time(1)); % original sampling frequency
    procfs = recfs/dsf; % down sampling frequency

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
    Width = 41;
    
    [Lf, vf, af] = sgolaydiff(Lf, fOrder, Width);
    [Lmt, vmt, amt] = sgolaydiff(Lmt, fOrder, Width);
    [Fmt, ymt, ~] = sgolaydiff(Fmt, fOrder, Width);
    Fmt = Fmt + data.recdata.Fmt(1);
    
    % rescale derivatives by multiplying by sampling frequency
    vf = vf*procfs;
    vmt = vmt*procfs;
    ymt = ymt*procfs;
    
    % only do this section if really needed
%     % filter derivatives again before taking second derivatives
%     vf = filtfilt(b, a, vf);
%     vmt = filtfilt(b, a, vmt);
%     ymt = filtfilt(b, a, ymt);
% 
%     % smooth and get second derivatives
%     [~, af, ~] = sgolaydiff(vf, fOrder, Width);
%     [~, amt, ~] = sgolaydiff(vmt, fOrder, Width);

    % create logical vector to keep real values and exclude NaNs created by
    % SG filter
    keep = ~isnan(af);
    
    Lf = Lf(keep);
    Lmt = Lmt(keep);
    Fmt = Fmt(keep);
    time = time(keep);
    vf = vf(keep);
    vmt = vmt(keep);
    ymt = ymt(keep);
    af = af(keep);
    amt = amt(keep);
    
    % plot if needed
    if data.parameters.passive == 1 && strcmp(data.parameters.aff, 'IA') && ii < 50
        figure
        subplot(331)
        plot(data.recdata.time, data.recdata.Lf - data.recdata.Lf(1), ...
            time, Lf)
        subplot(332)
        plot(data.recdata.time, data.recdata.Lmt - data.recdata.Lmt(1), ...
            time, Lmt, ...
            data.recdata.act, ones(1, numel(data.recdata.act)), '|r')
        subplot(333)
        plot(data.recdata.time, data.recdata.Fmt - data.recdata.Fmt(1), ...
            time, Fmt)
        subplot(334)
        plot(time, vf)
        subplot(335)
        plot(time, vmt)
        subplot(336)
        plot(time, ymt)
        ax = gca;
        subplot(337)
        plot(time, af)
        subplot(338)
        plot(time, amt)
        subplot(339)
        plot(data.recdata.spiketimes, data.recdata.ifr, '.k')
        xlim(ax.XAxis.Limits)
        title(data.parameters.aff)
    end
    
    % create processed data structure
    procdata.Lf = Lf;
    procdata.Lmt = Lmt;
    procdata.Fmt = Fmt;
    procdata.vf = vf;
    procdata.vmt = vmt;
    procdata.ymt = ymt;
    procdata.af = af;
    procdata.amt = amt;
    procdata.time = time;
    procdata.spiketimes = data.recdata.spiketimes;
    procdata.ifr = data.recdata.ifr;

    % save the bad trial indicator as 0 initially, bad trials will be
    % identified later on, skip if re-processing
    badtrial = 0;
    recdata = data.recdata;
    save([savefolder filesep D(ii).name], 'recdata', 'procdata', 'badtrial')
end
disp([num2str(Width*1000/procfs) ' ms'])
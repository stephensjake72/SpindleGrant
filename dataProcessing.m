% Script to process data
% Author: JDS
% Updated: 2/13/22
clc
clear
close all

% access functions
addpath(genpath('Functions'));

% load data
destination = uigetdir('\\cosmic.bme.emory.edu\labs\ting\shared_ting\Jake\Spindle_Grant');
D = dir(destination);
D = D(3:end);
%%
% loop through experiment files
for ii = 1:numel(D)
    disp(ii)
    data = load([D(ii).folder filesep D(ii).name]);
    
    % downsampling factor
    dsf = 20;
    
    % load downsampled data
    Lf = data.recdata.Lf(1:dsf:end);
    Lmt = data.recdata.Lmt(1:dsf:end);
    Fmt = data.recdata.Fmt(1:dsf:end);
    time = data.recdata.time(1:dsf:end);
    
    % lowpass filter
    fs = 1/(time(2) - time(1));
    cutoff = 50;
    Lf = lowpass(Lf, cutoff, fs);
    Lmt = lowpass(Lmt, cutoff, fs);
    Fmt = lowpass(Fmt, cutoff, fs);
    
    % smooth and get first derivatives with savitsky-golay filter
    fOrder = 6;
    Width = 101;
    [Lf, vf, ~] = sgolaydiff(Lf, fOrder, Width);
    [Lmt, vmt, ~] = sgolaydiff(Lmt, fOrder, Width);
    [Fmt, yank, ~] = sgolaydiff(Fmt, fOrder, Width);
    
    % smooth and get second derivatives
    [vf, af, ~] = sgolaydiff(vf, fOrder, Width);
    [vmt, amt, ~] = sgolaydiff(vmt, fOrder, Width);
    [yank, ~, ~] = sgolaydiff(yank, fOrder, Width);
    
    % create logical vector to keep real values and exclude nans created by
    % smoothing
    keep = ~isnan(af);
    
    Lf = Lf(keep);
    Lmt = Lmt(keep);
    Fmt = Fmt(keep);
    time = time(keep);
    vf = vf(keep);
    vmt = vmt(keep);
    yank = yank(keep);
    af = af(keep);
    amt = amt(keep);
    
    % subplot(331)
    % plot(time, Lf)
    % subplot(332)
    % plot(time, Lmt)
    % subplot(333)
    % plot(time, Fmt)
    % subplot(334)
    % plot(time, vf)
    % subplot(335)
    % plot(time, vmt)
    % subplot(336)
    % plot(time, yank)
    % subplot(337)
    % plot(time, af)
    % subplot(338)
    % plot(time, amt)

    procdata.Lf = Lf;
    procdata.Lmt = Lmt;
    procdata.Fmt = Fmt;
    procdata.vf = vf;
    procdata.vmt = vmt;
    procdata.yank = yank;
    procdata.af = af;
    procdata.amt = amt;
    procdata.time = time;
    procdata.aff1.times = data.recdata.aff1.times;
    procdata.aff1.IFR = 1./(data.recdata.aff1.times(2:end) - data.recdata.aff1.times(1:end - 1));
    if isfield(data.recdata, 'aff2')
        if ~isempty(data.recdata.aff2.times)
            procdata.aff2.IFR = 1./(data.recdata.aff2.times(2:end) - data.recdata.aff2.times(1:end - 1));
            procdata.aff2.times = data.recdata.aff2.times;
        end
    end
    
    save([D(ii).folder filesep D(ii).name], 'procdata', '-append')
    
    % plot for sanity check
    figure
    subplot(511)
    plot(time, procdata.Lmt)
    subplot(512)
    plot(time, procdata.Lf)
    subplot(513)
    plot(time, procdata.Fmt)
    if isfield(procdata, 'aff1')
        subplot(514)
        plot(procdata.aff1.times(1:end-1), procdata.aff1.IFR, '.k')
    end
    if isfield(procdata, 'aff2')
        subplot(515)
        plot(procdata.aff2.times(1:end-1), procdata.aff2.IFR, '.k')
    end
    clear procdata
end
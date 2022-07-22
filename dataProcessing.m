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
    Lf = data.recdata.Lf(1:dsf:end) - data.recdata.Lf(1);
    Lmt = data.recdata.Lmt(1:dsf:end) - data.recdata.Lmt(1);
    Fmt = data.recdata.Fmt(1:dsf:end);
    time = data.recdata.time(1:dsf:end);
    
    % lowpass filter
    fcut = 40;
    fs = 1/(time(2) - time(1));
    order = 4;
    wn = fcut/(fs/2);
    [b, a] = butter(order, wn);
    
    Lf = filtfilt(b, a, Lf);
    Lmt = filtfilt(b, a, Lmt);
    Fmt = filtfilt(b, a, Fmt);
    
    % smooth and get first derivatives with savitsky-golay filter
    fOrder = 4;
    Width = 21;
    [Lf, vf, af] = sgolaydiff(Lf, fOrder, Width);
    [Lmt, vmt, amt] = sgolaydiff(Lmt, fOrder, Width);
    [Fmt, yank, ~] = sgolaydiff(Fmt, fOrder, Width);
    
    % smooth and get second derivatives
%     [vf, af, ~] = sgolaydiff(vf, fOrder, Width);
%     [vmt, amt, ~] = sgolaydiff(vmt, fOrder, Width);
%     [yank, ~, ~] = sgolaydiff(yank, fOrder, Width);
    
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
    
    figure
    subplot(331)
    plot(time, Lf)
    subplot(332)
    plot(time, Lmt)
    subplot(333)
    plot(time, Fmt)
    subplot(334)
    plot(time, vf)
    subplot(335)
    plot(time, vmt)
    subplot(336)
    plot(time, yank)
    subplot(337)
    plot(time, af)
    subplot(338)
    plot(time, amt)

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
    
%     save([D(ii).folder filesep D(ii).name], 'procdata', '-append')
    
    % plot for sanity check
%     figure
%     subplot(511)
%     plot(data.recdata.time, data.recdata.Lmt, time, procdata.Lmt)
%     title('Lmt')
%     subplot(512)
%     plot(data.recdata.time, data.recdata.Lf, time, procdata.Lf)
%     title('Lf')
%     subplot(513)
%     plot(data.recdata.time, data.recdata.Fmt, time, procdata.Fmt)
%     title('Fmt')
%     if isfield(procdata, 'aff1')
%         subplot(514)
%         plot(procdata.aff1.times(1:end-1), procdata.aff1.IFR, '.k')
%     end
%     if isfield(procdata, 'aff2')
%         subplot(515)
%         plot(procdata.aff2.times(1:end-1), procdata.aff2.IFR, '.k')
%     end
%     title('IFR')
%     fr = abs(fft(data.recdata.Lf));
%     frange = linspace(0, fs, numel(fr));
%     hold on
%     plot(frange(1:floor(end/2)), fr(1:floor(end/2)))
    clear procdata
end
%% identify badtrials
% 87, 56, 45, 34, 30, 23, 12, 5, 4, 3, 2, 1
badtrials = [1, 2, 3, 4, 5, 12, 23, 30, 34, 45, 56, 87];
for jj = 1:numel(D)
    if ismember(jj, badtrials)
        badtrial = 1;
    else
        badtrial = 0;
    end
    save([D(jj).folder filesep D(jj).name], 'badtrial', '-append')
end
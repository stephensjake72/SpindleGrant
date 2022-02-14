% Script to process data
% Author: JDS
% Updated: 2/13/22
clc
clear
close all

% access functions
addpath(genpath('Functions'));

% load data
destination = uigetdir();
D = dir(destination);
D = D(3:end);
%%
% loop through experiment files
ii = 1;
% for ii = 1:numel(D)
    data = load([D(ii).folder filesep D(ii).name]);
    
    % load time series data vectors
    Lf = data.recdata.Lf;
    Lmt = data.recdata.Lmt;
    Fmt = data.recdata.Fmt;
    time = data.recdata.time;
    st = data.recdata.spiketimes;
    IFR = data.recdata.IFR;
    
    % calculate sampling frequency
    fs = length(time)/max(time);

    % apply a Savitsky-Golay filter to filter and take derivatives
%     N = 4;
%     F = 201;
%     [Lf, vf, af] = sgolaydiff(Lf, N, F);
%     [Lmt, vmt, amt] = sgolaydiff(Lmt, N, F);
%     [Fmt, ymt, yymt] = sgolaydiff(Fmt, N, F);

    % sgolaydiff doesn't account for time, so multiply by fs to get
    % d/dt
%     vf = vf*fs;
%     af = af*fs^2;
%     vmt = vmt*fs;
%     amt = amt*fs^2;
%     ymt = ymt*fs;

    % trim NaNs left from filtering
%     win = floor(F/2);
%     Lf = Lf(win+1:end-win-1);
%     Lmt = Lmt(win+1:end-win-1);
%     Fmt = Fmt(win+1:end-win-1);
%     act = act(win+1:end-win-1);
%     vf = vf(win+1:end-win-1);
%     af = af(win+1:end-win-1);
%     vmt = vmt(win+1:end-win-1);
%     amt = amt(win+1:end-win-1);
%     ymt = ymt(win+1:end-win-1);
%     time = time(win+1:end-win-1);

    % plot for sanity check
%         lims = [0 3];
%         F = figure('Position', [0 0 1000 1000]);
%         subplot(3, 3, 1)
%         plot(time, Lf)
%         xlim(lims)
%         title('fascicle')
%         subplot(3, 3, 4)
%         plot(time, vf)
%         xlim(lims)
%         subplot(3, 3, 7)
%         plot(time, af)
%         xlim(lims)
%         subplot(3, 3, 2)
%         plot(time, Lmt)
%         xlim(lims)
%         title('MTU')
%         subplot(3, 3, 5)
%         plot(time, vmt)
%         xlim(lims)
%         subplot(3, 3, 8)
%         plot(time, amt)
%         xlim(lims)
%         subplot(3, 3, 3)
%         plot(time, Fmt)
%         title('force')
%         xlim(lims)
%         subplot(3, 3, 6)
%         plot(time, ymt)
%         xlim(lims)

    % save processed data as a structure
%     procdata.Lf = Lf;
%     procdata.Lmt = Lmt;
%     procdata.Fmt = Fmt;
%     procdata.act = act;
%     procdata.vf = vf;
%     procdata.af = af;
%     procdata.vmt = vmt;
%     procdata.amt = amt;
%     procdata.ymt = ymt;
%     procdata.time = time;

    % spiketime and IFR sorting
%     st = st(1:end - 1);
%     IFR = IFR(st > min(time) & st < max(time));
%     st = st(st > min(time) & st < max(time));
% 
%     procdata.spiketimes = st;
%     procdata.IFR = IFR;

    % append procdata structure to existing .mat file
%    save([exps(ii).folder filesep exps(ii).name], 'procdata', '-append')
    % saveas(F, [figuredestination filesep name '.jpg'])
% end
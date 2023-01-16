% Data Sorting
% Author: JDS
% Updated: 2/14/2022
% The purpose of this script is to go through the data exported from Spike2
% and put them in the proper format for analysis.
% To-do: put data on server to make accessible, make bad trial
% identification automated, double check results, implement version control
% for results
clear
clc
close all
addpath(genpath('Functions'))

% Load data files
source = 'C:\\Users\Jake\Documents\Data\Spindle_spring_mat';
% create destination folder
date = datetime('today');
savefolder = uigetdir;
% if ~exist(savefolder, 'dir')
%     mkdir(savefolder)
% end

D = dir(source);
D = D(3:end);
%%
clc
close all

count = 1;
for ii =  1:numel(D)
    disp(ii)
    % load data for a whole experiment
    data = load([D(ii).folder filesep D(ii).name]);
    
    Fmt = data.Ch3.values; % keep absolute force values
    Lmt = data.Ch4.values; % take absolute motor length values
    Lf = data.Ch8.values; % calibrate sonos later
    alpha = data.Ch10.times;
    
    % some spikes are in different channels
    if isfield(data, 'Ch9') % if there's a channel 9
        spiketimes = data.Ch9.times;
        ifr = [1./(spiketimes(2:end) - spiketimes(1:end-1)); 0];
    elseif isfield(data, 'Ch11') && ~isfield(data, 'Ch9') % if there's no ch9 but is a ch11
        if isfield(data.Ch11, 'times')
            spiketimes = data.Ch11.times;
            ifr = [1./(spiketimes(2:end) - spiketimes(1:end-1)); 0];
        else
            continue
        end
    else
        continue
    end
    % create time vector based on sampling interval
    time = (0:numel(Lmt) - 1)*data.Ch4.interval;
    
    % take filtered mtu velocity to identify stretching periods during the
    % expt
    N = 2;
    W = 501;
    [~, vmt, ~] = sgolaydiff(Lmt, N, W);
    
    vthr = .0001;
    stretchtimes = time(vmt > vthr); % times where lengthening occurs
    interval = [stretchtimes(2:end) - stretchtimes(1:end-1)]; % intervals between lengthening times
    breaks = find(interval > 1.5); % find long intervals between lengthening to identify different trials
%     if isempty(breaks)
%         figure
%         plot(Lmt)
%         continue
%     end
    % use intervals to create vectors of trial start and end times
    starttimes = [stretchtimes(1) stretchtimes(breaks + 1)] - 1;
    stoptimes = [stretchtimes(breaks) stretchtimes(end)] + 1.5;
    
    figure
    subplot(311)
    plot(time, Lmt)
    ax = gca;
    subplot(312)
    plot(time, vmt)
    hold on
    plot(starttimes, zeros(1, numel(starttimes)), '|g', ...
        stoptimes, zeros(1, numel(stoptimes)), '|r')
    xlim(ax.XAxis.Limits)
%     subplot(313)
%     plot(starttimes, zeros(1, numel(starttimes)), '.')
%     hold on
%     plot(stoptimes, zeros(1, numel(stoptimes)), '.r')
%     hold off
%     xlim(ax.XAxis.Limits)
%     sgtitle(D(ii).name)
%     xlim(ax.XAxis.Limits)
    
    % loop through trials within the expt
    for jj = 1:numel(starttimes)
        win = find(time >= starttimes(jj) & time < stoptimes(jj));
        recdata.time = time(win) - time(win(1));
        recdata.Lmt = Lmt(win);
        recdata.Lf = Lf(win);
        recdata.Fmt = Fmt(win);
        recdata.act = alpha(alpha >= starttimes(jj) & alpha < stoptimes(jj)) - time(win(1));
        recdata.spiketimes = spiketimes(spiketimes >= starttimes(jj) & spiketimes < stoptimes(jj)) - time(win(1));
        recdata.ifr = ifr(spiketimes >= starttimes(jj) & spiketimes < stoptimes(jj));
        
        parameters = expParam(D(ii).name, recdata);
        
%         if parameters.passive % only plot and save passive files
%             figure
%             subplot(611)
%             plot(recdata.time, recdata.Lmt)
%             ax = gca;
%             subplot(612)
%             plot(recdata.time, recdata.Lf)
%             xlim(ax.XAxis.Limits)
%             subplot(613)
%             plot(recdata.time, recdata.Fmt)
%             xlim(ax.XAxis.Limits)
%             subplot(614)
%             plot(recdata.act, ones(1, numel(recdata.act)), '|r')
%             xlim(ax.XAxis.Limits)
%             subplot(615)
%             plot(recdata.spiketimes, recdata.ifr, '.k')
%             xlim(ax.XAxis.Limits)
%             sgtitle(parameters.aff)
            
        
        save([savefolder filesep 'exp' num2str(count)], 'recdata', 'parameters')
        count = count + 1;
%         end 
    end
end
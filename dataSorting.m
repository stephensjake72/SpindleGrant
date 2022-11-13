% Data Sorting
% Author: JDS
% Updated: 2/14/2022
% The purpose of this script is to go through the data exported from Spike2
% and put them in the proper format for analysis.
clear
clc
close all
% Load data files
source = 'C:\\Users\Jake\Documents\Data\Spindle_spring_mat';
savefolder = 'C:\\Users\Jake\Documents\Data\Spindle_spring_struct';
D = dir(source);
D = D(3:end);

addpath(genpath('Functions'))
%%
clc
close all

count = 1;
for ii =  1:numel(D)
    disp(ii)
    data = load([D(ii).folder filesep D(ii).name]);
    
    Fmt = data.Ch3.values; % keep absolute force values
    Lmt = data.Ch4.values; % take relative motor length values
    Lf = data.Ch8.values; % calibrate sonos later
    alpha = data.Ch10.times;
    
    if isfield(data, 'Ch9')
        spiketimes = data.Ch9.times;
        ifr = [1./(spiketimes(2:end) - spiketimes(1:end-1)); 0];
    elseif isfield(data, 'Ch11') && ~isfield(data, 'Ch9')
        if isfield(data.Ch11, 'times')
            spiketimes = data.Ch11.times;
            ifr = [1./(spiketimes(2:end) - spiketimes(1:end-1)); 0];
        else
            continue
        end
    else
        continue
    end
    
    time = (0:numel(Lmt) - 1)*data.Ch4.interval;
    
    N = 2;
    W = 501;
    [~, vmt, ~] = sgolaydiff(Lmt, N, W);
    
    vthr = .0001;
    stretchtimes = time(vmt > vthr);
    interval = [stretchtimes(2:end) - stretchtimes(1:end-1)];
    breaks = find(interval > 1.5);
    if isempty(breaks)
        figure
        plot(Lmt)
        continue
    end
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
            
        savedir = [savefolder filesep parameters.animal];
        if ~exist(savedir, 'dir')
            mkdir(savedir);
        end
        save([savedir filesep 'exp' num2str(count)], 'recdata', 'parameters')
        count = count + 1;
%         end 
    end
end
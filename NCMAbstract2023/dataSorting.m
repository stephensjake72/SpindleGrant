% Data Sorting
% Author: JDS
% Updated: 4/11/2023
% The purpose of this script is to go through the data exported from Spike2
% and put them in the proper format for analysis for the abstact "Force
% encoding in secondary muscle spindle afferents" by Stephens et. al. for
% Neural Control of Movement in Victoria, BC in April 2023 and
% the 2023 World Congress of the International Society of Biomechanics.

clear
clc
close all
addpath(genpath('Functions'))

% Load data files
source = '/Volumes/labs/ting/shared_ting/Jake/A100401';
path = uigetdir(source);
D = dir(path);
D = D(3:end);

% create save directory
savedir = [source filesep 'recdata'];
if ~exist(savedir, 'dir')
    mkdir(savedir)
end
%%
for ii = 45:numel(D)
    disp(D(ii).name)
    data = load([D(ii).folder filesep D(ii).name]);
    
    % PARAMETER EXTRACTION
    breaks = find(D(ii).name == '_');
    parameters.ID = D(ii).name(1:breaks(1)-1);
    parameters.cell = D(ii).name(breaks(2)+1:breaks(3)-1);
    parameters.aff = D(ii).name(breaks(3)+1:breaks(3)+2);
    
    % extract length, force, time
    Lmt = data.Ch4.values;
    Fmt = data.Ch3.values;
    time = (0:data.Ch3.length - 1)*data.Ch3.interval;
    
    % pull out spike channels
    check = 0;
    spikes1 = [];
    ifr1 = [];
    spikes2 = [];
    ifr2 = [];
    spikes3 = [];
    ifr3 = [];
    if isfield(data.Ch9, 'times')
        spikes1 = data.Ch9.times;
        ifr1 = spikes2ifr(spikes1);
    end
    if isfield(data, 'Ch11')
        spikes2 = data.Ch11.times;
        ifr2 = spikes2ifr(spikes2);
        check = 1;
        if isfield(data, 'Ch12')
            spikes3 = data.Ch12.times;
            ifr3 = spikes2ifr(spikes3);
        end
    end
    
    % find stretch periods
    [~, vmt, ~] = sgolaydiff(Lmt, 2, 501); % take the MTU velocity
    vmt = vmt/data.Ch3.interval; % divide by sampling rate
    vthr = 3.5; % set a velocity threshold to determine stretch periods
    stretchtimes = time(abs(vmt) > vthr);
    stretchint = stretchtimes(2:end) - stretchtimes(1:end - 1); % find the intervals between stretch
    startinds = find(stretchint > 1.5); % take the intervals that are >1.5s
    startTimes = [stretchtimes(1) stretchtimes(startinds+1)] - 0.75; % convert to time points corresponding with the start of a stretch
    stopTimes = [stretchtimes(startinds) stretchtimes(end)] + 0.75; % time pts corresponding to end of stretch
    % plot to check if needed
%     plot(time, vmt)
%     hold on
%     plot(startTimes, zeros(numel(startTimes), 1), 'xg')
%     plot(stopTimes, zeros(numel(stopTimes), 1), 'xr')
%     hold off
    
    % loop through stretch periods to segment trials
    for jj = 1:numel(startTimes)
        
        % choose spike channel
        if check == 1
            figure('Position', [0 0 800 800])
            subplot(411)
            plot(time, Lmt)
            xlim([startTimes(jj) stopTimes(jj)])
            subplot(412)
            plot(spikes1, ifr1, '.k')
            xlim([startTimes(jj) stopTimes(jj)])
            title('Ch9')
            subplot(413)
            plot(spikes2, ifr2, '.k')
            xlim([startTimes(jj) stopTimes(jj)])
            title('Ch11')
            subplot(414)
            plot(spikes3, ifr3, '.k')
            xlim([startTimes(jj) stopTimes(jj)])
            title('Ch12')
            
            liststr = {'Ch9', 'Ch11', 'Ch12'};
            [index, ~] = listdlg('ListString', liststr);
            spiketimes = data.(liststr{index}).times;
        else
            spiketimes = data.Ch9.times;
        end
        ifr = spikes2ifr(spiketimes);
            
        % segment the data for th individual trial
        win = time > startTimes(jj) & time < stopTimes(jj);
        recdata.Lmt = Lmt(win);
        recdata.Fmt = Fmt(win);
        recdata.time = time(win) - startTimes(jj);
        
        spikewin = spiketimes > startTimes(jj) & spiketimes < stopTimes(jj);
        recdata.spiketimes = spiketimes(spikewin) - startTimes(jj);
        recdata.ifr = ifr(spikewin);
%         
        figure('Position', [0 0 800 800])
        subplot(311)
        plot(recdata.time, recdata.Lmt)
        ax = gca;
        subplot(312)
        plot(recdata.time, recdata.Fmt)
        subplot(313)
        plot(recdata.spiketimes, recdata.ifr, '.k')
        xlim(ax.XAxis.Limits)
        
        % pull up dialog box to save the file or not
        textstr = {'keep', 'discard'};
        [index, ~] = listdlg('ListString', textstr);
        if isempty(index)
            exit
        elseif index == 2
            continue
        end
%         
        % save the file with the time point as a parameter so it can be
        % checked against original files
        parameters.startT = floor(startTimes(jj));
        savename = [D(ii).name(1:end-4) '_' num2str(floor(startTimes(jj))) 's'];
        save([savedir filesep savename '.mat'], 'parameters', 'recdata')
        
        clear recdata spiketimes 
        close all
    end
    clear parameters data
end
% Data Sorting
% Author: JDS
% Updated: 3/29/2023
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
for ii = 1:numel(D)
    disp(D(ii).name)
    
    % NUMERICAL DATA EXTRACTION
    data = load([D(ii).folder filesep D(ii).name]);
    
    disp(fieldnames(data))
    % extract length, force, and time
    Lmt = data.Ch4.values;
    Fmt = data.Ch3.values;
    time = (0:data.Ch3.length - 1)*data.Ch3.interval;
%     
%     figure
%     subplot(411)
%     plot(time, Lmt)
%     subplot(412)
%     plot(time,Fmt)
%     subplot(413)
%     plot(spiketimes, ifr, '.k')
%     
    % find stretch periods
    [~, vmt, ~] = sgolaydiff(Lmt, 2, 501); % take the MTU velocity
    vmt = vmt/data.Ch3.interval; % divide by sampling rate
    vthr = 3.5; % set a velocity threshold to determine stretch periods
    stretchtimes = time(abs(vmt) > vthr);
    stretchint = stretchtimes(2:end) - stretchtimes(1:end - 1); % find the intervals between stretch
    startinds = find(stretchint > 1.5); % take the intervals that are >1.5s
    startTimes = [0 stretchtimes(startinds+1) - 0.75]; % convert to time points corresponding with the start of a stretch
    stopTimes = [stretchtimes(startinds)+0.75 time(end)]; % time pts corresponding to end of stretch
    % plot to check if needed
%     plot(time, vmt)
%     hold on
%     plot(startTimes, zeros(numel(startTimes), 1), 'xg')
%     plot(stopTimes, zeros(numel(stopTimes), 1), 'xr')
%     hold off
    
    % loop through stretch periods to segment trials
    for jj = 1:numel(startTimes)
        win = time > startTimes(jj) & time < stopTimes(jj);
        % save the recorded data
        recdata.Lmt = Lmt(win);
        recdata.Fmt = Fmt(win);
        recdata.time = time(win) - startTimes(jj);
        
        % choose spike sorting channel if there are multiple
        if isfield(data, 'Ch12')
            st1 = data.Ch11.times;
            ifr1 = [1./(st1(2:end) - st1(1:end-1)); 0];
            st2 = data.Ch12.times;
            ifr2 = [1./(st2(2:end) - st2(1:end-1)); 0];
            
            figure('Position', [1000 600 600 600])
            subplot(311)
            plot(time, Lmt)
            xlim([startTimes(jj) stopTimes(jj)])
            subplot(312)
            plot(st1, ifr1, '.k')
            xlim([startTimes(jj) stopTimes(jj)])
            title('Ch11')
            subplot(313)
            plot(st2, ifr2, '.k')
            xlim([startTimes(jj) stopTimes(jj)])
            title('Ch12')
            
            channelstr = {'Ch11', 'Ch12'};
            [chanindex, ~] = listdlg('ListString', channelstr);
            if chanindex == 1
                spiketimes = st1;
            elseif chanindex == 2
                spiketimes = st2;
            end
        else
            spiketimes = data.Ch11.times;
        end
        ifr = [1./(spiketimes(2:end) - spiketimes(1:end-1)); 0];
        
        % save spiketimes data
        spikewin = spiketimes > startTimes(jj) & spiketimes < stopTimes(jj);
        recdata.spiketimes = spiketimes(spikewin) - startTimes(jj);
        recdata.ifr = ifr(spikewin);
        
        figure('Position', [1000 600 600 600])
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
        
        % save the file with the time point as a parameter so it can be
        % checked against original files
        parameters.startT = floor(startTimes(jj));
        savename = [D(ii).name(1:end-4) '_' num2str(floor(startTimes(jj))) 's'];
        save([savedir filesep savename '.mat'], 'parameters', 'recdata')
        
        clear recdata spiketimes st1 st2 ifr1 ifr2 ifr
        close all
    end
    clear parameters data
end
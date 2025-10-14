% Data Sorting
% Author: JDS
% Updated: 2.20.2025
% The purpose of this script is to go through the data exported from Spike2
% and put them in the proper format for analysis.
% The code is currently written for protocol A100142
clear; clc; close all
addpath(genpath('Functions'))

% Load data files
% source = '/Volumes/labs/ting/shared_ting/Jake/Workloop';
source = '/Users/jacobstephens/Documents/Data/Workloop';
path = uigetdir(source);
D = dir(path);
D = D(3:end);
savedir = [path filesep 'recdata'];
%%
close all
for ii = 1:numel(D)
    if ~contains(D(ii).name, '.mat')
        continue
    end
    % disp(D(ii).name)
    data = load([D(ii).folder filesep D(ii).name]);
    
    % PARAMETER EXTRACTION
    breaks = find(D(ii).name == '-' | D(ii).name == '_' |D(ii).name == ' ');
    parameters.ID = D(ii).name(1:breaks(3)-1);
    parameters.cell = D(ii).name(breaks(4)+1:breaks(5)-1);
    
    parameters.aff = D(ii).name(breaks(5)+1:end-4);
    % parameters

    % NUMERICAL DATA EXTRACTION
    Fmt = data.motor_F.values;
    Lmt = 2*data.motor_L.values;
    if isfield(data, 'SONOS')
        Lf = 15*data.SONOS.values;
    end
    if isfield(data, 'Spikes')
        spiketimes = data.Spikes.times;
    else
        continue
    end
    ifr = spikes2ifr(spiketimes);
    time = data.motor_F.times;
    if isfield(data, 'event2')
        act = data.event2.times;
    else
        act = data.event.times;
    end
    actrate = spikes2ifr(act);
    
     % find stretch periods
    [~, vmt, ~] = sgolaydiff(Lmt, 2, 501); % take the MTU velocity
    vmt = vmt/data.motor_L.interval; % divide by sampling rate
    vthr = 2.5; % set a velocity threshold to determine stretch periods
    stretchtimes = time(abs(vmt) > vthr);
    stretchint = stretchtimes(2:end) - stretchtimes(1:end - 1); % find the intervals between stretch
    startinds = find(stretchint > 1.2); % take the intervals that are >1.5s
    startTimes = [stretchtimes(1); stretchtimes(startinds+1)] - 0.75; % convert to time points corresponding with the start of a stretch
    stopTimes = [stretchtimes(startinds); stretchtimes(end)] + 0.75; % time pts corresponding to end of stretch
    
    % plot to check if needed
    % figure('Position', [0 500 1900 500])
    % plot(time, vmt)
    % hold on
    % plot(startTimes, zeros(numel(startTimes), 1), 'xg')
    % plot(stopTimes, zeros(numel(stopTimes), 1), 'xr')
    % hold off

    % loop through stretch periods to segment trials
    for jj = 1:numel(startTimes)

        % create time window
        win = time > startTimes(jj) & time < stopTimes(jj);

        % save the recorded data in the time window
        recdata.Lmt = Lmt(win);
        recdata.Fmt = Fmt(win);
        recdata.time = time(win) - startTimes(jj);
        recdata.Lf = Lf(win);

        spikewin = spiketimes > startTimes(jj) & spiketimes < stopTimes(jj);
        recdata.spiketimes = spiketimes(spikewin) - startTimes(jj);
        recdata.ifr = ifr(spikewin);

        actwin = act > startTimes(jj) & act < stopTimes(jj);
        recdata.act = act(actwin) - startTimes(jj);
        recdata.actrate = actrate(actwin);

        figure('Position', [0 100 600 800])
        subplot(411); plot(recdata.time, recdata.Lmt);
            yyaxis right; plot(recdata.act, recdata.actrate, '.r')
        subplot(412); plot(recdata.time, recdata.Lf - recdata.Lf(1))
        subplot(413); plot(recdata.time, recdata.Fmt)
            ax = gca;
        subplot(414); plot(recdata.spiketimes, recdata.ifr, '.k')
            xlim(ax.XAxis.Limits)

        liststr = {'ramp', 'triangle', 'sine', 'workloop', 'skip'};
        [a, b] = listdlg('ListString', liststr);
        close
        % disp([a b])
        if a == 5
            continue
        else
            parameters.type = liststr{a};
        end

        parameters.startTime = startTimes(jj);
        savename = [D(ii).name(1:end-4) '_' parameters.type '_' num2str(floor(startTimes(jj))) 's.mat'];
        save([savedir filesep savename], 'parameters', 'recdata')
        disp(savename)
        clear index
    end
    % disp(D(ii).name)
    % parameters
end
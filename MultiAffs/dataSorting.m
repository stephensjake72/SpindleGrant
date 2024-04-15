% Data Sorting
% Author: JDS
% Updated: 3/15/2024
% The purpose of this script is to go through the data exported from Spike2
% and put them in the proper format for analysis.
% The code is currently written for protocol A100142
clear
clc
close all
addpath(genpath('Functions'))

% Load data files
source = '/Volumes/labs/ting/shared_ting/Jake/';
path = uigetdir(source);
D = dir(path);
savedir = [path(1:find(path == '/', 1, 'last')) 'recdata'];
if ~exist(savedir, 'dir')
    mkdir(savedir)
end

D = D(3:end);
%%
close all
for ii = 1:numel(D)
    disp(D(ii).name)
    data = load([D(ii).folder filesep D(ii).name]);
    
    % PARAMETER EXTRACTION
    breaks = find(D(ii).name == '_');
    parameters.ID = D(ii).name(1:breaks(1)-1);
    parameters.cell = D(ii).name(breaks(2)+1:breaks(3)-1);
    parameters.aff = D(ii).name(breaks(3)+1:find(D(ii).name == '.')-1);
    % parameters

    % NUMERICAL DATA EXTRACTION
    Fmt = data.motor_F.values;
    Lmt = data.motor_L.values;
    if isfield(data, 'sonos')
        Lf = data.sonos.values;
    end
    spiketimes = data.Spikes1.times;

    ifr = spikes2ifr(spiketimes);
    time = data.motor_F.times;
    
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
    % figure
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
        if isfield(data, 'sonos')
            recdata.Lf = Lf(win)*15; % 15 mm / volt scaling factor
        end

        amp = max(recdata.Lmt) - min(recdata.Lmt);
        titlestr = '';
        savecheck = 1;
        if amp < 2
            savecheck = 0;
            titlestr = 'BAD :(';
        end

        spikewin = spiketimes > startTimes(jj) & spiketimes < stopTimes(jj);
        recdata.spiketimes = spiketimes(spikewin) - startTimes(jj);
        recdata.ifr = ifr(spikewin);

        % figure('Position', [1000 600 600 600])
        % subplot(311)
        % plot(recdata.time, recdata.Lmt)
        % subplot(312)
        % plot(recdata.time, recdata.Fmt)
        % ax = gca;
        % subplot(313)
        % plot(recdata.spiketimes, recdata.ifr, '.k')
        % xlim(ax.XAxis.Limits)
        % title(titlestr)

        parameters.startTime = startTimes(jj);
        savename = [D(ii).name(1:end-4) '_' num2str(floor(startTimes(jj))) 's.mat'];
        if savecheck == 1
            save([savedir filesep savename], 'parameters', 'recdata')
        end
        clear index
    end
    clear parameters recdata data
    % close all
end
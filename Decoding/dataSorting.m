% Data Sorting
% Author: JDS
% Updated: 2.20.2025
% The purpose of this script is to go through the data exported from Spike2
% and put them in the proper format for analysis.
% The code is currently written for protocol A100142
clear
clc
close all
addpath(genpath('Functions'))

% Load data files
source = '/Volumes/labs/ting/shared_ting/Jake/MultiAffs_mat';
path = uigetdir(source);
D = dir(path);
savedir = [path filesep 'recdata'];
if ~exist(savedir, 'dir')
    mkdir(savedir)
end

%%
close all
for ii = 1:numel(D)
    if ~contains(D(ii).name, '.mat')
        continue
    end
    disp(D(ii).name)
    data = load([D(ii).folder filesep D(ii).name]);
    
    % PARAMETER EXTRACTION
    breaks = find(D(ii).name == '-' | D(ii).name == '_');
    parameters.ID = D(ii).name(1:breaks(1)-1);
    parameters.cell = D(ii).name(breaks(2)+1:breaks(3)-1);
    parameters.aff = D(ii).name(breaks(3)+1:find(D(ii).name == '.')-1);
    % parameters

    % NUMERICAL DATA EXTRACTION
    Fmt = data.motor_F.values;
    Lmt = data.motor_L.values;
    if isfield(data, 'sonos')
        Lf = 15*data.sonos.values;
    end
    spiketimes = data.Spikes.times;

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
            recdata.Lf = Lf(win);
        end

        spikewin = spiketimes > startTimes(jj) & spiketimes < stopTimes(jj);
        recdata.spiketimes = spiketimes(spikewin) - startTimes(jj);
        recdata.ifr = ifr(spikewin);

        amp = max(recdata.Lmt) - min(recdata.Lmt);
        titlestr = '';
        savecheck = 1;
        if amp < 2
            savecheck = 0;
            titlestr = 'BAD :(';
        end

        parameters.startTime = startTimes(jj);
        
        amp = max(recdata.Lmt) - min(recdata.Lmt);
        maxt = max(recdata.time);

        check1 = amp > 3 && amp < 3.2;
        check2 = amp > 3.8 && amp < 4.3;
        check3 = maxt > 2.5 && maxt < 3;
        check4 = maxt > 5.8 && maxt < 6.2;
        % check5 = 
        skip = 0;
        if check1 && check3 % ramp
            subplot(411)
            parameters.type = 'ramp';
        elseif check1 && check4 % triangle
            subplot(412)
            parameters.type = 'triangle';
        elseif check2 % sinusoid
            subplot(413)
            parameters.type = 'sine';
        else
            subplot(414)
            skip = 1;
        end
        hold on
        plot(recdata.time, recdata.Lmt - recdata.Lmt(1))
        
        if skip == 0
            savename = [D(ii).name(1:end-4) '_' parameters.type '_' num2str(floor(startTimes(jj))) 's.mat'];
            save([savedir filesep savename], 'parameters', 'recdata')
            disp(savename)
        end
        clear index
    end
    clear parameters recdata data
    % close all
end
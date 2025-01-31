% Data Sorting
% Author: JDS
% Updated: 

clear
clc
close all
addpath(genpath('Functions'))

% Load data files
path = '/Volumes/labs/ting/shared_ting/Jake/Workloop/';
source = uigetdir(path);

savedir = [source filesep 'recdata'];

if ~exist(savedir, 'dir')
    mkdir(savedir)
end

D = dir(source);
%%
for n = 1:length(D) %7
    if ~contains(D(n).name, '.mat')
        continue
    end
    disp(D(n).name)
    data = load([D(n).folder filesep D(n).name]);
    
    % PARAMETER EXTRACTION
    breaks = find(D(n).name == '-');
    parameters.Animal = D(n).name(1:breaks(3)-1)
    parameters.cellnum = D(n).name(breaks(4)+1:breaks(5)-1)
    parameters.celltype = D(n).name(breaks(5)+1:breaks(6)-1);
    
    % % NUMERICAL DATA EXTRACTION
    Lmt = data.motor_L.values;
    time = data.motor_L.times;
    Fmt = data.motor_F.values;
    Lf = data.SONOS.values;
    spiketimes = data.Spikes.times;
    acttimes = data.event.times;

    % PARSE STRETCHES
    [startTimes, stopTimes] = findIntervals(time, Lmt);
    
    %SAVE INDIVIDUAL STRETCH TRIALS
    for jj = 1:numel(startTimes)

        % create time window
        win = time > startTimes(jj) & time < stopTimes(jj);
        % segment data accordingly
        recdata.Lmt = Lmt(win);
        recdata.Lmt = recdata.Lmt - recdata.Lmt(1);
        recdata.Lf = Lf(win);
        recdata.Lf = recdata.Lf - recdata.Lf(1);
        recdata.Fmt = Fmt(win);
        recdata.time = time(win) - startTimes(jj);

        % redo for spiketimes
        spikewin = spiketimes > startTimes(jj) & spiketimes < stopTimes(jj);
        recdata.spiketimes = spiketimes(spikewin) - startTimes(jj);
        recdata.ifr = spikes2ifr(recdata.spiketimes);

        % redo for activation
        actwin = acttimes > startTimes(jj) & acttimes < stopTimes(jj);
        recdata.acttimes = acttimes(actwin) - startTimes(jj);
        recdata.actrate = spikes2ifr(recdata.acttimes);

        figure('Position', [0 0 800 800])
        subplot(411)
        plot(recdata.time, recdata.Lmt, recdata.time, recdata.Lf)
        ax = gca;
        subplot(412)
        plot(recdata.time, recdata.Fmt)
        xlim(ax.XAxis.Limits)
        subplot(413)
        plot(recdata.spiketimes, recdata.ifr, '.k')
        xlim(ax.XAxis.Limits)
        subplot(414)
        plot(recdata.acttimes, recdata.actrate, '.r')
        xlim(ax.XAxis.Limits)

        % pull up dialog box to save the file or not
        textstr = {'ramp', 'triangle', 'sine', 'workloop', 'discard'};
        [index, ~] = listdlg('ListString', textstr);
        if isempty(index)
            break
        elseif index == 5
            close
            continue
        else
            choice = textstr{index};
        end

        parameters.type = choice;
        parameters.startT = floor(startTimes(jj));

        savename = [D(n).name(1:end-4) '_' choice '_' num2str(parameters.startT) 's.mat'];
        save([savedir filesep savename], 'recdata', 'parameters')
    % 
        close
    end

    clear parameters
    clear recdata
    close all
    
end
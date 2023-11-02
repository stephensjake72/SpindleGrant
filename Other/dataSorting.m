% Data Sorting
% Author: JDS
% Updated: 

clear
clc
close all
addpath(genpath('Functions'))

% Load data files
source = uigetdir();
%%

savedir = [source(1:find(source == filesep, 1, 'last')) 'recdata'];

if ~exist(savedir, 'dir')
    mkdir(savedir)
end

%%
D = dir(source);
D = D(3:end);
%%
for ii = 1:numel(D)
    disp(ii)
    data = load([D(ii).folder filesep D(ii).name]);
    
    % PARAMETER EXTRACTION
    breaks = find(D(ii).name == '_');
    parameters.ID = D(ii).name(1:breaks(1)-1);
    parameters.cell = D(ii).name(breaks(2)+1:breaks(3)-1);
    parameters.aff = D(ii).name(breaks(3)+1:breaks(3)+2);
    
    % NUMERICAL DATA EXTRACTION
    Lmt = data.motor_L.values;
    if isfield(data.motor_L, 'times')
        time = data.motor_L.times;
    else
        time = (1:numel(Lmt))'*data.motor_L.interval - data.motor_L.interval;
    end
    
    Fmt = data.motor_F.values;
    
    Lf = data.SONOS.values*15;
    
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
        
        figure('Position', [0 0 800 800])
        subplot(411)
        plot(recdata.time, recdata.Lmt, recdata.time, recdata.Lf)
        ax = gca;
        subplot(412)
        plot(recdata.time, recdata.Fmt)
        subplot(413)
        plot(recdata.spiketimes, recdata.ifr, '.k')
        subplot(414)
        plot(recdata.acttimes, ones(size(recdata.acttimes)), '|r')
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
        
        savename = [D(ii).name(1:end-4) '_' choice '_' num2str(parameters.startT) 's.mat'];
        save([savedir filesep savename], 'recdata', 'parameters')
        
        close
    end
    
    clear parameters
    clear recdata
    close all
    
end
% Data Sorting
% Author: JDS
% Updated: 5/09/2023
% The purpose of this script is to go through the data exported from Spike2
% and put them in the proper format for analysis.
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

for ii =  36:length(D) %1:numel(D)
    disp(D(ii).name)
    data = load([D(ii).folder filesep D(ii).name]);
    
    % pull different spike channels
    fields = fieldnames(data);
    spikefields = fields(contains(fields, 'Spikes'));
    
    % create time vector based on sampling interval
    time = (0:data.motor_L.length - 1)*data.motor_L.interval;
    
    % pull numerical data
    Lmt = data.motor_L.values;
    Fmt = data.motor_F.values;
    Lf = data.SONOS.values;
    act = data.event.times;
    
    % take filtered mtu velocity to identify stretching periods during the
    % expt
    N = 2;
    W = 501;
    [~, vmt, ~] = sgolaydiff(Lmt, N, W);
    vmt = vmt/data.motor_L.interval;
    
    vthr = 1.5;
    % times where displacement occurs
    stretchtimes = time(abs(vmt) > vthr);
    % intervals between stretch times
    stretchint = stretchtimes(2:end) - stretchtimes(1:end-1);
    % find intervals >1.2 s between lengthening to identify different trials
    startinds = find(stretchint > 1.5);
    % use intervals to create vectors of trial start and end times
    startTimes = [stretchtimes(1) stretchtimes(startinds+1)] - 0.75;
    stopTimes = [stretchtimes(startinds) stretchtimes(end)] + 0.75;
    
    % loop through trials within the expt
    for jj = 1:numel(startTimes)
        % segment time series data
        win = find(time >= startTimes(jj) & time < stopTimes(jj));
        actwin = act >= startTimes(jj) & act < stopTimes(jj);
        recdata.time = time(win) - time(win(1))';
        recdata.Lmt = Lmt(win);
        recdata.Lf = Lf(win);
        recdata.Fmt = Fmt(win);
        recdata.act = act(actwin) - startTimes(jj);
        
        % skip trials with muscle stim
        figure('Position', [100 400 500 500])
        subplot(411)
        plot(recdata.time, recdata.Lmt)
        ax = gca;
        subplot(412)
        plot(recdata.time, recdata.Lf)
        xlim(ax.XAxis.Limits)
        subplot(413)
        plot(recdata.time, recdata.Fmt)
        xlim(ax.XAxis.Limits)
        subplot(414)
        plot(recdata.act, ones(1, numel(recdata.act)), '|r')
        xlim(ax.XAxis.Limits)
        
        text1 = {'keep', 'skip'};
        [index, ~] = listdlg('ListString', text1);
        if isempty(index)
            break
        elseif index == 2
            close
            continue
        end
        close
        
        % select spike channel if needed
        if length(spikefields) == 1
            spiketimes = data.(spikefields{1}).times;
        else
            n = length(spikefields);
            figure('Position', [100 400 500 500])
            subplot(n + 1, 1, 1)
            plot(recdata.time, recdata.Lmt)
            for kk = 1:n
                tempst = data.(spikefields{kk}).times;
                tempifr = spikes2ifr(tempst);
                subplot(n + 1, 1, kk + 1)
                plot(tempst, tempifr, '.k')
                xlim([startTimes(jj) stopTimes(jj)])
                title(spikefields{kk})
            end
            
            [index2, ~] = listdlg('ListString', [spikefields; 'skip']);
            if index2 == length(spikefields) + 1
                continue
            end
            spiketimes = data.(spikefields{index2}).times;
            clear tempst tempifr index2
        end
        close all
        spikewin = spiketimes >= startTimes(jj) & spiketimes < stopTimes(jj);
        recdata.spiketimes = spiketimes(spikewin) - startTimes(jj);
        recdata.ifr = spikes2ifr(recdata.spiketimes);
        
        % PARAMETER EXTRACTION
        unds = find(D(ii).name == '_');
        parameters.ID = D(ii).name(1:unds(1)-1);
        parameters.cell = D(ii).name(unds(2)+1:unds(3)-1);
        parameters.aff = 'IA';
        parameters.KT = D(ii).name(find(D(ii).name == 'K') + 1);
        parameters.startT = startTimes(jj);
        
        savename = [D(ii).name(1:end-4) '_' num2str(round(startTimes(jj))) 's.mat'];
        save([savedir filesep savename], 'recdata', 'parameters')
        
        clear recdata parameters index
    end
    close all
end
% Script to process data
% Author: JDS
% Updated: 2.20.2025
clc; clear; close all
addpath(genpath('Functions'))

% Load data files
path = uigetdir('/Users/jacobstephens/Documents/Data/Workloop/', 'Animal folder');
D = dir([path filesep 'recdata']);
savedir = [path filesep 'procdata'];
D = D(3:end);
%%
close all
% loop through experiment files
for ii = 1:numel(D)
    if ~contains(D(ii).name, '.mat')
        continue
    end
    disp(ii)
    data = load([D(ii).folder filesep D(ii).name]);
    
    % subtract initial sonos
    data.recdata.Lf = data.recdata.Lf - data.recdata.Lf(1);

    % downsampling factor
    dsf = 1;
    
    % butterworth filter design
    fsample = 1/(dsf*(data.recdata.time(2)-data.recdata.time(1)));
    fstop = 200; % 200 Hz cutoff
    n = 4; % 4th order
    Wn = 2*fstop/fsample;
    [b, a] = butter(n, Wn, 'low');

    % SG parameters
    fOrder = 2;
    Width = 201; % 51 samples/1700 Hz ~ 30 ms

    ref = data.recdata.time;
    channels = fieldnames(data.recdata);
    for jj = 1:numel(channels)

        vec = data.recdata.(channels{jj});

        keep = ones(size(vec));
        derivcheck = 0;
        % check if a time series vector
        if length(data.recdata.(channels{jj})) == length(ref)

            % downsample
            vec = vec(1:dsf:end);

            if ~strcmp(channels{jj}, 'time')
                derivcheck = 1;

                % lowpass
                vec = filtfilt(b, a, vec);
    
                % smooth and differentiate with SV filter
                [~, vec2, vec3] = sgolaydiff(vec, fOrder, Width);
            end

            % get rid of nans
            keep = zeros(size(vec));
            keep(ceil(Width/2):length(vec) - ceil(Width/2)) = 1;
            
        end
        keep = logical(keep);
        procdata.(channels{jj}) = vec(keep);

        % export derivatives
        if derivcheck
            % multiply by sampling frequency to get the actual d/dt
            procdata.(['d' channels{jj}]) = fsample*vec2(keep); % first deriv
            procdata.(['dd' channels{jj}]) = (fsample^2)*vec3(keep); % second deriv
        end
    end

    tstart = procdata.time(find(abs(procdata.dLmt) >= 0.75, 1, 'first')); % 450 low
    if isempty(tstart)
        continue
    end
    procdata.time = procdata.time - tstart;
    procdata.spiketimes = procdata.spiketimes - tstart;
    procdata.act = data.recdata.act - tstart; 

    procdata.Lmt = procdata.Lmt - procdata.Lmt(find(procdata.time <= 0, 1, 'last'));
    % subplot(311)
    % hold on
    % plot(procdata.time, procdata.Lmt)
    % xlim([-.5 4])
    % ax = gca;
    % subplot(312)
    % hold on
    % plot(procdata.time, procdata.dLmt)
    % xlim(ax.XAxis.Limits)
    % subplot(313)
    % hold on
    % plot(procdata.spiketimes, procdata.ifr, '.k')
    % xlim(ax.XAxis.Limits)
    % 
    % if mod(ii, 5) == 0
    %     figure
    %     plotProcData(procdata, 'sonos')
    %     % plot(procdata.time, procdata.Lmt)
    % end
    if strcmp(data.parameters.type, 'workloop')
        figure
        plot(procdata.time, procdata.Fmt)
        hold on; plot(data.recdata.act, zeros(size(data.recdata.act)), 'xr')
        plot(procdata.act, zeros(size(procdata.act)), '|g')
        yyaxis right; plot(procdata.time, procdata.Lmt)
        xlim([-.5 6])
    end

    parameters = data.parameters;
    % break
    save([savedir filesep D(ii).name(1:end-4)], 'procdata', 'parameters')
end

%%
% run('appendStretchV.m')
% run('appendFreq.m')
run('appendAmp.m')
run('appendPhase.m')
run('appendSmoothSpikes.m')
run('writelookuptable.m')
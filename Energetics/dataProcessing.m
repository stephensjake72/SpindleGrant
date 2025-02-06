% Script to process data
% Author: JDS
% Updated: 3/19/24
clc
clear
close all
addpath(genpath('Functions'))

% Load data files
path = uigetdir('/Volumes/labs/ting/shared_ting/Jake/MultiAffs_mat');
D = dir(path);
savedir = [path(1:find(path == filesep, 1, 'last')) 'procdata'];
% if ~exist(savedir, 'dir')
%     mkdir(savedir)
% end

D = D(3:end);
%%
% loop through experiment files
for ii = 1:numel(D)
    disp(ii)
    data = load([D(ii).folder filesep D(ii).name]);
    
    % subtract initial sonos
    data.recdata.Lf = data.recdata.Lf - data.recdata.Lf(1);

    % downsampling factor
    dsf = 10;
    
    % butterworth filter design
    fsample = 1/(dsf*(data.recdata.time(2)-data.recdata.time(1)));
    fstop = 100; % 100 Hz cutoff
    n = 4; % 4th order
    Wn = 2*fstop/fsample;
    [b, a] = butter(n, Wn, 'low');

    % SG parameters
    fOrder = 2;
    Width = 51; % 51 samples/1700 Hz ~ 30 ms

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

        % optionally export derivatives
        if derivcheck
            % multiply by sampling frequency to get the actual d/dt
            procdata.(['d' channels{jj}]) = fsample*vec2(keep); % first deriv
            procdata.(['dd' channels{jj}]) = (fsample^2)*vec3(keep); % second deriv
        end
    end
    
    procdata.Lmt = procdata.Lmt - procdata.Lmt(1);

    tstart = procdata.time(find(procdata.ddLmt > 150, 1, 'first'));
    if isempty(tstart)
        continue
    end
    procdata.time = procdata.time - tstart;
    procdata.spiketimes = procdata.spiketimes - tstart;
    % if mod(ii, 5) == 0
        hold on
        % plotProcData(procdata, 'sonos')
        plot(procdata.time, procdata.Lf)
    % end

    parameters = data.parameters;
    save([savedir filesep D(ii).name(1:end-4)], 'procdata', 'parameters')
end
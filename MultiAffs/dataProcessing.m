% Script to process data
% Author: JDS
% Updated: 3/19/24
clc
clear
close all
addpath(genpath('Functions'))

% Load data files
path = uigetdir('/Volumes/labs/ting/shared_ting/Jake/');
D = dir(path);
savedir = [path(1:find(path == filesep, 1, 'last')) filesep 'procdata'];
if ~exist(savedir, 'dir')
    mkdir(savedir)
end

D = D(3:end);
%%
% loop through experiment files
for ii = 1:numel(D)
    disp(ii)
    data = load([D(ii).folder filesep D(ii).name]);
    
    % downsampling factor
    dsf = 20;
    
    % butterworth filter design
    fsample = 1/(dsf*(data.recdata.time(2)-data.recdata.time(1)));
    fstop = 200; % 200Hz cutoff
    n = 4; % 4th order
    Wn = 2*fstop/fsample;
    [b, a] = butter(n, Wn, 'low');

    % SG parameters
    fOrder = 2;
    Width = 21; % 21 samples/893 Hz = 23.5 ms

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
            procdata.(['d' channels{jj}]) = vec2(keep); % first deriv
            procdata.(['dd' channels{jj}]) = vec3(keep); % second deriv
        end
    end

    % figure
    % plotProcData(procdata, ' ')

    procdata.Lmt = procdata.Lmt - procdata.Lmt(1);
    parameters = data.parameters;
    save([savedir filesep D(ii).name(1:end-4)], 'procdata', 'parameters')
end
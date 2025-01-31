clc; clear;
close all
addpath(genpath('Functions'))

%% load sample IA ramps for CB sim

% animal and cell number for the example data
ia_animalnum = 'A100142-24-62';
ia_cellnum = 'cell-6';

% load the directory for the example animal
D = dir(['/Volumes/labs/ting/shared_ting/Jake/MultiAffs_mat/' ia_animalnum '/recdata']);
D = D(3:end);
%% part 1, pull data
% create data storage matrices
numtrials = 1e3;
numsamples = 55000;
LF = zeros(numtrials, numsamples);
TIME = zeros(numtrials, numsamples);
stretchv = zeros(1, numtrials);
count = 1;

% loop through files
for ii = 2:length(D)
    
    if contains(D(ii).name, 'ramp') && contains(D(ii).name, [ia_animalnum '-'])
        % disp(ii)
        data = load([D(ii).folder filesep D(ii).name]);
        
        disp(data.parameters.startTime)

        % first thing to do is align the data at t0 //////////////////////
        Lmt = data.recdata.Lmt;
        t = data.recdata.time;

        % lowpass parameters
        fsample = 1/diff(t(1:2));
        fstop = 200; % 200Hz cutoff
        n = 4; % 4th order
        Wn = 2*fstop/fsample;
        [b, a] = butter(n, Wn, 'low');
        % sgolay filter & differentiation parameters
        fOrder = 2;
        Width = 201;
        % apply filters
        Lmt2 = filtfilt(b, a, Lmt); % lowpass
        [~, dLmt2, ddLmt2] = sgolaydiff(Lmt2, fOrder, Width); % diffs
        dLmt2 = dLmt2*fsample; % rescale diffs
        ddLmt2 = ddLmt2*fsample^2;

        % plot to check
        % subplot(211)
        % plot(t, Lmt, t, Lmt2)
        % subplot(212)
        % plot(t, ddLmt2)
        % use acceleration to find a consistent t0
        thr = 500;
        istart = find(ddLmt2 > thr & t > 0.5, 1, 'first');
        tstart = t(istart);

        keep = (istart-14999):(istart+40000);

        L0 = Lmt2(istart);
        Lmt3 = Lmt2 - L0;

        % plot to check t0
        % hold on
        % plot(t-tstart, Lmt3)

        % now we have a consistent t0, we can align the sonos
        Lf = data.recdata.Lf - data.recdata.Lf(1);

        % filter 

        LF(count, :) = Lf(keep);
        TIME(count, :) = t(keep) - tstart;
        stretchv(count) = floor(mean(dLmt2(dLmt2 > .9*max(dLmt2))));
        count = count + 1;

        % hold on
        % plot(t(keep) - tstart, Lf(keep))
        
    end
end

LF(count:end, :) = [];
TIME(count:end, :) = [];
stretchv(count:end) = [];

plot(TIME', LF')
%% part 2, process data

% average over each velocity value
vvals = unique(stretchv);
rampsample.dLf = zeros(length(vvals), length(TIME)/10 - 11);
for vnum = 1:length(vvals)
    rownums = find(stretchv == vvals(vnum));
    tempmat = LF(rownums, 1:10:end);
    for jj = 1:length(rownums)
        tempmat(jj, :) = smooth(tempmat(jj, :), 100);
    end
    TRAJS = mean(tempmat);
    TIMES = TIME(rownums, 1:10:end);

    [~, dLf, ~] = sgolaydiff(TRAJS - TRAJS(1), 2, 11);

    subplot(length(vvals), 1, vnum)
    plot(TIMES(1, :), dLf)

    rampsample.dLf(vnum, :) = dLf(6:end-6);
end

rampsample.time = TIMES(1, 6:end-6);
rampsample.stretchv = vvals;

% save data
% save('rampsample.mat', 'rampsample', '-mat')
figure
plot(rampsample.time', rampsample.dLf')
%% repeat for triangle
% create data storage matrices
numtrials = 1e3;
numsamples = 91000;
LF = zeros(numtrials, numsamples);
TIME = zeros(numtrials, numsamples);
count = 1;

% loop through files
for ii = 1:length(D)
    
    if contains(D(ii).name, 'triangle') && contains(D(ii).name, [ia_animalnum '-'])
        % disp(ii)
        data = load([D(ii).folder filesep D(ii).name]);
        if data.parameters.startTime < 40
            continue
        end
        disp(data.parameters.startTime)

        % first thing to do is align the data at t0 //////////////////////
        Lmt = data.recdata.Lmt;
        t = data.recdata.time;

        % lowpass parameters
        fsample = 1/diff(t(1:2));
        fstop = 200; % 200Hz cutoff
        n = 4; % 4th order
        Wn = 2*fstop/fsample;
        [b, a] = butter(n, Wn, 'low');
        % sgolay filter & differentiation parameters
        fOrder = 2;
        Width = 201;
        % apply filters
        Lmt2 = filtfilt(b, a, Lmt); % lowpass
        [~, dLmt2, ddLmt2] = sgolaydiff(Lmt2, fOrder, Width); % diffs
        dLmt2 = dLmt2*fsample; % rescale diffs
        ddLmt2 = ddLmt2*fsample^2;

        % plot to check
        % subplot(211)
        % plot(t, Lmt, t, Lmt2)
        % subplot(212)
        % plot(t, ddLmt2)

        % use acceleration to find a consistent t0
        thr = 400;
        istart = find(ddLmt2 > thr & t > 0.1, 1, 'first');
        tstart = t(istart);

        keep = istart + (-4999:(numsamples - 5000));

        L0 = Lmt2(istart);
        Lmt3 = Lmt2 - L0;

        % % plot to check t0
        % hold on
        % plot(t-tstart, Lmt3)

        % now we have a consistent t0, we can align the sonos
        Lf = data.recdata.Lf - data.recdata.Lf(1);

        LF(count, :) = Lf(keep);
        TIME(count, :) = t(keep) - tstart;
        stretchv(count) = floor(mean(dLmt2(dLmt2 > .9*max(dLmt2))));
        count = count + 1;

        % hold on
        % plot(t(keep) - tstart, Lf(keep))
        
    end
end

LF(count:end, :) = [];
TIME(count:end, :) = [];
stretchv(count:end) = [];

plot(TIME', LF')
%% part 2, process data

% trisample.dLf = zeros(1, length(TIME)/10 - 51);

tempmat = LF(:, 1:10:end);
for jj = 1:height(tempmat)
    tempmat(jj, :) = smooth(tempmat(jj, :), 250);
end
TRAJS = mean(tempmat);
TIMES = TIME(:, 1:10:end);

[~, dLf, ~] = sgolaydiff(TRAJS, 2, 51);

% plot(TIMES(1, :), dLf)

trisample.dLf = dLf(26:end-26);
trisample.time = TIMES(1, 26:end-26);

plot(trisample.time, trisample.dLf)
% save data
save('trisample.mat', 'trisample', '-mat')

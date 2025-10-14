clc; clear; close all

addpath(genpath('Functions'))
d = dir('/Volumes/labs/ting/shared_ting/Jake/decoding_models_procdata/');
d = d(3:end);
%%
clc; close all

count = [1 1 1 1];

% tiledlayout('flow')
for n = 250:length(d) %1:length(d)
    data = load([d(n).folder filesep d(n).name]);
    if strcmp(data.parameters.aff, 'IA') && strcmp(data.parameters.type, 'ramp')
        disp(n)
        % iadata(count(1)) = data;
        R = smoothSpikes(data, 21);

        figure('Position', [0 0 1200 800])
        subplot(211); plot(R.t, R.r)
        hold on; plot(data.procdata.spiketimes, data.procdata.ifr, '.k')
        % xlim([0 0.05])
        subplot(212); plot(R.t, R.interval)
        % xlim([0 0.05])
        ax = gca;
        ax.XAxis.Visible = 'off';
        % nexttile
        % count(1) = count(1) + 1;
        % if mod(count(1), 10) == 0
        %     figure('Position', [0 0 1200 800])
        %     tiledlayout('flow')
        % end
    % elseif strcmp(data.parameters.aff, 'II')
    %     iidata(count(2)) = data;
    %     iidata(count(2)).R = filtspikesignal(data);
    %     count(2) = count(2) + 1;
    % elseif strcmp(data.parameters.aff, 'IB')
    %     ibdata(count(3)) = data;
    %     ibdata(count(3)).R = filtspikesignal(data);
    %     count(3) = count(3) + 1;
    % elseif strcmp(data.parameters.aff, 'IX')
    %     ixdata(count(4)) = data;
    %     ixdata(count(4)).R = filtspikesignal(data);
    %     count(4) = count(4) + 1;
    end
end

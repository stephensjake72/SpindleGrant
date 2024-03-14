% classify

clear
clc
close all
addpath(genpath('Functions'))

% Load data files
source = '/Volumes/labs/ting/shared_ting/Jake/';
path = uigetdir(source);
D = dir(path);
D = D(3:end);
%%
close all
for ii = 1:numel(D)
    disp(ii)
    data = load([D(ii).folder filesep D(ii).name]);
    parameters = data.parameters;

    amp = max(data.procdata.Lmt) - min(data.procdata.Lmt);

    rampcheck = max(data.procdata.time) < 3 && amp >= 2.8 && amp < 3.2;
    tricheck = max(data.procdata.time) > 4.5 && amp >= 2.8 && amp < 3.2;
    sinecheck = amp > 1.9 && amp < 2.1;
    if rampcheck
        subplot(411)
        parameters.type = 'ramp';
    elseif tricheck
        subplot(412)
        parameters.type = 'tri';
    elseif sinecheck
        subplot(413)
        parameters.type = 'sine';
    else
        subplot(414)
        parameters.type = 'other';
    end
    hold on
    plot(data.procdata.time, data.procdata.Lmt)
    % rampcheck = sum(abs(data.procdata.vmt) > 15) > 100 & max(data.procdata.time) < 3;
    % tricheck = sum(abs(data.procdata.vmt) > 12) < 25 & max(data.procdata.time) < 8 & max(data.procdata.vmt) < 10;
    % othercheck = max(data.procdata.time) > 20;
    % if rampcheck
    %     subplot(141)
    %     hold on
    %     plot(data.procdata.time, data.procdata.vmt)
    % 
    %     parameters.type = 'ramp';
    % elseif tricheck
    %     subplot(142)
    %     hold on
    %     plot(data.procdata.time, data.procdata.vmt)
    % 
    %     parameters.type = 'triangle';
    % elseif othercheck
    %     subplot(144)
    %     hold on
    %     plot(data.procdata.time, data.procdata.vmt)
    % 
    %     parameters.type = 'other';
    % else
    %     subplot(143)
    %     hold on
    %     plot(data.procdata.time, data.procdata.vmt)
    % 
    %     parameters.type = 'sine';
    % end
    % hold off
    % 
    save([D(ii).folder filesep D(ii).name], 'parameters', '-append')
end
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
    maxt = max(data.procdata.time);

    rampcheck = amp >= 2.8 && amp < 3.4 && maxt < 3 && maxt > 1.5;
    tricheck = amp >= 2.8 && amp < 3.4 && max(data.procdata.time) < 8;
    sinecheck = amp > 3.9 && amp < 4.2;
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
    % save([D(ii).folder filesep D(ii).name], 'parameters', '-append')
end
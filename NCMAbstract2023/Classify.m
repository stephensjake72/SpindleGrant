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
for ii = 1:numel(D)
    disp(ii)
    data = load([D(ii).folder filesep D(ii).name]);
    parameters = data.parameters;
    
    rampcheck = sum(abs(data.procdata.vmt) > 15) > 100;
    tricheck = sum(abs(data.procdata.vmt) > 12) < 25;
    if rampcheck
        subplot(131)
        hold on
        plot(data.procdata.time, data.procdata.vmt)
        
        parameters.type = 'ramp';
    elseif tricheck
        subplot(132)
        hold on
        plot(data.procdata.time, data.procdata.vmt)
        
        parameters.type = 'triangle';
    end
    hold off
    
    save([D(ii).folder filesep D(ii).name], 'parameters', '-append')
end
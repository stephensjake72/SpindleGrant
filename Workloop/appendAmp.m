% run this script after dataProcessing

clc; clear; close all


addpath(genpath('Functions'))

% loc = '/Volumes/labs/ting/shared_ting/Jake/Workloop/';
loc = '/Users/jacobstephens/Documents/Data/Workloop/';
d = dir(loc);

%%

for n = 1:length(d)
    if ~contains(d(n).name, 'A100')
        continue
    else
        subdir = dir([d(n).folder filesep d(n).name filesep 'procdata']);
    end

    if isempty(subdir)
        continue
    end

    figure
    for m = 3:length(subdir)
        if ~contains(subdir(m).name, '.mat')
            continue
        end
        data = load([subdir(m).folder filesep subdir(m).name]);
        parameters = data.parameters;
        disp(m)
        if strcmp(data.parameters.type, 'workloop')
            [p, l] = findpeaks(data.procdata.Lmt, ...
                'MinPeakHeight', 1, ...
                'MinPeakProminence', 2);
            hold on; plot(data.procdata.time, data.procdata.Lmt)
            % hold on; plot(data.procdata.time(l), p, 'xr')
            parameters = data.parameters;
            parameters.amp = round(mean(p)*2)/2;
        else
            parameters.amp = round(max(data.procdata.Lmt)*2)/2;
        end
        save([subdir(m).folder filesep subdir(m).name], 'parameters', '-append')
    end
end

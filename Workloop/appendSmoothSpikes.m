% append continuous spike signals

clc; clear; close all;

addpath(genpath('Functions'))

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

    count = 1;
    figure('Position', [0 0 1900 1000])
    for m = 3:length(subdir)
        if ~contains(subdir(m).name, '.mat')
            continue
        end
        data = load([subdir(m).folder filesep subdir(m).name]);
        parameters = data.parameters;
        disp(m)
        R = smoothSpikes(data, 5, -2.5);
        if strcmp(data.parameters.type, 'workloop')
            subplot(8, 1, count)
            plot(data.procdata.spiketimes, data.procdata.ifr, '.k')
            hold on; plot(R.t, R.r)
            if count == 8
                figure('Position', [0 0 1900 1000])
                count = 0;
            end
            count = count + 1;
        end
        save([subdir(m).folder filesep subdir(m).name], 'R', '-append')
    end
end

% run this script after dataProcessing

clc; clear; close all


addpath(genpath('Functions'))

loc = '/Volumes/labs/ting/shared_ting/Jake/MultiAffs_mat/';
d = dir(loc);

%%
close all; clc;

for n = 1:length(d)
    if ~contains(d(n).name, 'A100')
        continue
    else
        subdir = dir([d(n).folder filesep d(n).name filesep 'procdata']);
    end

    if isempty(subdir)
        continue
    end

    for m = 3:length(subdir)
        data = load([subdir(m).folder filesep subdir(m).name]);
        parameters = data.parameters;

        if contains(subdir(m).name, 'sine')
            parameters.f = getFreq(data.procdata);
        else
            parameters.f = 0;
        end
        
        disp(parameters.f)
        if parameters.f == 2
            subplot(311)
        elseif parameters.f == 0
            subplot(313)
        else
            subplot(312)
        end
        hold on
        plot(data.procdata.time, data.procdata.Lmt)
        
        save([subdir(m).folder filesep subdir(m).name], 'parameters', '-append')
    end
end

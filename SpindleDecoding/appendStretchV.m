% run this script after dataProcessing

clc; clear; close all


addpath(genpath('Functions'))

loc = '/Volumes/labs/ting/shared_ting/Jake/MultiAffs_mat/';
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

    for m = 3:length(subdir)
        data = load([subdir(m).folder filesep subdir(m).name]);

        % hold on
        % plot(data.procdata.time, data.procdata.dLmt)
        
        parameters = data.parameters;
        parameters.stretchV = getStretchV(data.procdata);
        save([subdir(m).folder filesep subdir(m).name], 'parameters', '-append')
    end
end

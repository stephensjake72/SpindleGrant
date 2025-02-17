clc; clear; close all;

addpath(genpath('Functions'))

loc = '/Volumes/labs/ting/shared_ting/Jake/MultiAffs_mat/';
d = dir(loc);
%%
close all

opts = {d.name};
sel = listdlg('ListString', opts);
folders = opts(sel);

for n = 1:length(folders)
    subdir = dir([loc folders{n} '/procdata']);
    for m = 1:length(subdir)
        if contains(subdir(m).name, 'cell-1-') && contains(subdir(m).name, 'ramp')
            data = load([subdir(m).folder filesep subdir(m).name]);

            % fit model coefficients
            parameters = [100 10; 0 0; 500 100];
            fit = getLVgains(data.procdata, parameters);

            plotLVmodel(fit)
        end
    end
end
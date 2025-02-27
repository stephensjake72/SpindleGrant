clc; clear; close all;

addpath(genpath('Functions'))

loc = '/Volumes/labs/ting/shared_ting/Jake/MultiAffs_mat/';
d = dir(loc);
%% get LV model gains
close all

opts = {d.name};
sel = listdlg('ListString', opts);
folders = opts(sel);

for n = 1:length(folders)
    subdir = dir([loc folders{n} '/procdata']);
    for m = 1:length(subdir)
        if contains(subdir(m).name, '.mat')
            data = load([subdir(m).folder filesep subdir(m).name]);
    
            % fit model coefficients
            parameters = [100 10; 0 0; 500 100];
            fit = getLVgains(data.procdata, parameters);
    
            hold on
            plot(data.procdata.time, data.procdata.Lf)
            % plotLVmodel(fit)
            % 
            % save([subdir(m).folder filesep subdir(m).name], 'fit', '-append')
        end
    end
end
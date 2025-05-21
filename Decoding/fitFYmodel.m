% fit models
clc; clear; close all


addpath(genpath('Functions'))

loc = '/Volumes/labs/ting/shared_ting/Jake/MultiAffs_mat/';
d = dir(loc);

savedir = ['/Users/jacobstephens/Documents/Data/decodingmodelfitting' filesep 'FY-' char(datetime('today'))];
figsavedir = ['/Users/jacobstephens/Documents/Data/decodingmodelfittingfigs' filesep 'FY-' char(datetime('today'))];
if ~isfolder(savedir)
    mkdir(savedir)
end
if ~isfolder(figsavedir)
    mkdir(figsavedir)
end

%%
clc; close all;

workdir = dir;
NCmods = {workdir(contains({workdir.name}, 'A100')).name};

for n = 1:length(NCmods)
    NC = load(NCmods{n});
    expname = NCmods{n}(1:end-7);
    subdir = dir([loc filesep expname filesep 'procdata']);
    for m = 1:length(subdir)
        if ~contains(subdir(m).name, '.mat')
            continue
        else
            data = load([subdir(m).folder filesep subdir(m).name]);
            if length(data.procdata.spiketimes) < 3
                continue
            end

            % kf, ky, b, L0
            up = [500 50 150 0.1];
            low = [0 0 -50 -.1];
            init = [500 50 0 0];

            fyparams = [init; low; up];
            fy_fit = getFYgains(data.procdata, NC.NC, fyparams);
    
            parameters = data.parameters;

            figure('Position', [100 100 800 500])
            plotFYmodel(fy_fit);
            F = gcf;
            save([savedir filesep subdir(m).name], 'fy_fit', 'parameters')
            saveas(F, [figsavedir filesep subdir(m).name(1:end-4) '.jpg'], 'jpeg')
            close
        end
    end
end
%%
options = struct('evalCode', false, 'outputDir', savedir);
publish('fy_cost.m', options)
publish('fitFYmodel.m', options)
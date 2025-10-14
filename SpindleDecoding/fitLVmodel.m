% fit models
clc; clear; close all


addpath(genpath('Functions'))

loc = '/Volumes/labs/ting/shared_ting/Jake/MultiAffs_mat/';
d = dir(loc);

savedir = ['/Users/jacobstephens/Documents/Data/decodingmodelfitting' filesep 'LV-' char(datetime('today'))];
figsavedir = ['/Users/jacobstephens/Documents/Data/decodingmodelfittingfigs' filesep 'LV-' char(datetime('today'))];
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

            % kl, kv, b
            low = [0 0 -150];
            up = [200 50 150];
            init = (up+low)/2;

            lvparams =  [init; low; up];
            lv_fit = getLVgains(data.procdata, lvparams);
    
            parameters = data.parameters;

            % subplot(211)
            % hold on
            % plot(lv_fit.time, lv_fit.L)
            % subplot(212)
            % hold on
            % plot(lv_fit.time, lv_fit.V)
            figure('Position', [100 100 800 500])
            plotLVmodel(lv_fit);
            F = gcf;
            save([savedir filesep subdir(m).name], 'lv_fit', 'parameters')
            saveas(F, [figsavedir filesep subdir(m).name(1:end-4) '.jpg'], 'jpeg')
            close
        end
    end
end
%%
options = struct('evalCode', false, 'outputDir', savedir);
publish('lv_cost.m', options)
publish('fitLVmodel.m', options)
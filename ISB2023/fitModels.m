% model fitting
 
clc
clear
close all
 
addpath(genpath('Functions'))
path =  '/Volumes/labs/ting/shared_ting/Jake/A100401/procdata';
savedir = [path(1:find(path == '/', 1, 'last')) 'model fits NY' char(datetime('today'))];

if ~isfolder(savedir)
    mkdir(savedir)
end
 
D = dir(path);
D = D(3:end);
%%
for ii = 1:numel(D)
    disp(ii)
    data = load([D(ii).folder filesep D(ii).name]);
    procdata = data.procdata;
    parameters = data.parameters;
    if strcmp(parameters.type, 'triangle')
        continue
    end
    
    switch parameters.aff
        case 'IA'
            % A, k_exp, L0, k_lin, kF, kY, bF, bY, lambda
            upper = [0.08 1.2  0.5 0.02 800 0.0   0  0  0];
            lower = [0.04 0.7 -0.5 0.02 0.0 0.000 -.2  0  0];
            init =  [0.06 0.9  0.0 0.02 400 0.000   0 -1  0];
        case 'II'
            % A, k_exp, L0, k_lin, kF, kY, bF, bY, lambda
            upper = [0.08 1.2  0.5 0.02 800 0.0   0  0  0];
            lower = [0.04 0.7 -0.5 0.02 0.0 0.000 -.2  0  0];
            init =  [0.06 0.9  0.0 0.02 400 0.000   0 -1  0];
    end
    fitparam = [init; lower; upper];
    fit = getFYgains(procdata, fitparam, 'Blum');
    
    if strcmp(parameters.aff, 'IA') && mod(ii, 4) == 0
        figure('Position', [100 400 600 600]);
        subplot(311)
        plot(procdata.time, fit.F, 'k', ...
            procdata.time, fit.Fnc, 'c', ...
            procdata.time, fit.Fc, 'r')
        legend({['A: ' num2str(fit.A)], ['k_{exp}: ' num2str(fit.k_exp)], ...
            ['L_0: ' num2str(fit.L0)]}, 'Location', 'eastoutside')
        subplot(312)
        plot(procdata.time, fit.Y, 'k', ...
            procdata.time, fit.Ync, 'c', ...
            procdata.time, fit.Yc, 'r')
        legend({['k_F: ' num2str(fit.kF)], ['k_Y: ' num2str(fit.kY)], ...
            ['VAF: ' num2str(fit.VAF)]}, 'Location', 'eastoutside')
        subplot(313)
        plot(procdata.time, fit.Fcomp, 'b', ...
            procdata.time, fit.Ycomp, 'b', ...
            procdata.time, fit.predictor, 'r')
        hold on
        plot(procdata.spiketimes, procdata.ifr, '.k')
        hold off
        sgtitle(D(ii).name)
    end
    save([savedir filesep D(ii).name], 'procdata', 'parameters', 'fit')
end

% model fitting
 
clc
clear
close all
addpath(genpath('Functions'))

path = uigetdir('/Volumes/labs/ting/shared_ting/Jake/SFN/');
D = dir(path);
D = D(3:end);
%%
savedir = ['/Volumes/labs/ting/shared_ting/Jake/SFN/Fits-100mN-alteredinterp-' char(datetime('today'))];
if ~exist(savedir, 'dir')
    mkdir(savedir);
end

%%
clc
close all

% figure('Position', [0 0 1920 1080]);

for ii = 1:numel(D) %numel(D)
    
    data = load([path filesep D(ii).name]);
    
    parameters = data.parameters;
    procdata = data.procdata;
    NC = data.NC;
    
    %        kF,   kY,   bF, bY, lambda
    init =  [200,  300,   1, -1];
    upper = [500,  300,   1,  0];
    lower = [0,      0, -.3, -5];
    param = [init; lower; upper];
    
    fit = getFYgains(procdata, NC, param);
    
    if mod(ii, 5) == 0
        plotModel(fit)
    end
    
    % subplot(1, 4, [floor(ii/60) + 1])
    % hold on
    % plot(fit.time + fit.lambda, fit.predictor + 20*ii, 'r')
    % plot(fit.spiketimes, fit.ifr + 10*ii, '.k')
    % xlim([0 2])
    % hold off
    save([savedir filesep D(ii).name], 'fit')
end
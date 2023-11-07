% model fitting
 
clc
clear
close all
addpath(genpath('Functions'))

path = uigetdir();
D = dir(path);
D = D(3:end);

savedir = '\\cosmic.bme.emory.edu\labs\ting\shared_ting\Jake\SFN\11-6-Fits-100mN';
if ~exist(savedir, 'dir')
    mkdir(savedir);
end

%%
clc
close all

figure('Position', [0 0 1920 1080]);

for ii = 1:numel(D)
    
    data = load([path filesep D(ii).name]);
    
    parameters = data.parameters;
    procdata = data.procdata;
    NC = data.NC;
    
    %        kF,   kY,   bF, bY, lambda
    init =  [200,  10,  -.1, 0,   0];
    upper = [1000, 100,   0, 0,  .1];
    lower = [0,    0,   -.1, 0, -.1];
    param = [init; lower; upper];
    
    fit = getFYgains(procdata, NC, param);
    
%     plotModel(fit)
    subplot(1, 4, [floor(ii/60) + 1])
    hold on
    plot(fit.time + fit.lambda, fit.predictor + 20*ii, 'r')
    plot(fit.spiketimes, fit.ifr + 10*ii, '.k')
    xlim([0 2])
    hold off
    save([savedir filesep D(ii).name], 'fit')
end
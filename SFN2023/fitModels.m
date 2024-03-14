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
    
    procdata = data.procdata;
    NC = data.NC;
    
    %        kF,   kY,   bF, bY, lambda
    init =  [200,  300,   0, -1];
    upper = [800,  300,   0,  0];
    lower = [0,      0, -.3, -3];
    param = [init; lower; upper];
    
    fit = getFYgains(procdata, NC, param);
    
    % if mod(ii, 5) == 0
    %     plotModel(fit)
    % end
    parameters = data.parameters;
    save([savedir filesep D(ii).name], 'fit', 'parameters')
end

% run("writeSumTable.m")
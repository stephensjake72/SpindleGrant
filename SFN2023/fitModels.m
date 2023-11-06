% model fitting
 
clc
clear
close all
addpath(genpath('Functions'))

path = uigetdir();
D = dir(path);
D = D(3:end);

savedir = '\\cosmic.bme.emory.edu\labs\ting\shared_ting\Jake\SFN\10-30Fits';
if ~exist(savedir, 'dir')
    mkdir(savedir);
end

%%
close all
for ii = 1%:50%numel(D)
    
    data = load([path filesep D(ii).name]);
    
    parameters = data.parameters;
    procdata = data.procdata;
    NC = data.NC;
    
    %         A,  kexp,    L0, klin, kF,   kY, bF, bY, lambda
    init =  [NC.A, NC.kexp, NC.L0,  0.05, 500,  10,  -.1, 0,   0];
    upper = [0.5, NC.k_exp, 4,  0.1,  1000, 100, -.1, 0,  .1];
    lower = [0.0, NC.k_exp, 0,  0.0,  0,    0,     0, 0, -.1];
%     
%     fit = getFYgains(procdata, [init; lower; upper], 'Blum');
%     
%     plotModel(fit)
end
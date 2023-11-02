% model fitting
 
clc
clear
close all
addpath(genpath('Functions'))

path = '\\cosmic.bme.emory.edu\labs\ting\shared_ting\Jake\SFN\procdataNC';
D = dir(path);
D = D(3:end);

savedir = '\\cosmic.bme.emory.edu\labs\ting\shared_ting\Jake\SFN\10-30Fits';
if ~exist(savedir, 'dir')
    mkdir(savedir);
end

%%

for ii = 1:100%numel(D)
    
    data = load([path filesep D(ii).name]);
    
    parameters = data.parameters;
    procdata = data.procdata;
    NCmod = data.NCmod;
    
    %         A,        kexp,       L0,  klin, kF, kY, bF, bY, lambda
    init =  [NCmod.A, NCmod.kexp, NCmod.L0, 0, 100,  10,  0, 0,   0];
    upper = [NCmod.A, NCmod.kexp, NCmod.L0, 0, 1000, 100, 0, 0,  .1];
    lower = [NCmod.A, NCmod.kexp, NCmod.L0, 0, 0,    0,   0, 0, -.1];
    
    fit = getFYgains(procdata, [init; lower; upper], 'Blum');
    
    plotModel(fit)
end
clc
clear
close all
addpath(genpath('Functions'))

d = dir('C:\\Users\Jake\Documents\Data\HorslenData');

file = load([d(5).folder filesep d(5).name]);
data = file.procdata;

% fyupper = [0.07 37.6 .6 0.1 0 50 .5 0 0]; % A, k_exp, L0, k_lin, kF, kY, bF, lambda
% fylower = [0.07 37.6 .6 0.0 0 0 -.5 0 -.01];
fyupper = [0.0011 2.0 .10 0.1 1000 50 1 0 0];
fylower = [0.0011 2.0 .09 0.0 10 10 -1 0 -.01];
fyinit = fylower;
fyparameters = [fyinit; fylower; fyupper];
FYfit = getFYgains(data, fyparameters, 'Blum');
% plotFY(data, FYfit, -30)
% print(['C:\\Users\Jake\Documents\Data\HorslenData\fig1FYsway.eps'], '-depsc','-painters')
% plotFY(data, FYfit, -1)
% print(['C:\\Users\Jake\Documents\Data\HorslenData\fig1FYramp.eps'], '-depsc','-painters')
FYfit

lvaupper = [1000 500 100 5 10 100 0];
lvalower = [1 1 1 -1 -1 -10 -.02];
lvainit = lvalower;
lvaparameters = [lvainit; lvalower; lvaupper];
LVAMfit = getLVAgains(data, lvaparameters, 'MTU');
% plotLVA(data, LVAMfit, -30)
% print(['C:\\Users\Jake\Documents\Data\HorslenData\fig1LVAMsway.eps'], '-depsc','-painters')
% plotLVA(data, LVAMfit, -1)
% print(['C:\\Users\Jake\Documents\Data\HorslenData\fig1LVAMramp.eps'], '-depsc','-painters')
LVAMfit

LVAFfit = getLVAgains(data, lvaparameters, 'Fas');
% plotLVA(data, LVAFfit, -30)
% print(['C:\\Users\Jake\Documents\Data\HorslenData\fig1LVAFsway.eps'], '-depsc','-painters')
% plotLVA(data, LVAFfit, -1)
% print(['C:\\Users\Jake\Documents\Data\HorslenData\fig1LVAFramp.eps'], '-depsc','-painters')
LVAFfit
%%
for ii = 3:5 % numel(d)
    clear fit
    file = load([d(ii).folder filesep d(ii).name]);
    data = file.procdata;
    
    swayLmt = data.Lmt(data.time < 0);
    swayAmp = mean(sqrt(swayLmt.^2));
    
    fyupper = [FYfit.A FYfit.k_exp FYfit.L0 FYfit.k_lin FYfit.kF FYfit.kY FYfit.bF FYfit.bY FYfit.lambda]; % A, k_exp, L0, k_lin, kF, kY, bF, lambda
    fylower = [FYfit.A FYfit.k_exp FYfit.L0 FYfit.k_lin FYfit.kF FYfit.kY FYfit.bF FYfit.bY FYfit.lambda];
    fyinit = fylower;
    fyparameters = [fyinit; fylower; fyupper];
    modfyfit = getFYgains(data, fyparameters, 'Blum');
    plotFY(data, modfyfit, -30)
    sgtitle(['RMS sway amp.: ' num2str(swayAmp)])
    print(['C:\\Users\Jake\Documents\Data\HorslenData\FY', d(ii).name, 'sway.eps'], '-depsc','-painters')
    plotFY(data, modfyfit, -1)
    sgtitle(['RMS sway amp.: ' num2str(swayAmp)])
    print(['C:\\Users\Jake\Documents\Data\HorslenData\FY', d(ii).name, 'ramp.eps'], '-depsc','-painters')
%     
    lvamupper = [LVAMfit.kL LVAMfit.kV LVAMfit.kA LVAMfit.bL LVAMfit.bV LVAMfit.bA LVAMfit.lambda];
    lvamlower = [LVAMfit.kL LVAMfit.kV LVAMfit.kA LVAMfit.bL LVAMfit.bV LVAMfit.bA LVAMfit.lambda];
    lvaminit = lvamlower;
    lvamparameters = [lvaminit; lvamlower; lvamupper];
    modlvamfit = getLVAgains(data, lvamparameters, 'MTU');
    plotLVA(data, modlvamfit, -30)
    print(['C:\\Users\Jake\Documents\Data\HorslenData\LVAM', d(ii).name, 'sway.eps'], '-depsc','-painters')
    plotLVA(data, modlvamfit, -1)
    print(['C:\\Users\Jake\Documents\Data\HorslenData\LVAM', d(ii).name, 'ramp.eps'], '-depsc','-painters')
    
    lvafupper = [LVAFfit.kL LVAFfit.kV LVAFfit.kA LVAFfit.bL LVAFfit.bV LVAFfit.bA LVAFfit.lambda];
    lvaflower = [LVAFfit.kL LVAFfit.kV LVAFfit.kA LVAFfit.bL LVAFfit.bV LVAFfit.bA LVAFfit.lambda];
    lvafinit = lvaflower;
    lvafparameters = [lvafinit; lvaflower; lvafupper];
    modlvaffit = getLVAgains(data, lvafparameters, 'Fas');
    plotLVA(data, modlvaffit, -30)
    print(['C:\\Users\Jake\Documents\Data\HorslenData\LVAF', d(ii).name, 'sway.eps'], '-depsc','-painters')
    plotLVA(data, modlvaffit, -1)
    print(['C:\\Users\Jake\Documents\Data\HorslenData\LVAF', d(ii).name, 'ramp.eps'], '-depsc','-painters')
    save([d(ii).folder filesep d(ii).name], 'modfyfit', 'modlvamfit', 'modlvaffit', '-append')
end
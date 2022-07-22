clc
clear
close all

D = dir('C:\\Users\Jake\Documents\Data\HorslenCondAmp');
%%
for ii = 14 % 3:numel(D)
    clear fit
    file = load([D(ii).folder filesep D(ii).name]);
    data = file.procdata;
    
    fyupper = [0.011 1.25 0.1 0 1500 30 .5 0 0]; % A, k_exp, L0, k_lin, kF, kY, bF, bY, lambda
    fylower = [0 1.25 0.0 0 400 5 -.5 0 0];
    fyinit = fylower;
    fyparameters = [fyinit; fylower; fyupper];
    FYfit = getFYgains(data, fyparameters, 'Blum');
    plotFY(data, FYfit)
    sgtitle(num2str(ii))
    FYfit
    
    save([D(ii).folder filesep D(ii).name], 'FYfit', '-append')
end
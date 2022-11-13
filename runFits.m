
clc
clear
close all
addpath(genpath('Functions'))
load('summaryTable.mat')

animals = unique(summaryTable.animal);
count = 0;
for ii = 1:height(summaryTable)
    check1 = strcmp(summaryTable.type{ii}, 'triangle'); % check if is ramp
    check2 = summaryTable.passive{ii} == 1; % if is passive
    check3 = summaryTable.badtrial{ii} == 0; % if it's a good trial
    check4 = strcmp(summaryTable.KT{ii}, 'T');
    check5 = strcmp(summaryTable.animal{ii}, animals{10});
    if check1 && check2 && check3 && check4 && check5
        data = load(summaryTable.address{ii});
        
        A = 0*[0.03; .01; .1]; % init, lower, upper
        k_exp = [2; 2; 3];
        L0 = [.1; -.1; .15];
        k_lin = 0*[0.3; 0.3; 0.3];
        kF = [1000; 100; 1000];
        kY = 0*[40; 20; 100];
        bF = [0; -.1; 0]; 
        bY = [0; 0; 0];
        lambda = [0; 0; 0];
        
        parameters = [A k_exp L0 k_lin kF kY bF bY lambda];
        fit = getFYgains(data.procdata, parameters, 'Fas')
        
        figure('Position', [800 200 1100 700])
        % variables
        subplot(621)
        plot(fit.time, fit.F)
        yyaxis right
        plot(fit.time, fit.Y)
        title('Force/yank')
        % NC model
        subplot(623)
        plot(fit.time, fit.F, fit.time, fit.Fc, fit.time, fit.Fnc)
        legend('MTU', 'C', 'NC')
        title('force')
        subplot(624)
        plot(fit.L, fit.F, fit.L, fit.Fc, fit.L, fit.Fnc)
        legend({'Fmt', 'Fc', 'Fnc'}, 'Location', 'eastoutside')
        title(['A=' num2str(fit.A) ' k_{exp}=' num2str(fit.k_exp) ' k_{lin}=' num2str(fit.k_lin) ' L_0=' num2str(fit.L0)])
        subplot(625)
        plot(fit.time, fit.Y, fit.time, fit.Yc, fit.time, fit.Ync)
        legend('MTU', 'C', 'NC')
        title('yank')
        % occlusion
        subplot(627)
        plot(fit.time, fit.occBag, fit.time, fit.occChain)
        ylim([0 1])
        legend('bag occ', 'chain occ')
        % components
        subplot(629)
        plot(fit.time, fit.chainComp, fit.time, fit.bagComp)
        title(['k_F=' num2str(fit.kF) ' k_Y=' num2str(fit.kY) ' b_F=' num2str(fit.bF)])
        legend('chain component', 'bag component')
        % fit
        subplot(6,2, 11)
        plot(fit.time + fit.lambda, fit.predictor, 'r')
        hold on
        plot(fit.spiketimes, fit.ifr, '.k')
        hold off
        count = count + 1;
    end
end
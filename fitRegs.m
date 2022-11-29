% fit lm's
clc
clear
close all
load('summaryTable.mat')
addpath(genpath('Functions'))

plotcount = 1;
for ii = 1:height(summaryTable)
    check1 = summaryTable.badtrial{ii} == 0;
    check2 = summaryTable.passive{ii} == 1 || summaryTable.trimdatacheck{ii} == 1;
    check3 = strcmp(summaryTable.aff{ii}, 'IA');
    check4 = strcmp(summaryTable.type{ii}, 'sine') || strcmp(summaryTable.type{ii}, 'ramp') || strcmp(summaryTable.type{ii}, 'triangle');
    if check1 && check2 && check3 && check4
        data = load(summaryTable.address{ii});
        if summaryTable.trimdatacheck{ii} == 1
            expdata = data.trimdata;
        else
            expdata = data.procdata;
        end
        models = fitmodels(expdata);
        save(summaryTable.address{ii}, 'models', '-append')
        
        if plotcount <= 100
            Lmtst = interp1(expdata.time, expdata.Lmt, expdata.spiketimes);
            Lfst = interp1(expdata.time, expdata.Lf, expdata.spiketimes);
            vfst = interp1(expdata.time, expdata.vf, expdata.spiketimes);
            Fmtst = interp1(expdata.time, expdata.Fmt, expdata.spiketimes);
            ifr = expdata.ifr;
            
            figure
            subplot(421)
            plot(expdata.time, models.mLmt*expdata.Lmt)
            hold on
            plot(expdata.spiketimes, expdata.ifr, '.k')
            
            subplot(422)
            plot(Lmtst, models.mLmt*Lmtst, 'r')
            hold on
            plot(Lmtst, ifr, '.k')
            plotcount = plotcount + 1;
            
            subplot(423)
            plot(expdata.time, models.mLf*expdata.Lf)
            hold on
            plot(expdata.spiketimes, expdata.ifr, '.k')
            
            subplot(424)
            plot(Lfst, models.mLf*Lfst, 'r')
            hold on
            plot(Lfst, ifr, '.k')
            plotcount = plotcount + 1;
            
            subplot(425)
            plot(expdata.time, models.mvf*expdata.vf)
            hold on
            plot(expdata.spiketimes, expdata.ifr, '.k')
            
            subplot(426)
            plot(vfst, models.mvf*vfst, 'r')
            hold on
            plot(vfst, ifr, '.k')
            
            subplot(428)
            plot(Fmtst, models.mFmt*Fmtst, 'r')
            hold on
            plot(Fmtst, ifr, '.k')
            title(num2str(models.rFmt))
            plotcount = plotcount + 1;
        end
%         clear models
    end
end
%%
% vars = {'mLf', 'rLf', 'mvf', 'rvf', 'mLmt', 'rLmt', 'mvmt', 'rvmt', 'mFmt', 'rFmt'};
vars = {'mFmt', 'rFmt'};
summaryTable = tableAppend(summaryTable, vars);
save('summaryTable.mat', 'summaryTable')
%%
writetable(summaryTable, 'C:\\Users\Jake\Documents\Data\SpindleSpringSummary.csv')
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
        type = summaryTable.type{ii};
        models = fitmodels(expdata, type);
        save(summaryTable.address{ii}, 'models', '-append')
        
        if plotcount <= 50
            Lmtst = interp1(expdata.time, expdata.Lmt, expdata.spiketimes);
            Lfst = interp1(expdata.time, expdata.Lf, expdata.spiketimes);
            vfst = interp1(expdata.time, expdata.vf, expdata.spiketimes);
            Fmtst = interp1(expdata.time, expdata.Fmt, expdata.spiketimes);
            ifr = expdata.ifr;
            
            figure
            subplot(421)
            plot(expdata.time, models.mLmt*expdata.Lmt + models.bLmt)
            hold on
            plot(expdata.spiketimes, expdata.ifr, '.k')
            title('Lmt')
            
            subplot(422)
            plot(Lmtst, models.mLmt*Lmtst + models.bLf, 'r')
            hold on
            plot(Lmtst, ifr, '.k')
            
            subplot(423)
            plot(expdata.time, models.mLf*expdata.Lf + models.bLf)
            hold on
            plot(expdata.spiketimes, expdata.ifr, '.k')
            title('Lf')
            
            subplot(424)
            plot(Lfst, models.mLf*Lfst + models.bLf, 'r')
            hold on
            plot(Lfst, ifr, '.k')
            
            subplot(425)
            plot(expdata.time, models.mvf*expdata.vf + models.bvf)
            hold on
            plot(expdata.spiketimes, expdata.ifr, '.k')
            title('Vf')
            
            subplot(426)
            plot(vfst, models.mvf*vfst + models.bvf, 'r')
            hold on
            plot(vfst, ifr, '.k')
            
            subplot(427)
            plot(expdata.time, models.mFmt*expdata.Fmt + models.bFmt)
            hold on
            plot(expdata.spiketimes, expdata.ifr, '.k')
            title('Force')
            
            subplot(428)
            plot(Fmtst, models.mFmt*Fmtst + models.bFmt, 'r')
            hold on
            plot(Fmtst, ifr, '.k')
            title(num2str(models.rFmt))
            
            plotcount = plotcount + 1;
        end
        clear models
    end
end
%%
vars = {'mLf', 'bLf', 'rLf', ...
    'mvf', 'bvf', 'rvf', ...
    'mLmt', 'bLmt', 'rLmt', ...
    'mvmt', 'bvmt', 'rvmt', ...
    'mFmt', 'bFmt', 'rFmt'};
summaryTable = tableAppend(summaryTable, vars);
save('summaryTable.mat', 'summaryTable')
%%
writetable(summaryTable, 'C:\\Users\Jake\Documents\Data\SpindleSpringSummary.csv')
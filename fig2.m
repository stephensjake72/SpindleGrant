% fig 2
clc
clear
close all
load('summaryTable.mat')
addpath(genpath('Functions'))

%% find ctrl data
animals = unique(summaryTable.animal);

Tcount = 0;
for ii = 1:height(summaryTable)
    check1 = summaryTable.badtrial{ii} == 0;
    check2 = strcmp(summaryTable.type{ii}, 'triangle');
    check3 = strcmp(summaryTable.aff{ii}, 'IA');
    check4 = summaryTable.passive{ii} == 1;
    check5 = strcmp(summaryTable.KT{ii}, 'T');
    check6 = strcmp(summaryTable.animal{ii}, animals{13});
    
    if check1 && check2 && check3 && check4 && check5 && check6
        Tcount = Tcount + 1;
    end
    
    if check1 && check2 && check3 && check4 && check5 && check6 && Tcount == 1
        data = load(summaryTable.address{ii});
        
        subplot(421)
        hold on
        plot(data.procdata.time, data.procdata.Lmt, 'k')
        subplot(423)
        hold on
        plot(data.procdata.time, data.procdata.Lf, 'k')
        subplot(425)
        hold on
        plot(data.procdata.time, data.procdata.Fmt, 'k')
        subplot(427)
        hold on
        plot(data.procdata.spiketimes, data.procdata.ifr, '.k')
        
        subplot(422)
        plot(data.procdata.Lmt, data.procdata.Lf, 'k')
        subplot(424)
        plot(data.procdata.Lmt, data.procdata.Fmt, 'k')
        subplot(426)
        plot(data.procdata.Lf, data.procdata.Fmt, 'k')
    end
end
%%
Ccount = 0;
for jj = 1:height(summaryTable)
    check1 = summaryTable.badtrial{jj} == 0;
    check2 = strcmp(summaryTable.type{jj}, 'triangle');
    check3 = strcmp(summaryTable.aff{jj}, 'IA');
    check4 = summaryTable.passive{jj} == 1;
    check5 = strcmp(summaryTable.KT{jj}, 'C');
    check6 = strcmp(summaryTable.animal{jj}, animals{13});
    if check1 && check2 && check3 && check4 && check5 && check6
        Ccount = Ccount + 1;
        Ccount
    end
    
    if check1 && check2 && check3 && check4 && check5 && check6 && Ccount == 3
        data = load(summaryTable.address{jj});
        
        subplot(421)
        hold on
        plot(data.procdata.time, data.procdata.Lmt, 'c')
        subplot(423)
        hold on
        plot(data.procdata.time, data.procdata.Lf, 'c')
        subplot(425)
        hold on
        plot(data.procdata.time, data.procdata.Fmt, 'c')
        subplot(427)
        hold on
        plot(data.procdata.spiketimes, data.procdata.ifr, '.c')
        
        subplot(422)
        hold on
        plot(data.procdata.Lmt, data.procdata.Lf, 'c')
        xlabel('Lmt')
        ylabel('Lf')
        subplot(424)
        hold on
        plot(data.procdata.Lmt, data.procdata.Fmt, 'c')
        xlabel('Lmt')
        ylabel('Fmt')
        subplot(426)
        hold on
        plot(data.procdata.Lf, data.procdata.Fmt, 'c')
        xlabel('Lf')
        ylabel('Fmt')
    end
end
% print(['C:\\Users\Jake\Documents\Data\Spindle_spring_figures\fig2a.eps'], '-depsc','-painters')

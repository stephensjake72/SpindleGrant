% fig 2
clc
clear
close all
load('summaryTable.mat')
addpath(genpath('Functions'))

%% find ctrl data
animals = unique(summaryTable.animal);
F = figure();
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
        time = data.procdata.time;
        st = data.procdata.spiketimes;
        ifr = data.procdata.ifr;
        Lmt = data.procdata.Lmt;
        Lf = data.procdata.Lf;
        Fmt = data.procdata.Fmt;
        
        % create color maps
        cStart = [0 0 0];
        cStop = [.7 .7 .7];
        [map1, map2] = timeColorMap(time, st, cStart, cStop);
        sz1 = ones(1, numel(time));
        sz2 = 6*ones(1, numel(st));
        
        % time series
        subplot(421)
        hold on
        plot(time, Lmt, 'k')
        subplot(423)
        hold on
        plot(time, Lf, 'k')
        subplot(425)
        hold on
        plot(time, Fmt, 'k')
        subplot(427)
        hold on
        scatter(st, ifr, sz2, map2, 'filled')
        
        % ifr vs L, V, F
        Lmt_st = interp1(time, Lmt, st);
        Lf_st = interp1(time, Lf, st);
        Fmt_st = interp1(time, Fmt, st);
        
        subplot(422)
        hold on
        scatter(Lmt_st, ifr, sz2, map2, 'filled')
        plot(Lmt_st, data.models.mLmt*Lmt_st, 'k')
        xlabel('Lmt')
        subplot(424)
        hold on
        scatter(Lf_st, ifr, sz2, map2, 'filled')
        plot(Lf_st, data.models.mLf*Lf_st, 'k')
        xlabel('Lf')
        subplot(426)
        hold on
        scatter(Fmt_st, ifr, sz2, map2, 'filled')
        plot(Fmt_st, data.models.mFmt*Fmt_st, 'k')
        xlabel('Fmt')
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
        time = data.procdata.time;
        st = data.procdata.spiketimes;
        ifr = data.procdata.ifr;
        Lmt = data.procdata.Lmt;
        Lf = data.procdata.Lf;
        Fmt = data.procdata.Fmt;
        
        % create color maps
        cStart = [230,85,13]/255;
        cStop = [253,190,133]/255;
        [map1, map2] = timeColorMap(time, st, cStart, cStop);
        sz1 = ones(1, numel(time));
        sz2 = 6*ones(1, numel(st));
        
        % time series
        subplot(421)
        hold on
        plot(time, Lmt, 'Color', cStart)
        ax = gca;
        subplot(423)
        hold on
        plot(time, Lf, 'Color', cStart)
        subplot(425)
        hold on
        plot(time, Fmt, 'Color', cStart)
        subplot(427)
        hold on
        scatter(st, ifr, sz2, map2, 'filled')
        xlim(ax.XAxis.Limits)
        
        % ifr vs L, V, F
        Lmt_st = interp1(time, Lmt, st);
        Lf_st = interp1(time, Lf, st);
        Fmt_st = interp1(time, Fmt, st);
        
        subplot(422)
        hold on
        scatter(Lmt_st, ifr, sz2, map2, 'filled')
        plot(Lmt_st, data.models.mLmt*Lmt_st, 'k')
        xlabel('Lmt')
        xlim([-.5 3.5])
        subplot(424)
        hold on
        scatter(Lf_st, ifr, sz2, map2, 'filled')
        plot(Lf_st, data.models.mLf*Lf_st, 'k')
        xlabel('Lf')
        xlim([-.25 1.75])
        subplot(426)
        hold on
        scatter(Fmt_st, ifr, sz2, map2, 'filled')
        plot(Fmt_st, data.models.mFmt*Fmt_st, 'k')
        xlabel('Fmt')
        xlim([0 1.25])
    end
end
%%
saveas(F, 'C:\\Users\Jake\Documents\Lab\JEPfig2.jpg')
print(['C:\\Users\Jake\Documents\Lab\fig4data.eps'], '-depsc','-painters')

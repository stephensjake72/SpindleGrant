%  fig 4
clc
clear
close all
addpath(genpath('Functions'))
load('summaryTable.mat')

%% find ctrl data
animals = unique(summaryTable.animal);
an = animals{13};
F = figure();
Tcount = 0;
for ii = 1:height(summaryTable)
    check1 = summaryTable.badtrial{ii} == 0;
    check2 = summaryTable.trimdatacheck{ii} == 1;
    check3 = strcmp(summaryTable.aff{ii}, 'IA');
    check4 = strcmp(summaryTable.KT{ii}, 'T');
    check5 = strcmp(summaryTable.animal{ii}, an);
    
    if check1 && check2 && check3 && check4 && check5
        Tcount = Tcount + 1;
    end
    
    if check1 && check2 && check3 && check4 && check5 && Tcount == 3
        data = load(summaryTable.address{ii});
        time = data.trimdata.time;
        st = data.trimdata.spiketimes;
        ifr = data.trimdata.ifr;
        Lmt = data.trimdata.Lmt;
        Lf = data.trimdata.Lf;
        vf = data.trimdata.vf;
        Fmt = data.trimdata.Fmt;
        
        % create color maps
        cStart = [0 0 0];
        cStop = [.7 .7 .7];
        [map1, map2] = timeColorMap(time, st, cStart, cStop);
        sz1 = ones(1, numel(time));
        sz2 = ones(1, numel(st));
        
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
        scatter(st, ifr, 6*sz2, map2, 'filled')
        xlim(ax.XAxis.Limits)
         
        % ifr vs L, V, F
        Lmt_st = interp1(time, Lmt, st);
        Lf_st = interp1(time, Lf, st);
        Fmt_st = interp1(time, Fmt, st);
        vf_st = interp1(time, vf, st);
        
        subplot(422)
        hold on
        scatter(Lmt_st, ifr, 8*sz2, map2, 'filled')
        plot(Lmt_st, Lmt_st*data.models.mLmt, '--k')
        xlabel('Lmt')
        subplot(424)
        hold on
        scatter(Lf_st, ifr, 8*sz2, map2, 'filled')
        plot(Lf_st, Lf_st*data.models.mLf, '--k')
        xlabel('Lf')
        subplot(426)
        hold on
        scatter(vf_st, ifr, 8*sz2, map2, 'filled')
        plot(vf_st, vf_st*data.models.mvf, '--k')
        xlabel('vf')
        subplot(428)
        hold on
        scatter(Fmt_st, ifr, 8*sz2, map2, 'filled')
        plot(Fmt_st, Fmt_st*data.models.mFmt, '--k')
        xlabel('Fmt')
    end
end
%%
Ccount = 0;
for jj = 1:height(summaryTable)
    check1 = summaryTable.badtrial{jj} == 0;
    check2 = summaryTable.trimdatacheck{jj} == 1;
    check3 = strcmp(summaryTable.aff{jj}, 'IA');
    check4 = strcmp(summaryTable.KT{jj}, 'C');
    check5 = strcmp(summaryTable.animal{jj}, an);
    
    if check1 && check2 && check3 && check4 && check5
        Ccount = Ccount + 1;
%         Ccount
    end
    
    if check1 && check2 && check3 && check4 && check5 && Ccount == 2
        data = load(summaryTable.address{jj});
        time = data.trimdata.time;
        st = data.trimdata.spiketimes;
        ifr = data.trimdata.ifr;
        Lmt = data.trimdata.Lmt;
        vmt = data.trimdata.vmt;
        Lf = data.trimdata.Lf;
        vf = data.trimdata.vf;
        Fmt = data.trimdata.Fmt;
        
        % create color maps
        cStart = [0 109 44]/255;
        cStop = [178,226,226]/255;
        [map1, map2] = timeColorMap(time, st, cStart, cStop);
        sz1 = ones(1, numel(time));
        sz2 = ones(1, numel(st));
        
        % time series
        subplot(421)
        hold on
        plot(time, Lmt, 'Color', cStart)
        xlim([0.5 2.5])
        ax = gca;
        subplot(423)
        hold on
        plot(time, Lf, 'Color', cStart)
        xlim(ax.XAxis.Limits)
        subplot(425)
        hold on
        plot(time, Fmt, 'Color', cStart)
        xlim(ax.XAxis.Limits)
        subplot(427)
        hold on
        scatter(st, ifr, 8*sz2, map2, 'filled')
        xlim(ax.XAxis.Limits)
        
        % ifr vs L, V, F
        Lmt_st = interp1(time, Lmt, st);
        vmt_st = interp1(time, vmt, st);
        Lf_st = interp1(time, Lf, st);
        Fmt_st = interp1(time, Fmt, st);
        vf_st = interp1(time, vf, st);
        
        subplot(422)
        hold on
        scatter(Lmt_st, ifr, 8*sz2, map2, 'filled')
        plot(Lmt_st, Lmt_st*data.models.mLmt, 'Color', cStart)
        xlim([-1 2.5])
        subplot(424)
        hold on
        scatter(Lf_st, ifr, 8*sz2, map2, 'filled')
        plot(Lf_st, Lf_st*data.models.mLf, 'Color', cStart)
        xlim([-.5 1.5])
        subplot(426)
        hold on
        scatter(vf_st, ifr, 8*sz2, map2, 'filled')
        plot(vf_st, vf_st*data.models.mvf, 'Color', cStart)
        xlabel('vf')
        xlim([-7.5 15])
        subplot(428)
        hold on
        scatter(Fmt_st, ifr, 8*sz2, map2, 'filled')
        plot(Fmt_st, Fmt_st*data.models.mFmt(1), 'Color', cStart)
        xlabel('Fmt')
        xlim([.15 .75])
        
    end
end
%%
saveas(F, 'C:\\Users\Jake\Documents\Lab\JEPfig2.jpg')
print(['C:\\Users\Jake\Documents\Lab\JEPfig2data.eps'], '-depsc','-painters')
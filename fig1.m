% figure 1
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
    check2 = strcmp(summaryTable.type{ii}, 'ramp');
    check3 = strcmp(summaryTable.aff{ii}, 'IA');
    check4 = summaryTable.passive{ii} == 1;
    check5 = strcmp(summaryTable.KT{ii}, 'T');
    check6 = strcmp(summaryTable.animal{ii}, animals{13});
    
    if check1 && check2 && check3 && check4 && check5 && check6
        Tcount = Tcount + 1;
    end
    
    if check1 && check2 && check3 && check4 && check5 && check6 && Tcount == 5
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
        scatter(time, Lmt, sz1, map1)
        xlim([.5 2.5])
        ylim([0 3])
        ax = gca;
        subplot(423)
        hold on
        scatter(time, Lf, sz1, map1)
        xlim(ax.XAxis.Limits)
        subplot(425)
        hold on
        scatter(time, Fmt, sz1, map1)
        xlim(ax.XAxis.Limits)
        subplot(427)
        hold on
        scatter(st, ifr, sz2, map2, 'filled')
        xlim(ax.XAxis.Limits)
        
        subplot(422)
        scatter(data.procdata.Lmt, data.procdata.Lf, sz1, map1)
        set(gca, 'Box', 'off')
        xlim([-.5 3.5])
        subplot(424)
        scatter(data.procdata.Lmt, data.procdata.Fmt, sz1, map1)
        set(gca, 'Box', 'off')
        xlim([-.5 3.5])
        subplot(426)
        scatter(data.procdata.Lf, data.procdata.Fmt, sz1, map1)
        set(gca, 'Box', 'off')
        xlim([-.25 1.5])
    end
end
%%
Ccount = 0;
for jj = 1:height(summaryTable)
    check1 = summaryTable.badtrial{jj} == 0;
    check2 = strcmp(summaryTable.type{jj}, 'ramp');
    check3 = strcmp(summaryTable.aff{jj}, 'IA');
    check4 = summaryTable.passive{jj} == 1;
    check5 = strcmp(summaryTable.KT{jj}, 'C');
    check6 = strcmp(summaryTable.animal{jj}, animals{13});
    if check1 && check2 && check3 && check4 && check5 && check6
        Ccount = Ccount + 1;
%         Ccount
    end
    
    if check1 && check2 && check3 && check4 && check5 && check6 && Ccount == 2
        data = load(summaryTable.address{jj});
        time = data.procdata.time;
        st = data.procdata.spiketimes;
        ifr = data.procdata.ifr;
        Lmt = data.procdata.Lmt;
        Lf = data.procdata.Lf;
        Fmt = data.procdata.Fmt;
        
        % create color maps
        cStart = [8,81,156]/255;
        cStop = [189,215,231]/255;
        [map1, map2] = timeColorMap(time, st, cStart, cStop);
        sz1 = ones(1, numel(time));
        sz2 = 6*ones(1, numel(st));
        
        subplot(422)
        hold on
        scatter(data.procdata.Lmt, data.procdata.Lf, sz1, map1)
        set(gca, 'Box', 'off')
        xlabel('Lmt')
        ylabel('Lf')
        xlim([-.5 3.5])
        subplot(424)
        hold on
        scatter(data.procdata.Lmt, data.procdata.Fmt, sz1, map1)
        set(gca, 'Box', 'off')
        xlabel('Lmt')
        ylabel('Fmt')
        xlim([-.5 3.5])
        subplot(426)
        hold on
        scatter(data.procdata.Lf, data.procdata.Fmt, sz1, map1)
        set(gca, 'Box', 'off')
        xlabel('Lf')
        ylabel('Fmt')
        xlim([-.25 1.5])
        
    end
end
%%
saveas(F, 'C:\\Users\Jake\Documents\Lab\JEPfig1.jpg')
print(['C:\\Users\Jake\Documents\Lab\fig1timeseries.eps'], '-depsc','-painters')

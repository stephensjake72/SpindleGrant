%  fig 4
clc
clear
close all
addpath(genpath('Functions'))
load('summaryTable.mat')

%% find ctrl data
animals = unique(summaryTable.animal);
an = animals{11};
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
    
    if check1 && check2 && check3 && check4 && check5 && Tcount == 2
        data = load(summaryTable.address{ii});
        time = data.trimdata.time;
        st = data.trimdata.spiketimes;
        ifr = data.trimdata.ifr;
        Lmt = data.trimdata.Lmt;
        Lf = data.trimdata.Lf;
        Fmt = data.trimdata.Fmt;
        
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
        plot(st, ifr, '.k')
         
        % ifr vs L, V, F
        Lmt_st = interp1(time, Lmt, st);
        Lf_st = interp1(time, Lf, st);
        Fmt_st = interp1(time, Fmt, st);
        
        subplot(422)
        plot(Lmt_st, ifr, '.k')
        hold on
        xlabel('Lmt')
        subplot(424)
        hold on
        plot(Lf_st, ifr, '.k')
        xlabel('Lf')
        subplot(426)
        hold on
        plot(Fmt_st, ifr, '.k')
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
        Lf = data.trimdata.Lf;
        Fmt = data.trimdata.Fmt;
        
        % time series
        subplot(421)
        hold on
        plot(time, Lmt, 'Color', [0 .447 .741])
        xlim([0.5 2.5])
        ax = gca;
        subplot(423)
        hold on
        plot(time, Lf, 'Color', [0 .447 .741])
        xlim(ax.XAxis.Limits)
        subplot(425)
        hold on
        plot(time, Fmt, 'Color', [0 .447 .741])
        xlim(ax.XAxis.Limits)
        subplot(427)
        hold on
        plot(st, ifr, ...
            'Color', [0 .447 .741], 'Marker', '.', 'LineStyle', 'none')
        xlim(ax.XAxis.Limits)
        
        % ifr vs L, V, F
        Lmt_st = interp1(time, Lmt, st);
        Lf_st = interp1(time, Lf, st);
        Fmt_st = interp1(time, Fmt, st);
        
        subplot(422)
        hold on
        plot(Lmt_st, ifr, ...
            'Color', [0 .447 .741], 'Marker', '.', 'LineStyle', 'none')
        xlabel('Lmt')
        xlim([-1 2.5])
        subplot(424)
        hold on
        plot(Lf_st, ifr, ...
            'Color', [0 .447 .741], 'Marker', '.', 'LineStyle', 'none')
        xlabel('Lf')
        xlim([-.25 1])
        subplot(426)
        hold on
        plot(Fmt_st, ifr, ...
            'Color', [0 .447 .741], 'Marker', '.', 'LineStyle', 'none')
        xlabel('Fmt')
        xlim([.2 .9])
    end
end
%%
saveas(F, 'C:\\Users\Jake\Documents\Lab\JEPfig4.jpg')
print(['C:\\Users\Jake\Documents\Data\Spindle_spring_figures\fig4a.eps'], '-depsc','-painters')
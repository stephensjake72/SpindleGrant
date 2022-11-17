% figure 1
clc
clear
close all
load('summaryTable.mat')

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
        
        % time series
        subplot(421)
        hold on
        plot(time, Lmt, 'k')
        xlim([.5 2.5])
        ax = gca;
        subplot(423)
        hold on
        plot(time, Lf, 'k')
        xlim(ax.XAxis.Limits)
        subplot(425)
        hold on
        plot(time, Fmt, 'k')
        xlim(ax.XAxis.Limits)
        subplot(427)
        hold on
        plot(st(st < 2.5), ifr(st < 2.5), '.k')
        plot(st(st >= 2.5), ifr(st >= 2.5), ...
            'Color', [.5 .5 .5], 'Marker', '.', 'LineStyle', 'none')
        xlim(ax.XAxis.Limits)
        
        subplot(422)
        plot(data.procdata.Lmt, data.procdata.Lf, 'k')
        xlim([-.5 3.5])
        subplot(424)
        plot(data.procdata.Lmt, data.procdata.Fmt, 'k')
        xlim([-.5 3.5])
        subplot(426)
        plot(data.procdata.Lf, data.procdata.Fmt, 'k')
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
        
        subplot(422)
        hold on
        plot(data.procdata.Lmt, data.procdata.Lf, 'Color', [0 .447 .741])
        xlabel('Lmt')
        ylabel('Lf')
        subplot(424)
        hold on
        plot(data.procdata.Lmt, data.procdata.Fmt, 'Color', [0 .447 .741])
        xlabel('Lmt')
        ylabel('Fmt')
        subplot(426)
        hold on
        plot(data.procdata.Lf, data.procdata.Fmt, 'Color', [0 .447 .741])
        xlabel('Lf')
        ylabel('Fmt')
    end
end
%%
saveas(F, 'C:\\Users\Jake\Documents\Lab\JEPfig1.jpg')
print(['C:\\Users\Jake\Documents\Data\Spindle_spring_figures\fig1.eps'], '-depsc','-painters')

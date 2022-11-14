% figure 1
clc
clear
close all
load('summaryTable.mat')

for ii = 1:100
    check1 = summaryTable.passive{ii};
    check2 = strcmp(summaryTable.type{ii}, 'ramp');
    check3 = summaryTable.badtrial{ii};
    check4 = summaryTable.amp{ii} == 3;
    
    if check1 && check2 && ~check3 && check4
        data = load(summaryTable.address{ii});
        figure
        subplot(411)
        plot(data.procdata.time, data.procdata.Lmt)
        ax = gca;
        subplot(412)
        plot(data.procdata.time, data.procdata.Fmt)
        xlim(ax.XAxis.Limits)
        subplot(413)
        plot(data.procdata.time, data.procdata.Lf)
        xlim(ax.XAxis.Limits)
        subplot(414)
        plot(data.procdata.spiketimes, data.procdata.ifr, '.k')
        xlim(ax.XAxis.Limits)
    end
end
%%
figure(8)
print(['C:\\Users\Jake\Documents\Data\Spindle_spring_figures\fig1.eps'], '-depsc','-painters')

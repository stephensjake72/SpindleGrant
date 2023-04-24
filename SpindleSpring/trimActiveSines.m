% trim active sines
clc
clear
close all
addpath(genpath('Functions'))
load('summaryTable.mat')
%%
for ii = 1:height(summaryTable)
    check1 = strcmp(summaryTable.type{ii}, 'sine');
    check2 = summaryTable.passive{ii} == 0;
    if check1 && check2
        data = load(summaryTable.address{ii});

        % find peaks
        [pks, locs] = findpeaks(data.procdata.Lmt, ...
            'MinPeakHeight', data.procdata.Lmt(1) + 1.5);
        badtrial = data.badtrial;
        if isempty(pks)
            badtrial = 1;
            save(summaryTable.address{ii}, 'badtrial', '-append')
            continue
        end
        pktimes = data.procdata.time(locs);
        cycleT = pktimes(2) - pktimes(1);
        stopT = pktimes(4) + cycleT/2;

        actwin = data.recdata.act(data.recdata.act < stopT);
        if ~isempty(actwin)
            continue
        end

        startT = data.procdata.time(1);
        keep = data.procdata.time <= stopT;
        spikekeep = data.procdata.spiketimes >= startT & data.procdata.spiketimes <= stopT;

        trimdata.time = data.procdata.time(keep);
        trimdata.Lmt = data.procdata.Lmt(keep);
        trimdata.Fmt = data.procdata.Fmt(keep);
        trimdata.Lf = data.procdata.Lf(keep);
        trimdata.vmt = data.procdata.vmt(keep);
        trimdata.ymt = data.procdata.ymt(keep);
        trimdata.vf = data.procdata.vf(keep);
        trimdata.amt = data.procdata.amt(keep);
        trimdata.af = data.procdata.af(keep);
        trimdata.spiketimes = data.procdata.spiketimes(spikekeep);
        trimdata.ifr = data.procdata.ifr(spikekeep);

        trimdatacheck = 1;
        if isempty(trimdata.spiketimes)
            badtrial = 1;
        end

        save(summaryTable.address{ii}, 'trimdata', 'trimdatacheck', 'badtrial', '-append')
        figure
        subplot(411)
        plot(trimdata.time, trimdata.Lmt)
        yyaxis right
        plot(trimdata.time, trimdata.vmt)
        ax = gca;
        subplot(412)
        plot(trimdata.time, trimdata.Lf)
        yyaxis right
        plot(trimdata.time, trimdata.vf)
        xlim(ax.XAxis.Limits)
        subplot(413)
        plot(trimdata.time, trimdata.Fmt)
        yyaxis right
        plot(trimdata.time, trimdata.ymt)
        subplot(414)
        plot(trimdata.spiketimes, trimdata.ifr, '.k')
        xlim(ax.XAxis.Limits)
    end
end
%%
summaryTable = tableAppend(summaryTable, {'trimdatacheck', 'badtrial'});
save('summaryTable.mat', 'summaryTable')
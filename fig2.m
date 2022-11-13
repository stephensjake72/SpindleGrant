% fig 2
clc
clear
close all
load('summaryTable.mat')
addpath(genpath('Functions'))

check1 = [summaryTable.passive{:}]' == 1;
check2 = strcmp(summaryTable.type, 'ramp');
check3 = strcmp(summaryTable.aff, 'IA');
check4 = [summaryTable.badtrial{:}]' == 0;
check5 = [summaryTable.amp{:}]' == 3;
check6 = ~strcmp(summaryTable.KT, 'B');
check7 = ~strcmp(summaryTable.KT, 'A');
keeprows = find(check1 & check2 & check3 & check4 & check5 & check6 & check7);
tempT = summaryTable(keeprows, :);

animals = unique(tempT.animal);
%%
for ii = 5% :numel(animals)
    anim = animals{ii} % group by animal
    animT = tempT(strcmp(tempT.animal, anim), :);
    cells = unique(animT.cell)
    for jj = 2%:numel(cells)
        cellT = animT(strcmp(animT.cell, cells{jj}), :); % group by cell
        if length(unique(cellT.KT)) == 2
            Ctab = cellT(strcmp(cellT.KT, 'C'), :); % group by compliance
            Ttab = cellT(strcmp(cellT.KT, 'T'), :);
            
            for mm = 2%:height(Ttab)
                Tdata = load(Ttab.address{mm});
%                 hold on
%                 subplot(121)
%                 plot(Tdata.procdata.time, Tdata.procdata.Fmt, 'k')
% %                 ylim([0 600])
            
                for nn = 10%1:height(Ctab)
                    Cdata = load(Ctab.address{nn});
%                     hold on
%                     subplot(122)
%                     plot(Cdata.procdata.time, Cdata.procdata.Fmt, '.r')
%     %                 ylim([0 600])
                    figure
                    subplot(212)
                    plot(Tdata.procdata.time, Tdata.procdata.Lmt - Tdata.procdata.Lmt(1), 'k', ...
                        Cdata.procdata.time - .1, Cdata.procdata.Lmt - Cdata.procdata.Lmt(1), 'r')
                    ax = gca;
                    subplot(211)
                    plot(Tdata.procdata.spiketimes, Tdata.procdata.ifr, '.k', ...
                        Cdata.procdata.spiketimes - .1, Cdata.procdata.ifr, '.r')
                    xlim(ax.XAxis.Limits)
                end
            end
        end
    end
end
%%
% find time lag bt Cdata and Tdata
[corr, lags] = xcorr(Tdata.procdata.Lmt, Cdata.procdata.Lmt);
[maxcorr, lagloc] = max(corr);
lag = lags(lagloc);
tshift = Tdata.procdata.time(abs(lag))/1.5;

figure
subplot(412)
plot(Tdata.procdata.time, Tdata.procdata.Lmt - Tdata.procdata.Lmt(1), 'k', ...
    Cdata.procdata.time - tshift, Cdata.procdata.Lmt - Cdata.procdata.Lmt(1), 'b')
xlim([0 max(Tdata.procdata.time)])
ax = gca;
subplot(411)
plot(Tdata.procdata.spiketimes, Tdata.procdata.ifr, '.k', ...
    Cdata.procdata.spiketimes - tshift, Cdata.procdata.ifr, '.b')
xlim(ax.XAxis.Limits)

clear Tdata Cdata
%%
check1 = [summaryTable.trimdatacheck{:}]' == 1;
check2 = strcmp(summaryTable.aff, 'IA');
check3 = [summaryTable.badtrial{:}]' == 0;
check4 = ~strcmp(summaryTable.KT, 'B');
check5 = ~strcmp(summaryTable.KT, 'A');
keeprows = find(check1 & check2 & check3 & check4 & check5);
tempT = summaryTable(keeprows, :);
%%
animals = unique(tempT.animal);
for pp = 1% :numel(animals)
    anim = animals{pp}; % group by animal
    animT = tempT(strcmp(tempT.animal, anim), :);
    cells = unique(animT.cell);
    for qq = 1% :numel(cells)
        cellT = animT(strcmp(animT.cell, cells{qq}), :); % group by cell
        if length(unique(cellT.KT)) == 2
            Ctab = cellT(strcmp(cellT.KT, 'C'), :); % group by compliance
            Ttab = cellT(strcmp(cellT.KT, 'T'), :);
            
            for rr = 1%:height(Ttab)
                Tdata = load(Ttab.address{rr});
                for ss = 4 % 1:height(Ctab)
                    Cdata = load(Ctab.address{ss});
%                     figure
%                     subplot(212)
%                     plot(Tdata.trimdata.time - Tdata.trimdata.time(1), Tdata.trimdata.Lmt - Tdata.procdata.Lmt(1), 'k', ...
%                         Cdata.trimdata.time - Cdata.trimdata.time(1), Cdata.trimdata.Lmt - Cdata.procdata.Lmt(1), 'b')
%                     ax = gca;
%                     subplot(211)
%                     plot(Tdata.trimdata.spiketimes - Tdata.trimdata.time(1), Tdata.trimdata.ifr, '.k', ...
%                         Cdata.trimdata.spiketimes - Cdata.trimdata.time(1), Cdata.trimdata.ifr, '.b')
%                     xlim(ax.XAxis.Limits)
                end
            end
        end
    end
end
%%
[corr, lags] = xcorr(Tdata.trimdata.Lmt, Cdata.trimdata.Lmt);
[maxcorr, lagloc] = max(corr);
lag = lags(lagloc);
tshift = Tdata.trimdata.time(abs(lag))/2;

% figure
subplot(414)
plot(Tdata.trimdata.time, Tdata.trimdata.Lmt - Tdata.trimdata.Lmt(1), 'k', ...
    Cdata.trimdata.time - tshift, Cdata.trimdata.Lmt - Cdata.trimdata.Lmt(1), 'b')
ax = gca;
subplot(413)
plot(Tdata.trimdata.spiketimes, Tdata.trimdata.ifr, '.k', ...
    Cdata.trimdata.spiketimes - tshift, Cdata.trimdata.ifr, '.b')
xlim(ax.XAxis.Limits)

print(['C:\\Users\Jake\Documents\Data\Spindle_spring_figures\fig2a.eps'], '-depsc','-painters')

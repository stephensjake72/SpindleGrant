% SICB POSTER FIGS

clc
clear
close all


% first figure, just showing the stretch metrics we'll be comparing
% for ramps, initial burst, dynamic response, static response
animal = 'A100142-24-62';
d = dir(['/Volumes/labs/ting/shared_ting/Jake/MultiAffs_mat/' animal '/procdata']);
ianum = '-7-';
iinum = '-3-';

count = [1 1];

pn = 1;
figure(1)
for m = 1:numel(d)
    if (contains(d(m).name, 'ramp') || contains(d(m).name, 'triangle')) && contains(d(m).name, ianum)
        iadata(count(1)) = load([d(m).folder filesep d(m).name]);

        subplot(20, 2, 2*count(1)-1)
        plot(iadata(count(1)).procdata.spiketimes, iadata(count(1)).procdata.ifr, '.k')
        set(gca, 'xtick', [])

        count(1) = count(1)+1;
        
    elseif (contains(d(m).name, 'ramp') || contains(d(m).name, 'triangle')) && contains(d(m).name, iinum)
        iidata(count(2)) = load([d(m).folder filesep d(m).name]);

        subplot(20, 2, 2*count(2))
        plot(iidata(count(2)).procdata.spiketimes, iidata(count(2)).procdata.ifr, '.k')
        set(gca, 'xtick', [])

        count(2) = count(2)+1;
    end
end

% velocity match
vels = zeros(length(iadata), 2);
for n = 1:length(iadata)
    vels(n, 1) = getStretchV(iadata(n).procdata);
    vels(n, 2) = getStretchV(iidata(n).procdata);
end
n1 = find(vels(:, 1) == 15, 1, 'first');
n2 = find(vels(:, 2) == 15, 1, 'first');
n3 = find(vels(:, 1) == 4, 1, 'last');
n4 = find(vels(:, 2) == 4, 1, 'last');
%%
figure
subplot(421)
plot(iadata(n1).procdata.time, iadata(n1).procdata.Lmt)
ax = gca;
ax.Box = 'off';
ax.XAxis.Limits = [-.1 1.5];

subplot(423)
plot(iadata(n1).procdata.spiketimes, iadata(n1).procdata.ifr, '.k')
xlim(ax.XAxis.Limits)
ax2 = gca;
set(gca, 'Box', 'off')

subplot(424)
plot(iidata(n2).procdata.spiketimes, iidata(n2).procdata.ifr, '.k')
set(gca, 'Box', 'off')
xlim(ax.XAxis.Limits)
ylim(ax2.YAxis.Limits)

subplot(425)
plot(iadata(n3).procdata.time, iadata(n3).procdata.Lmt)
ax3 = gca;
ax3.Box = 'off';
ax3.XAxis.Limits = [-.2 4.6];

subplot(427)
plot(iadata(n3).procdata.spiketimes, iadata(n3).procdata.ifr, '.k')
xlim(ax3.XAxis.Limits)
ax4 = gca;
set(gca, 'Box', 'off')

subplot(428)
plot(iidata(n4).procdata.spiketimes, iidata(n4).procdata.ifr, '.k')
set(gca, 'Box', 'off')
xlim(ax3.XAxis.Limits)
ylim(ax4.YAxis.Limits)

print('/Users/jacobstephens/Documents/Figures/SICBFig1A', '-depsc', '-painters')
clear ax ax2 ax3 ax4
%% plot velocity sweeps
close all
figure

lmtcolors = mapColors([0 0 0], [175 175 175]/255, 5);
iacolors = mapColors([31, 120, 180]/255, [166 206 227]/255, 5);
iicolors = mapColors([255, 127, 0]/255, [253, 191, 111]/255, 5);
velvals = [15 17 20 24 30];

for q = 1:length(iadata)
    colornum = find(velvals == vels(q, 1));
    iicolornum = find(velvals == vels(q, 2));

    if ~isempty(colornum)
        subplot(321)
        hold on
        plot(iadata(q).procdata.time, iadata(q).procdata.Lmt, ...
            'Color', lmtcolors(colornum, :))
        xlim([-.1 1.5])
        ax = gca;
        
        subplot(323)
        hold on
        plot(iadata(q).procdata.spiketimes, iadata(q).procdata.ifr, ...
            'Marker', 'o', ...
            'MarkerFaceColor', iacolors(colornum, :), ...
            'MarkerEdgeColor', iacolors(colornum, :), ...
            'MarkerSize', 1.5, ...
            'LineStyle', 'none')
        xlim(ax.XAxis.Limits)
    end

    if ~isempty(iicolornum)
        subplot(325)
        hold on
        plot(iidata(q).procdata.spiketimes, iidata(q).procdata.ifr, ...
            'Marker', 'o', ...
            'MarkerFaceColor', iicolors(iicolornum, :), ...
            'MarkerEdgeColor', iicolors(iicolornum, :), ...
            'MarkerSize', 1.5, ...
            'LineStyle', 'none')
        xlim(ax.XAxis.Limits)
        ylim([0 200])
    end
end

% now plot CB sims
[file, path] = uigetfile('/Users/jacobstephens/Documents/SimResults');
sim = load([path file]);

for q = 1:5
    subplot(322)
    hold on
    plot(sim.results.ia.dataB(q).t, sim.results.ia.dataB(q).cmd_length, ...
        'Color', lmtcolors(q, :))
    xlim(ax.XAxis.Limits)

    subplot(324)
    hold on
    plot(sim.results.ia.r_t(q, :), sim.results.ia.r(q, :), ...
        'Color', iacolors(q, :))
    xlim(ax.XAxis.Limits)

    subplot(326)
    hold on
    plot(sim.results.ii.r_t(q, :), sim.results.ii.r(q, :), ...
        'Color', iicolors(q, :))
    xlim(ax.XAxis.Limits)
end

print('/Users/jacobstephens/Documents/Figures/SICBFig1B', '-depsc', '-painters')
%% triangle sims
close all

trisim = load('trisims.mat'); % load triangle sims
load('triangleTable.mat'); % load triangle data

% table of group Ia and II spike count data
T1 = triT(strcmp(triT.affType, 'IA'), :); 
T2 = triT(strcmp(triT.affType, 'II'), :);

% compute AUC for sims as an analogue of spike count
simsc1 = computeTriSimSC(trisim.results.ia.r_t, trisim.results.ia.r);
simsc2 = computeTriSimSC(trisim.results.ii.r_t, trisim.results.ii.r);

% sample data file numbers
nia = 14;
nii = 17;

% plot
figure
subplot(421)
plot(iadata(nia).procdata.time, iadata(nia).procdata.Lmt, 'k')
xlim([min(iadata(nia).procdata.time) max(iadata(nia).procdata.time)])
ylabel('\Delta L_{MTU} (mm)')
ax = gca;

subplot(423)
plot(iadata(nia).procdata.spiketimes, iadata(nia).procdata.ifr, ...
        'Marker', 'o', ...
        'MarkerFaceColor', iacolors(1, :), ...
        'MarkerEdgeColor', iacolors(1, :), ...
        'MarkerSize', 1.5, ...
        'LineStyle', 'none')
xlim(ax.XAxis.Limits)
ylabel('IFR (pps)')

subplot(425)
plot(trisim.results.ia.r_t, trisim.results.ia.r, 'Color', iacolors(1, :))
xlim(ax.XAxis.Limits)
xlabel('time (s)')

subplot(427)
for nrow = 1:height(T1)
    hold on
    plot([1 2 3], [T1.sc1(nrow), T1.sc2(nrow), T1.sc3(nrow)], ...
        'Color', iacolors(1, :), ...
        'Marker', 'o', ...
        'MarkerFaceColor', iacolors(1, :))
end
xlim([0.5 3.5])
ylabel('spike count')
yyaxis right
plot([1 2 3], simsc1, 'k', 'Marker', 'o', 'MarkerFaceColor', 'k')
ylim([0 100])
ylabel('AUC')

subplot(422)
plot(iidata(nii).procdata.time, iidata(nii).procdata.Lmt, 'k')
xlim(ax.XAxis.Limits)

subplot(424)
plot(iidata(nii).procdata.spiketimes, iidata(nii).procdata.ifr, ...
        'Marker', 'o', ...
        'MarkerFaceColor', iicolors(1, :), ...
        'MarkerEdgeColor', iicolors(1, :), ...
        'MarkerSize', 1.5, ...
        'LineStyle', 'none')
xlim(ax.XAxis.Limits)

subplot(426)
plot(trisim.results.ii.r_t, trisim.results.ii.r, 'Color', iicolors(1, :))
xlim(ax.XAxis.Limits)

subplot(428)
for nrow = 1:height(T2)
    hold on
    plot([1 2 3], [T2.sc1(nrow), T2.sc2(nrow), T2.sc3(nrow)], ...
        'Color', iicolors(1, :), ...
        'Marker', 'o', ...
        'MarkerFaceColor', iicolors(1, :))
end
xlim([0.5 3.5])
ylim([0 100])
yyaxis right
plot([1 2 3], simsc2, 'k', 'Marker', 'o', 'MarkerFaceColor', 'k')
ylim([0 100])
ylabel('AUC')

print('/Users/jacobstephens/Documents/Figures/SICBFig2', '-depsc', '-painters')

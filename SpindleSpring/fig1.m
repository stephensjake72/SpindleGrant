% figure 1
clc
clear
close all
addpath(genpath('Functions'))

% Load data files
source = '/Volumes/labs/ting/shared_ting/Jake/Spindle spring data';
path = uigetdir(source);
savedir = '/Users/jacobstephens/Documents/Figures/Abbott_Stephens_manuscript';

D = dir(path);
D = D(3:end);
%% find ctrl data
F = figure();
for ii = 430%1:length(D)
    data = load([path filesep D(ii).name]);
    if strcmp(data.parameters.KT, 'T') && ...
            strcmp(data.parameters.type, 'ramp') && ...
            strcmp(data.parameters.ID, 'A18042-20-32')
        disp(ii)
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
        xlim([-.25 1.5])
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
        hold on
        scatter(data.procdata.Lmt, data.procdata.Lf, sz1, map1)
        set(gca, 'Box', 'off')
        xlim([-.5 3.5])
        subplot(424)
        hold on
        scatter(data.procdata.Lmt, data.procdata.Fmt, sz1, map1)
        set(gca, 'Box', 'off')
        xlim([-.5 3.5])
        subplot(426)
        hold on
        scatter(data.procdata.Lf, data.procdata.Fmt, sz1, map1)
        set(gca, 'Box', 'off')
        xlim([-.25 1.5])
    end
end

for jj = 487%1:length(D)
    data = load([path filesep D(jj).name]);
    if strcmp(data.parameters.KT, 'C') && ...
            strcmp(data.parameters.type, 'ramp') && ...
            strcmp(data.parameters.ID, 'A18042-20-32')
        disp(jj)
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
saveas(F, [savedir filesep 'JEPfig1.jpg'])
print([savedir filesep 'fig1timeseries.eps'], '-depsc','-painters')

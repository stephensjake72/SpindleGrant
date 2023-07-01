%  fig 2
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
close all
F = figure();
for ii = 427%1:length(D)
    data = load([path filesep D(ii).name]);
    if strcmp(data.parameters.KT, 'T') && ...
            strcmp(data.parameters.type, 'sine') && ...
            strcmp(data.parameters.ID, 'A18042-20-32')
%         disp(ii)
        time = data.procdata.time;
        st = data.procdata.spiketimes;
        ifr = data.procdata.ifr;
        Lmt = data.procdata.Lmt;
        Lf = data.procdata.Lf;
        vf = data.procdata.vf;
        Fmt = data.procdata.Fmt;
        
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
        xlim([-.25 2.25])
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
%         plot(Lmt_st, Lmt_st*data.models.mLmt, '--k')
        xlabel('Lmt')
        subplot(424)
        hold on
        scatter(Lf_st, ifr, 8*sz2, map2, 'filled')
%         plot(Lf_st, Lf_st*data.models.mLf, '--k')
        xlabel('Lf')
        subplot(426)
        hold on
        scatter(vf_st, ifr, 8*sz2, map2, 'filled')
%         plot(vf_st, vf_st*data.models.mvf, '--k')
        xlabel('vf')
        subplot(428)
        hold on
        scatter(Fmt_st, ifr, 8*sz2, map2, 'filled')
%         plot(Fmt_st, Fmt_st*data.models.mFmt, '--k')
        xlabel('Fmt')
    end
end

for jj = 400%1:length(D)
    data = load([path filesep D(jj).name]);
    if strcmp(data.parameters.KT, 'C') && ...
            strcmp(data.parameters.type, 'sine') && ...
            strcmp(data.parameters.ID, 'A18042-20-32')
%         disp(jj)
        time = data.procdata.time;
        st = data.procdata.spiketimes;
        ifr = data.procdata.ifr;
        Lmt = data.procdata.Lmt;
        vmt = data.procdata.vmt;
        Lf = data.procdata.Lf;
        vf = data.procdata.vf;
        Fmt = data.procdata.Fmt;
        
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
        xlim(ax.XAxis.Limits)
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
%         plot(Lmt_st, Lmt_st*data.models.mLmt, 'Color', cStart)
        xlim([-1 2.5])
        subplot(424)
        hold on
        scatter(Lf_st, ifr, 8*sz2, map2, 'filled')
%         plot(Lf_st, Lf_st*data.models.mLf, 'Color', cStart)
        xlim([-.5 1.5])
        subplot(426)
        hold on
        scatter(vf_st, ifr, 8*sz2, map2, 'filled')
%         plot(vf_st, vf_st*data.models.mvf, 'Color', cStart)
        xlabel('vf')
        xlim([-7.5 15])
        subplot(428)
        hold on
        scatter(Fmt_st, ifr, 8*sz2, map2, 'filled')
%         plot(Fmt_st, Fmt_st*data.models.mFmt(1), 'Color', cStart)
        xlabel('Fmt')
        xlim([.15 .75])
    end
end
%%
saveas(F, [savedir filesep 'JEPfig2.jpg'])
print([savedir filesep 'fig2timeseries.eps'], '-depsc','-painters')

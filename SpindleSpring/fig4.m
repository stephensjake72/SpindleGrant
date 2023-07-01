% fig 4
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
Tcount = 0;
for ii = 300:450%1:length(D)
    data = load([path filesep D(ii).name]);
    if strcmp(data.parameters.KT, 'T') && ...
            strcmp(data.parameters.type, 'triangle') && ...
            strcmp(data.parameters.ID, 'A18042-20-32')
        Tcount = Tcount + 1;
        if Tcount == 3
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
            plot(time, Lmt, 'k')
            xlim([-.25 4.75])
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
            scatter(st, ifr, sz2, map2, 'filled')
            xlim(ax.XAxis.Limits)

            % ifr vs L, V, F
            Lmt_st = interp1(time, Lmt, st);
            Lf_st = interp1(time, Lf, st);
            Fmt_st = interp1(time, Fmt, st);

            subplot(422)
            hold on
            scatter(Lmt_st, ifr, sz2, map2, 'filled')
%             plot(Lmt_st, data.models.mLmt*Lmt_st, 'k')
            xlabel('Lmt')
            subplot(424)
            hold on
            scatter(Lf_st, ifr, sz2, map2, 'filled')
%             plot(Lf_st, data.models.mLf*Lf_st, 'k')
            xlabel('Lf')
            subplot(426)
            hold on
            scatter(Fmt_st, ifr, sz2, map2, 'filled')
%             plot(Fmt_st, data.models.mFmt*Fmt_st, 'k')
            xlabel('Fmt')
        end
    end
end

Ccount = 0;
for jj = 400:410%length(D)
    data = load([path filesep D(jj).name]);
    if strcmp(data.parameters.KT, 'C') && ...
            strcmp(data.parameters.type, 'triangle') && ...
            strcmp(data.parameters.ID, 'A18042-20-32')
%         disp(jj)
        Ccount = Ccount + 1;
        if Ccount == 1
            time = data.procdata.time;
            st = data.procdata.spiketimes;
            ifr = data.procdata.ifr;
            Lmt = data.procdata.Lmt;
            Lf = data.procdata.Lf;
            Fmt = data.procdata.Fmt;

            % create color maps
            cStart = [230,85,13]/255;
            cStop = [253,190,133]/255;
            [map1, map2] = timeColorMap(time, st, cStart, cStop);
            sz1 = ones(1, numel(time));
            sz2 = 6*ones(1, numel(st));

            % time series
            subplot(421)
            hold on
            plot(time, Lmt, 'Color', cStart)
            xlim([-.25 4.75])
            ax = gca;
            subplot(423)
            hold on
            plot(time, Lf, 'Color', cStart)
            subplot(425)
            hold on
            plot(time, Fmt, 'Color', cStart)
            subplot(427)
            hold on
            scatter(st, ifr, sz2, map2, 'filled')
            xlim(ax.XAxis.Limits)

            % ifr vs L, V, F
            Lmt_st = interp1(time, Lmt, st);
            Lf_st = interp1(time, Lf, st);
            Fmt_st = interp1(time, Fmt, st);

            subplot(422)
            hold on
            scatter(Lmt_st, ifr, sz2, map2, 'filled')
            plot(Lmt_st, data.models.mLmt*Lmt_st, 'k')
            xlabel('Lmt')
            xlim([-.5 3.5])
            subplot(424)
            hold on
            scatter(Lf_st, ifr, sz2, map2, 'filled')
            plot(Lf_st, data.models.mLf*Lf_st, 'k')
            xlabel('Lf')
            xlim([-.25 1.75])
            subplot(426)
            hold on
            scatter(Fmt_st, ifr, sz2, map2, 'filled')
            plot(Fmt_st, data.models.mFmt*Fmt_st, 'k')
            xlabel('Fmt')
            xlim([0 1.25])
        end
    end
end
%%
saveas(F, [savedir filesep 'JEPfig4.jpg'])
print([savedir filesep 'fig4timeseries.eps'], '-depsc','-painters')
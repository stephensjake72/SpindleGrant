clc; clear; close all
addpath(genpath('Functions'))

% Load data files
% path = uigetdir('/Volumes/labs/ting/shared_ting/Jake/Workloop');
path = uigetdir('/Users/jacobstephens/Documents/Data/Workloop/');

savedir = [path filesep 'figures'];

load('lookuptable.mat');
%% figure 1 - data breakdown and plots by phase
clc; close all

cells = unique(T.cellid);
for n = 1:length(cells)
    rows = find(T.cellid == cells(n) & T.stretchtype == 'workloop');
    celltab = T(rows, :);
    amps = unique(celltab.amp);
    for r = 1:length(amps)
        tab = celltab(celltab.amp == amps(r), :);
        F = figure('Position', [0 0 1400 800]);
        for m = 1:height(tab) % data for a single cell
            % set plot color based on stim phase
            if tab.phase(m) == 0 || tab.phase(m) == 100
                color = [215 25 28]/255;
                X = [-.125 0];
                fplotnum = 13;
            elseif tab.phase(m) == 25
                color = [253 174 97]/255;
                X = [0 .125];
                fplotnum = 16;
            elseif tab.phase(m) == 50
                color = [171 221 164]/255;
                X = [0.125 .25];
                fplotnum = 19;
            elseif tab.phase(m) == 75
                color = [43 131 186]/255;
                X = [.25 .375];
                fplotnum = 22;
            end

            % load data and downsample
            data = load(tab.FileAddress{m});
            procdata = data.procdata;
            dsf = 10;
            t = procdata.time(1:dsf:end);
            Lm = procdata.Lmt(1:dsf:end);
            Lf = procdata.Lf(1:dsf:end);
            F = procdata.Fmt(1:dsf:end);

            %plot L and F
            subplot(8, 3, [1 4]); hold on; plot(t, Lm)
            xlabel('time'); ylabel('\Delta L_{MTU}'); xlim([-.5 5])

            subplot(8, 3, [7 10]); hold on; plot(t, F, 'Color', color)
            xlabel('time'); ylabel('F_{MTU}'); xlim([-.5 5])

            %plot work loop
            Lint = interp1(t, Lm, procdata.act);
            Fint = interp1(t, F, procdata.act);

            subplot(8, 3, [2 3 5 6 8 9 11 12]); hold on;
            plot(Lm, F, 'Color', [.8 .8 .8])
            plot(Lint, Fint, 'LineStyle','none', 'Marker', '.', 'Color', color)
            xlabel('\Delta L_{MTU}'); ylabel('F_{MTU}')

            % find peaks to stack sine phases
            [p, l] = findpeaks(Lm, 'MinPeakProminence', 0.4*data.parameters.amp);

            % plot force and firing rates \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
            for q = 1:length(p)
                % use peaks to plot from -50% to 100%
                ptime = t(l(q));
                tstart = ptime - 0.25;
                tstop = ptime + 0.375;
                win = t > tstart & t <= tstop;
                spikewin = procdata.spiketimes > tstart & procdata.spiketimes <= tstop;
                actwin = procdata.act > tstart & procdata.act <= tstop;
                % determine if an active or passive cycle
                if sum(actwin) < 1
                    c2 = [.75 .75 .75];
                else
                    c2 = color;
                end

                subplot(8, 3, fplotnum); hold on; yyaxis left;
                plot(t(win)-ptime, F(win), ...
                   'Color', c2, 'Marker', 'none', 'LineStyle', '-')
                if q >= 2 && q < length(p)
                    yyaxis right; plot(t(win)-ptime, Lm(win), ...
                        'Color', [.8 .8 .8], 'Marker', 'none', 'LineStyle', '-', ...
                        'LineWidth', 2)
                end
                ax = gca;
                Y = ax.YLim;

                subplot(8, 3, fplotnum+1); hold on; yyaxis left;
                plot(t(win) - ptime, Lf(win), ...
                    'LineStyle', '-', 'Marker', 'none', 'Color', c2)
                if q >= 2 && q < length(p)
                    yyaxis right; plot(t(win)-ptime, Lm(win), ...
                        'Color', [.8 .8 .8], 'Marker', 'none', 'LineStyle', '-')
                end

                subplot(8, 3, fplotnum+2); hold on; yyaxis left;
                plot(procdata.spiketimes(spikewin) - ptime, procdata.ifr(spikewin), ...
                    'LineStyle', 'none', 'Marker', '.', 'MarkerEdgeColor', c2)
                if q >= 2 && q < length(p)
                    yyaxis right; plot(t(win)-ptime, Lm(win), ...
                        'Color', [.8 .8 .8], 'Marker', 'none', 'LineStyle', '-')
                end
            end

            % plot highlight boxes \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
            subplot(8, 3, 13); yyaxis right; patch([-.125 0 0 -.125], ...
                [-5 -5 5 5], ...
                [255 255 191]/255, ...
                'FaceAlpha', .1, ...
                'EdgeColor', 'none')
            subplot(8, 3, 16); yyaxis right; patch([0 .125 .125 0], ...
                [min(ylim)*[1 1] max(ylim)*[1 1]], ...
                [255 255 191]/255, ...
                'FaceAlpha', .1, ...
                'EdgeColor', 'none')
            subplot(8, 3, 19); yyaxis right; patch([.125 .25 .25 .125], ...
                [-5 -5 5 5], ...
                [255 255 191]/255, ...
                'FaceAlpha', .1, ...
                'EdgeColor', 'none')
            subplot(8, 3, 22); yyaxis right; patch([-.25 -.125 -.125 -.25], ...
                [-5 -5 5 5], ...
                [255 255 191]/255, ...
                'FaceAlpha', .1, ...
                'EdgeColor', 'none')
            patch([.25 .375 .375 .25], ...
                [-5 -5 5 5], ...
                [255 255 191]/255, ...
                'FaceAlpha', .1, ...
                'EdgeColor', 'none')

            subplot(8, 3, 14); yyaxis right; patch([-.125 0 0 -.125], ...
                [-5 -5 5 5], ...
                [255 255 191]/255, ...
                'FaceAlpha', .1, ...
                'EdgeColor', 'none')
            subplot(8, 3, 17); yyaxis right; patch([0 .125 .125 0], ...
                [min(ylim)*[1 1] max(ylim)*[1 1]], ...
                [255 255 191]/255, ...
                'FaceAlpha', .1, ...
                'EdgeColor', 'none')
            subplot(8, 3, 20); yyaxis right; patch([.125 .25 .25 .125], ...
                [-5 -5 5 5], ...
                [255 255 191]/255, ...
                'FaceAlpha', .1, ...
                'EdgeColor', 'none')
            subplot(8, 3, 23); yyaxis right; patch([-.25 -.125 -.125 -.25], ...
                [-5 -5 5 5], ...
                [255 255 191]/255, ...
                'FaceAlpha', .1, ...
                'EdgeColor', 'none')
            patch([.25 .375 .375 .25], ...
                [-5 -5 5 5], ...
                [255 255 191]/255, ...
                'FaceAlpha', .1, ...
                'EdgeColor', 'none')

            subplot(8, 3, 15); yyaxis right; patch([-.125 0 0 -.125], ...
                [-5 -5 5 5], ...
                [255 255 191]/255, ...
                'FaceAlpha', .1, ...
                'EdgeColor', 'none')
            subplot(8, 3, 18); yyaxis right; patch([0 .125 .125 0], ...
                [min(ylim)*[1 1] max(ylim)*[1 1]], ...
                [255 255 191]/255, ...
                'FaceAlpha', .1, ...
                'EdgeColor', 'none')
            subplot(8, 3, 21); yyaxis right; patch([.125 .25 .25 .125], ...
                [-5 -5 5 5], ...
                [255 255 191]/255, ...
                'FaceAlpha', .1, ...
                'EdgeColor', 'none')
            subplot(8, 3, 24); yyaxis right; patch([-.25 -.125 -.125 -.25], ...
                [-5 -5 5 5], ...
                [255 255 191]/255, ...
                'FaceAlpha', .1, ...
                'EdgeColor', 'none')
            patch([.25 .375 .375 .25], ...
                [-5 -5 5 5], ...
                [255 255 191]/255, ...
                'FaceAlpha', .1, ...
                'EdgeColor', 'none')
            sgtitle([tab.cellid{1} ' ' tab.celltype{1}])
            clear procdata
        end
        F2 = gcf;
        savename = [tab.cellid{1} '-' num2str(amps(r)) 'mm-' tab.celltype{1}  '-1'];
        saveas(F2, [savedir filesep savename '.jpg'], 'jpeg')
        % close
    end
end
%% figure 2 - MTU work loops with spike timing
clc; close all

cells = unique(T.cellid);
for n = 1:length(cells)
    rows = find(T.cellid == cells(n) & T.stretchtype == 'workloop');
    celltab = T(rows, :);
    amps = unique(celltab.amp);
    for q = 1:length(amps)
        tab = celltab(celltab.amp == amps(q), :);
        F = figure('Position', [ 0 0 1400 700]);
        for m = 1:height(tab) % data for a single cell
            data = load(tab.FileAddress{m});
            procdata = data.procdata;
            da = [diff(procdata.act); 0];
            stimstops = [procdata.act(find(da > 0.15)); procdata.act(end)];
            stimstarts = [procdata.act(1); procdata.act(find(da > 0.15)+1)];
    
            [~, l] = findpeaks(procdata.Lmt, 'MinPeakProminence', data.parameters.amp*.9);
            tstart = procdata.time(l(1)) - 0.125;
            if tab.phase(m) == 0 || tab.phase(m) == 100
                color = [215 25 28]/255;
                plotnum = 1;
                highlightwin = procdata.time > tstart & procdata.time < tstart + .125;
            elseif tab.phase(m) == 25
                color = [253 174 97]/255;
                plotnum = 6;
                highlightwin = procdata.time > tstart + .125 & procdata.time < tstart + .25;
            elseif tab.phase(m) == 50
                color = [171 221 164]/255;
                plotnum = 11;
                highlightwin = procdata.time > tstart + .25 & procdata.time < tstart + .375;
            elseif tab.phase(m) == 75
                color = [43 131 186]/255;
                plotnum = 16;
                highlightwin = procdata.time > tstart + .375 & procdata.time < tstart + .5;
            end
    
            subplot(4, 5, [plotnum plotnum+1])
            hold on; plot(procdata.Lmt, procdata.Fmt, ...
                'LineStyle', '-', 'Marker', 'none', 'Color', [.8 .8 .8])
            xlabel('\Delta L_{MTU}'); ylabel('F_{MTU}')
    
            subplot(4, 5, plotnum + 2)
            win = procdata.time > tstart & procdata.time < tstart + 0.5;
            hold on; plot(procdata.time(win) - tstart, procdata.Lmt(win), ...
                'Color', [.8 .8 .8], 'LineWidth', 3)
            % xlim([0 .5])
            hold on; plot(procdata.time(highlightwin) - tstart, procdata.Lmt(highlightwin), ...
                'Color', color, 'LineWidth', 3)
            for p = 1:length(stimstarts)
                win = procdata.time > stimstarts(p) & procdata.time < stimstops(p);
                subplot(4, 5, [plotnum plotnum+1])
                hold on; plot(procdata.Lmt(win), procdata.Fmt(win), 'Color', color)
            end
            
            Lint = interp1(procdata.time, procdata.Lmt, procdata.spiketimes);
            Fint = interp1(procdata.time, procdata.Fmt, procdata.spiketimes);
            subplot(4, 5, [plotnum + 3, plotnum + 4])
            hold on; plot(procdata.Lmt, procdata.Fmt, ...
                'LineStyle', '-', 'Marker', 'none', 'Color', [.8 .8 .8])
            plot(Lint, Fint, 'LineStyle', 'none', 'Marker', '.', 'Color', color)
            xlabel('\Delta L_{MTU}'); ylabel('F_{MTU}');
            legend('spikes', 'Location', 'eastoutside')
    
            sgtitle([tab.cellid{1} ' ' tab.celltype{1}])
            
        end
        saveas(F, [savedir filesep tab.cellid{1} '-' num2str(amps(q)) 'mm-' tab.celltype{1} '-2.png'], 'png')
    end
    % for m = 1
end


%% figure 3 - fascicle workloops with spike timing
close all

cells = unique(T.cellid);
for n = 1:length(cells)
    rows = find(T.cellid == cells(n) & T.stretchtype == 'workloop');
    celltab = T(rows, :);
    amps = unique(celltab.amp);
    for q = 1:length(amps)
        tab = celltab(celltab.amp == amps(q), :);
        F = figure('Position', [ 0 0 1400 700]);
        for m = 1:height(tab) % data for a single cell
            data = load(tab.FileAddress{m});
            procdata = data.procdata;
            da = [diff(procdata.act); 0];
            stimstops = [procdata.act(find(da > 0.15)); procdata.act(end)];
            stimstarts = [procdata.act(1); procdata.act(find(da > 0.15)+1)];
    
            [~, l] = findpeaks(procdata.Lmt, 'MinPeakProminence', data.parameters.amp*.9);
            tstart = procdata.time(l(1)) - 0.125;
            if tab.phase(m) == 0 || tab.phase(m) == 100
                color = [215 25 28]/255;
                plotnum = 1;
                highlightwin = procdata.time > tstart & procdata.time < tstart + .125;
            elseif tab.phase(m) == 25
                color = [253 174 97]/255;
                plotnum = 6;
                highlightwin = procdata.time > tstart + .125 & procdata.time < tstart + .25;
            elseif tab.phase(m) == 50
                color = [171 221 164]/255;
                plotnum = 11;
                highlightwin = procdata.time > tstart + .25 & procdata.time < tstart + .375;
            elseif tab.phase(m) == 75
                color = [43 131 186]/255;
                plotnum = 16;
                highlightwin = procdata.time > tstart + .375 & procdata.time < tstart + .5;
            end
    
            subplot(4, 5, [plotnum plotnum+1])
            hold on; plot(procdata.Lf, procdata.Fmt, ...
                'LineStyle', '-', 'Marker', 'none', 'Color', [.8 .8 .8])
            xlabel('\Delta L_{F}'); ylabel('F_{MTU}')
    
            subplot(4, 5, plotnum + 2)
            win = procdata.time > tstart & procdata.time < tstart + 0.5;
            hold on; plot(procdata.time(win) - tstart, procdata.Lmt(win), ...
                'Color', [.8 .8 .8], 'LineWidth', 3)
            % xlim([0 .5])
            hold on; plot(procdata.time(highlightwin) - tstart, procdata.Lmt(highlightwin), ...
                'Color', color, 'LineWidth', 3)
            for p = 1:length(stimstarts)
                win = procdata.time > stimstarts(p) & procdata.time < stimstops(p);
                subplot(4, 5, [plotnum plotnum+1])
                hold on; plot(procdata.Lf(win), procdata.Fmt(win), 'Color', color)
            end
            
            Lint = interp1(procdata.time, procdata.Lf, procdata.spiketimes);
            Fint = interp1(procdata.time, procdata.Fmt, procdata.spiketimes);
            subplot(4, 5, [plotnum + 3, plotnum + 4])
            hold on; plot(procdata.Lf, procdata.Fmt, ...
                'LineStyle', '-', 'Marker', 'none', 'Color', [.8 .8 .8])
            plot(Lint, Fint, 'LineStyle', 'none', 'Marker', '.', 'Color', color)
            xlabel('\Delta L_{F}'); ylabel('F_{MTU}');
            legend('spikes', 'Location', 'eastoutside')
    
            sgtitle([tab.cellid{1} ' ' tab.celltype{1}])
            
        end
        saveas(F, [savedir filesep tab.cellid{1} '-' num2str(amps(q)) 'mm-' tab.celltype{1} '-3.png'], 'png')
    end
    % for m = 1
end

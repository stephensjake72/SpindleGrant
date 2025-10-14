clc;
clear;
close all

load('lookuptable.mat')
savedir = '/Users/jacobstephens/Documents/Data/Workloop/A100142-25-152/figures';
%%
clc; close all
wltab = T(strcmp(T.stretchtype, 'workloop'), :);

amps = unique(wltab.amp);
palette = (1/255)*[213,62,79;
        244,109,67;
        253,174,97;
        254,224,139;
        230,245,152;
        171,221,164;
        102,194,165;
        50,136,189];
for n = 1:length(amps) % loop through stretch amplitudes
    T1 = wltab(wltab.amp == amps(n), :);

    celltypes = unique(T1.celltype);
    nrow = length(celltypes) + 1;
    ncol = length(unique(T1.phase));
    F = figure('Position', [0 0 1800 1000]);
    sgtitle([num2str(amps(n)) ' mm'])
    for m = 1:length(celltypes) % loop through cell types
        T2 = T1(strcmp(T1.celltype, celltypes{m}), :); % data for a single cell type
        affs = unique(T2.cellid);
        plotcolors = genplotcolors(palette, length(affs));
        for p = 1:length(affs)
            T3 = T2(strcmp(T2.cellid, affs{p}), :); % data for a single cell
            for q = 1:height(T3)
                data = load(T3.FileAddress{q});
                procdata = data.procdata;

                [~, l] = findpeaks(procdata.Lmt, 'MinPeakProminence', 0.9*T3.amp(q));
                for r = 1:length(l)
                    tpeak = procdata.time(l(r));
                    tstart = tpeak - 0.125;
                    tstop = tpeak + .375;
                    win = data.R.t >= tstart - .125 & data.R.t < tstop;
                    awin = procdata.act >= tstart & procdata.act < tstop;
                    swin = procdata.spiketimes >= tstart & procdata.spiketimes < tstop;

                    if T3.phase(q) == 0
                        subplot(nrow, ncol, 1); hold on; yyaxis left;
                        plot(procdata.time(win) - tstart, procdata.Lmt(win), 'Color', [.8 .8 .8], ...
                            'LineStyle', '-', 'Marker', 'none')
                        yyaxis right; plot(procdata.act(awin) - tstart, procdata.actrate(awin), 'xr')
                    elseif T3.phase(q) == 25
                        subplot(nrow, ncol, 2); hold on; yyaxis left;
                        plot(procdata.time(win) - tstart, procdata.Lmt(win), 'Color', [.8 .8 .8], ...
                            'LineStyle', '-', 'Marker', 'none')
                        yyaxis right; plot(procdata.act(awin) - tstart, procdata.actrate(awin), 'xr')
                    elseif T3.phase(q) == 50 
                        subplot(nrow, ncol, 3); hold on; yyaxis left;
                        plot(procdata.time(win) - tstart, procdata.Lmt(win), 'Color', [.8 .8 .8], ...
                            'LineStyle', '-', 'Marker', 'none')
                        yyaxis right; plot(procdata.act(awin) - tstart, procdata.actrate(awin), 'xr')
                    elseif T3.phase(q) == 75 
                        subplot(nrow, ncol, 4); hold on; yyaxis left;
                        plot(procdata.time(win) - tstart, procdata.Lmt(win), 'Color', [.8 .8 .8], ...
                            'LineStyle', '-', 'Marker', 'none')
                        yyaxis right; plot(procdata.act(awin) - tstart, procdata.actrate(awin), 'xr')
                    end

                    if sum(awin) < 2
                        plotc = [.8 .8 .8];
                    else
                        plotc = plotcolors(p, :);
                    end

                    if T3.phase(q) == 0
                        subplot(nrow, ncol, 4*(m)+1);
                        hold on; plot(procdata.spiketimes(swin) - tstart, procdata.ifr(swin), ...
                        'Marker', '.', 'Color', plotc, 'LineStyle', 'none')
                        xlim([-.2 0.6]); ylim([0 500])
                        ylabel(celltypes{m})
                    elseif T3.phase(q) == 25
                        subplot(nrow, ncol, 4*(m)+2);
                        hold on; plot(procdata.spiketimes(swin) - tstart, procdata.ifr(swin), ...
                        'Marker', '.', 'Color', plotc, 'LineStyle', 'none')
                        xlim([-.2 0.6]); ylim([0 500])
                        ylabel(celltypes{m})
                    elseif T3.phase(q) == 50 
                        subplot(nrow, ncol, 4*(m)+3);
                        hold on; plot(procdata.spiketimes(swin) - tstart, procdata.ifr(swin), ...
                        'Marker', '.', 'Color', plotc, 'LineStyle', 'none')
                        xlim([-.2 0.6]); ylim([0 500])
                        ylabel(celltypes{m})
                    elseif T3.phase(q) == 75
                        subplot(nrow, ncol, 4*(m)+4);
                        hold on; plot(procdata.spiketimes(swin) - tstart, procdata.ifr(swin), ...
                        'Marker', '.', 'Color', plotc, 'LineStyle', 'none')
                        xlim([-.2 0.6]); ylim([0 500])
                        ylabel(celltypes{m})
                    end
                    
                end
                
            end
        end
    end
    savename = ['groupedcells_ifr_' num2str(amps(n)) 'mm'];
    saveas(F, [savedir filesep savename], 'png')
end


function C = genplotcolors(palette, n)
x1 = 1:height(palette);
x2 = linspace(1, height(palette), n);
c1 = interp1(x1, palette(:, 1), x2);
c2 = interp1(x1, palette(:, 2), x2);
c3 = interp1(x1, palette(:, 3), x2);
C = [c1' c2' c3'];
end
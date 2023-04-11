% Presentation Figures
% Author: JDS
% Updated 4/05/2023
clc
clear
close all
addpath(genpath('Functions'))

% Load data files
source = '/Volumes/labs/ting/shared_ting/Jake/A100142';
D = dir(source);
D = D(4:end);

paths = cell(1000, 1);
count = 1;
for ii = 1:numel(D)
    subdir = dir([D(ii).folder filesep D(ii).name filesep 'procdata']);
    for jj = 3:numel(subdir)
        paths{count} = [subdir(jj).folder filesep subdir(jj).name];
        count = count + 1;
    end
end

%%
paths = paths(~cellfun(@isempty, paths));
%%
offcount = 0;
oncount = 0;
F1 = figure('Position', [0 0 800 800])
for kk = 1:numel(paths)
    data = load(paths{kk});
    
    if strcmp(data.parameters.type, 'ramp')
        switch data.parameters.iso
            case 'on'
                subplot(6, 1, 1)
                hold on
                plot(data.procdata.spiketimes, data.procdata.ifr, '.k')
                xlim([-.5 2])
                ylim([0 600])
                title('ISO ON')
                subplot(6, 1, [2 3])
                hold on
                plot(data.procdata.spiketimes, ...
                    oncount*ones(1, length(data.procdata.spiketimes)), '|k')
                xlim([-.5 2])
                oncount = oncount + 1;
            case 'off'
                subplot(6, 1, 4)
                hold on
                plot(data.procdata.spiketimes, data.procdata.ifr, '.k')
                xlim([-.5 2])
                ylim([0 600])
                title('ISO OFF')
                subplot(6, 1, [5 6])
                hold on
                plot(data.procdata.spiketimes, ...
                    offcount*ones(1, length(data.procdata.spiketimes)), '|k')
                xlim([-.5 2])
                offcount = offcount + 1;
        end
    end
    hold off
end

savepath = '/Users/jacobstephens/Documents/Figures/04032023PresentationFig1.jpg';
saveas(F1, savepath)
clear oncount offcount
%%
offcount = 0;
oncount = 0;
F2 = figure('Position', [0 0 800 800])
for nn = 1:numel(paths)
    data = load(paths{nn});
    
    if strcmp(data.parameters.type, 'triangle')
        switch data.parameters.iso
            case 'on'
                subplot(6, 1, 1)
                hold on
                plot(data.procdata.spiketimes, data.procdata.ifr, '.k')
                xlim([-.5 4.5])
                ylim([0 200])
                title('ISO ON')
                subplot(6, 1, [2 3])
                hold on
                plot(data.procdata.spiketimes, ...
                    oncount*ones(1, length(data.procdata.spiketimes)), '|k')
                xlim([-.5 4.5])
                oncount = oncount + 1;
            case 'off'
                subplot(6, 1, 4)
                hold on
                plot(data.procdata.spiketimes, data.procdata.ifr, '.k')
                xlim([-.5 4.5])
                ylim([0 200])
                title('ISO OFF')
                subplot(6, 1, [5 6])
                hold on
                plot(data.procdata.spiketimes, ...
                    offcount*ones(1, length(data.procdata.spiketimes)), '|k')
                xlim([-.5 4.5])
                offcount = offcount + 1;
        end
    end
    hold off
end

savepath = '/Users/jacobstephens/Documents/Figures/04032023PresentationFig2.jpg';
saveas(F2, savepath)
clear oncount offcount
%%
offcount = 0;
oncount = 0;
F3 = figure('Position', [0 0 800 800])
for mm = 1:numel(paths)
    data = load(paths{mm});
    
    if strcmp(data.parameters.type, 'sine')
        switch data.parameters.iso
            case 'on'
                subplot(6, 1, 1)
                hold on
                plot(data.procdata.spiketimes, data.procdata.ifr, '.k')
                xlim([-.5 4.5])
                ylim([0 200])
                title('ISO ON')
                subplot(6, 1, [2 3])
                hold on
                plot(data.procdata.spiketimes, ...
                    oncount*ones(1, length(data.procdata.spiketimes)), '|k')
                xlim([-.5 4.5])
                oncount = oncount + 1;
            case 'off'
                subplot(6, 1, 4)
                hold on
                plot(data.procdata.spiketimes, data.procdata.ifr, '.k')
                xlim([-.5 4.5])
                ylim([0 200])
                title('ISO OFF')
                subplot(6, 1, [5 6])
                hold on
                plot(data.procdata.spiketimes, ...
                    offcount*ones(1, length(data.procdata.spiketimes)), '|k')
                xlim([-.5 4.5])
                offcount = offcount + 1;
        end
    end
    hold off
end

savepath = '/Users/jacobstephens/Documents/Figures/04032023PresentationFig3.jpg';
saveas(F3, savepath)
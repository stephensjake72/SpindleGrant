% EMG figures
% Author: JDS
% Updated 4/06/2023
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

paths = paths(~cellfun(@isempty, paths));

counter = zeros(1, 6);
F = figure('Position', [0 0 1200 800])
for kk = 1:numel(paths)
    data = load(paths{kk});
    
    switch data.parameters.type
        case 'ramp'
            subplot(9, 2, 5)
            plot(data.procdata.time, data.procdata.Lmt)
            xlim([-.5 2])
            subplot(9, 2, 6)
            plot(data.procdata.time, data.procdata.Lmt)
            xlim([-.5 2])
            
            if strcmp(data.parameters.iso, 'on')
                subplot(9, 2, [1 3])
                hold on
                plot(data.procdata.time, ...
                    data.procdata.EMG + counter(1))
                xlim([-.5 2])
                title('ISO ON')
                counter(1) = counter(1) + .01;
            else
                subplot(9, 2, [2 4])
                hold on
                plot(data.procdata.time, ...
                    data.procdata.EMG + counter(2))
                xlim([-.5 2])
                title('ISO OFF')
                counter(2) = counter(2) + .01;
            end
        case 'triangle'
            subplot(9, 2, 11)
            plot(data.procdata.time, data.procdata.Lmt)
            xlim([-.5 5])
            subplot(9, 2, 12)
            plot(data.procdata.time, data.procdata.Lmt)
            xlim([-.5 5])
            
            if strcmp(data.parameters.iso, 'on')
                subplot(9, 2, [7 9])
                hold on
                plot(data.procdata.time, ...
                    data.procdata.EMG + counter(3))
                xlim([-.5 5])
                counter(3) = counter(3) + .01;
            else
                subplot(9, 2, [8 10])
                hold on
                plot(data.procdata.time, ...
                    data.procdata.EMG + counter(4))
                xlim([-.5 5])
                counter(4) = counter(4) + .01;
            end
        case 'sine'
            subplot(9, 2, 17)
            plot(data.procdata.time, data.procdata.Lmt)
            xlim([-.5 4])
            subplot(9, 2, 18)
            plot(data.procdata.time, data.procdata.Lmt)
            xlim([-.5 4])
            
            if strcmp(data.parameters.iso, 'on')
                subplot(9, 2, [13 15])
                hold on
                plot(data.procdata.time, ...
                    data.procdata.EMG + counter(5))
                xlim([-.5 4])
                counter(5) = counter(5) + .01;
            else
                subplot(9, 2, [14 16])
                hold on
                plot(data.procdata.time, ...
                    data.procdata.EMG + counter(6))
                xlim([-.5 4])
                counter(6) = counter(6) + .01;
            end
    end
end
savepath = '/Users/jacobstephens/Documents/Figures/04032023PresentationFig5.jpg';
saveas(F, savepath)
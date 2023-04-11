% Force figures
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

paths = paths(~cellfun(@isempty, paths));
%%
F = figure('Position', [0 0 800 800])

for kk = 1:length(paths)
    data = load(paths{kk});
    
    switch data.parameters.type
        case 'ramp'
            if strcmp(data.parameters.iso, 'on')
                subplot(3, 2, 1)
                hold on
                plot(data.procdata.time, data.procdata.Fmt)
                xlim([-.5 2])
                title('ISO ON')
            else
                subplot(3, 2, 2)
                hold on
                plot(data.procdata.time, data.procdata.Fmt)
                xlim([-.5 2])
                title('ISO OFF')
            end
        case 'triangle'
            if strcmp(data.parameters.iso, 'on')
                subplot(3, 2, 3)
                hold on
                plot(data.procdata.time, data.procdata.Fmt)
                xlim([-.5 4.5])
            else
                subplot(3, 2, 4)
                hold on
                plot(data.procdata.time, data.procdata.Fmt)
                xlim([-.5 4.5])
            end
        case 'sine'
            if strcmp(data.parameters.iso, 'on')
                subplot(3, 2, 5)
                hold on
                plot(data.procdata.time, data.procdata.Fmt)
                xlim([-.5 3.5])
            else
                subplot(3, 2, 6)
                hold on
                plot(data.procdata.time, data.procdata.Fmt)
                xlim([-.5 3.5])
            end
    end
end

savepath = '/Users/jacobstephens/Documents/Figures/04032023PresentationFig4.jpg';
saveas(F, savepath)
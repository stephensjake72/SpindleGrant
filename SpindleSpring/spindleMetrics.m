% extract spindle metrics

clc
clear
close all

addpath(genpath('Functions'));

source = '/Volumes/labs/ting/shared_ting/Jake/Spindle spring data/';
path  = uigetdir(source);
D = dir(path);
D = D(3:end);

savedir = [path(1:find(path == '/', 1, 'last')) 'procdata_w_stiffness_ifr'];
if ~exist(savedir, 'dir')
    mkdir(savedir)
end

%%
clc
close all
for ii = 601:length(D)
    disp(ii)
    data = load([path filesep D(ii).name]);
    switch data.parameters.type
        case 'ramp'
            ifrMetrics = exportRampMetrics(data.procdata);
%             figure('Position', [100 100 500 500])
%             hold on
%             plot(data.procdata.spiketimes, data.procdata.ifr, '.k')
%             plot(ifrMetrics.ibt, ifrMetrics.IBA, '.r')
%             yline(ifrMetrics.DRA)
%             yline(ifrMetrics.SRA)
%             title(D(ii).name, 'Interpreter', 'none')
%             
%             [text, ~] = listdlg('ListString', {''});
%             close
        case 'sine'
            ifrMetrics = exportSineMetrics(data.procdata);
%             figure
%             hold on
%             plot(data.procdata.spiketimes, data.procdata.ifr, '.k')
%             plot(ifrMetrics.ifrpktimes, ifrMetrics.ifrpks, '.r', 'MarkerSize', 12)
%             plot(stops, zeros(1, length(stops)), 'xk')
        case 'triangle'
            ifrMetrics = exportTriangleMetrics(data.procdata);

%             hold on
%             plot(data.procdata.spiketimes, data.procdata.ifr, '.k')
%             plot(ifrMetrics.ibt, ifrMetrics.triIB, '.r')
%             plot(ifrMetrics.drst(1), ifrMetrics.drifr(1), '.c')
    end
    
    % save
    procdata = data.procdata;
    parameters = data.parameters;
    stiffness = data.stiffness;
    save([savedir filesep D(ii).name], 'procdata', 'parameters', ...
        'stiffness', 'ifrMetrics')
    clear ifrMetrics
end
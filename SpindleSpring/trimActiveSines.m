% Script to trim the active components of the work loop data
% Author: JDS
% Updated: 5/24/23
clc
clear
close all

% access functions
addpath(genpath('Functions'));

% Load data files
source = '/Volumes/labs/ting/shared_ting/Jake/';
path = uigetdir(source);
D = dir(path);
savedir = [path(1:find(path == '/', 1, 'last')) 'procdata_fixed_sines'];
if ~exist(savedir, 'dir')
    mkdir(savedir)
end

D = D(3:end);
%%
close all
for ii = 1:numel(D)
    disp(ii)
    data = load([path filesep D(ii).name]);
    
    if strcmp(data.parameters.type, 'sine')
        procdata = data.procdata;
        acttimes = procdata.act;
        actrate = 1./(acttimes(2:end) - acttimes(1:end-1));
        
        if find(actrate > 5) > 0
            stopT = 2.25; %acttimes(find(actrate > 60, 1, 'first'));
        else
            stopT = data.procdata.time(end);
        end
        
        keep = procdata.time < stopT;
        procdata.time = procdata.time(keep);
        procdata.Lmt = procdata.Lmt(keep);
        procdata.Fmt = procdata.Fmt(keep);
        procdata.Lf = procdata.Lf(keep);
        procdata.vmt = procdata.vmt(keep);
        procdata.ymt = procdata.ymt(keep);
        procdata.vf = procdata.vf(keep);
        procdata.spiketimes = procdata.spiketimes(procdata.spiketimes < stopT);
        procdata.ifr = procdata.ifr(procdata.spiketimes < stopT);
        procdata.act = procdata.act(procdata.act < stopT);
        
        subplot(411)
        hold on
        plot(procdata.time, procdata.Lmt)
        subplot(412)
        hold on
        plot(procdata.time, procdata.Fmt)
        subplot(413)
        hold on
        plot(procdata.time, procdata.Lf)
        subplot(414)
        hold on
        plot(procdata.spiketimes, procdata.ifr, '.k')
        
        parameters = data.parameters;
    else
        procdata = data.procdata;
        parameters = data.parameters;
    end
    save([savedir filesep D(ii).name], 'procdata', 'parameters')
    clear parameters procdata
end
%%

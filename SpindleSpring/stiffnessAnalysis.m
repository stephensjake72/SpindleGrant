clc
clear
close all
addpath(genpath('Functions'))

source = '/Volumes/labs/ting/shared_ting/Jake/Spindle spring data/';
path  = uigetdir(source);
D = dir(path);
D = D(3:end);

savedir = [path(1:find(path == '/', 1, 'last')) 'procdata_w_stiffness'];
if ~exist(savedir, 'dir')
    mkdir(savedir)
end
%%
for ii = 1:length(D)
    data = load([D(ii).folder filesep D(ii).name]);
    
    switch data.parameters.type
        case 'ramp'
            thr = .5;
        case 'triangle'
            thr = .4;
        case 'sine'
            thr = .4;
    end
    stiffness = computeStiffness(data.procdata, thr);
    
%     if strcmp(data.parameters.type, 'triangle')
%         dx = [-.1 0 .1];
%         dF = stiffness.kMTU*dx;
%         hold on
%         plot(data.procdata.Lmt, data.procdata.Fmt, 'k')
%         plot(stiffness.Lmtcenter + dx, stiffness.Fmtcenter + dF, 'r')
%     end
    % save
    procdata = data.procdata;
    parameters = data.parameters;
    save([savedir filesep D(ii).name], 'stiffness', 'procdata', 'parameters')
    clear stiffness thr data
end
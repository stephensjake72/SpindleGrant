% fit regressions
clc
clear
close all

addpath(genpath('Functions'));

source = '/Volumes/labs/ting/shared_ting/Jake/Spindle spring data/';
path  = uigetdir(source);
D = dir(path);
D = D(3:end);

savedir = [path(1:find(path == '/', 1, 'last')) 'procdata_w_stiffness_ifr_regs'];
if ~exist(savedir, 'dir')
    mkdir(savedir)
end
%%
plotcount = 1;
for ii = 1:length(D)
    data = load([path filesep D(ii).name]);
    
    % check stetch type
    type = data.parameters.type;
    % fit model
    models = fitmodels(data.procdata, type);
    % save
    procdata = data.procdata;
    parameters = data.parameters;
    stiffness = data.stiffness;
    ifrMetrics = data.ifrMetrics;
%     save([savedir filesep D(ii).name], 'procdata', 'parameters', ...
%         'stiffness', 'ifrMetrics', 'models')
        
    if strcmp(data.parameters.type, 'ramp') && ii < 100
        expdata = data.procdata;
        Lmtst = interp1(expdata.time, expdata.Lmt, expdata.spiketimes);
        Lfst = interp1(expdata.time, expdata.Lf, expdata.spiketimes);
        vfst = interp1(expdata.time, expdata.vf, expdata.spiketimes);
        Fmtst = interp1(expdata.time, expdata.Fmt, expdata.spiketimes);
        ifr = expdata.ifr;
        
        x = Fmtst;
        figure
        plot(x, expdata.ifr, '.k')
        hold on
        plot(x, Fmtst*models.mFmt + models.bFmt)
        title(num2str(models.mFmt))

        plotcount = plotcount + 1;
    end
    clear models
end
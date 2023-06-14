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
    save([savedir filesep D(ii).name], 'procdata', 'parameters', ...
        'stiffness', 'ifrMetrics', 'models')
        
    if plotcount <= 50
        expdata = data.procdata;
        Lmtst = interp1(expdata.time, expdata.Lmt, expdata.spiketimes);
        Lfst = interp1(expdata.time, expdata.Lf, expdata.spiketimes);
        vfst = interp1(expdata.time, expdata.vf, expdata.spiketimes);
        Fmtst = interp1(expdata.time, expdata.Fmt, expdata.spiketimes);
        ifr = expdata.ifr;

        figure
        subplot(421)
        plot(expdata.time, models.mLmt*expdata.Lmt + models.bLmt)
        hold on
        plot(expdata.spiketimes, expdata.ifr, '.k')
        title('Lmt')

        subplot(422)
        plot(Lmtst, models.mLmt*Lmtst + models.bLf, 'r')
        hold on
        plot(Lmtst, ifr, '.k')

        subplot(423)
        plot(expdata.time, models.mLf*expdata.Lf + models.bLf)
        hold on
        plot(expdata.spiketimes, expdata.ifr, '.k')
        title('Lf')

        subplot(424)
        plot(Lfst, models.mLf*Lfst + models.bLf, 'r')
        hold on
        plot(Lfst, ifr, '.k')

        subplot(425)
        plot(expdata.time, models.mvf*expdata.vf + models.bvf)
        hold on
        plot(expdata.spiketimes, expdata.ifr, '.k')
        title('Vf')

        subplot(426)
        plot(vfst, models.mvf*vfst + models.bvf, 'r')
        hold on
        plot(vfst, ifr, '.k')

        subplot(427)
        plot(expdata.time, models.mFmt*expdata.Fmt + models.bFmt)
        hold on
        plot(expdata.spiketimes, expdata.ifr, '.k')
        title('Force')

        subplot(428)
        plot(Fmtst, models.mFmt*Fmtst + models.bFmt, 'r')
        hold on
        plot(Fmtst, ifr, '.k')
        title(num2str(models.rFmt))

        plotcount = plotcount + 1;
    end
    clear models
end
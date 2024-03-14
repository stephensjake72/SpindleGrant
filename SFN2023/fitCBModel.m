% model fitting
 
clc
clear
close all
addpath(genpath('Functions'))

path = '/Volumes/labs/ting/shared_ting/Jake/SFN/procdataRamps100mN';
D = dir(path);
D = D(3:end);
%%
savedir = ['/Volumes/labs/ting/shared_ting/Jake/SFN/Fits-100mN-CB-' char(datetime('today'))];
if ~exist(savedir, 'dir')
    mkdir(savedir);
end

%%
clc
close all

CBm = load('/Users/jacobstephens/Documents/GitHub/Simha-Ting2023JExptPhysiol/sim_output/08-Nov-2023/rampSim4pCa64Amp56Vel360.mat');

for ii = 1:100%numel(D) %numel(D)
    
    data = load([path filesep D(ii).name]);
    
    spiketimes = data.procdata.spiketimes;
    ifr = data.procdata.ifr;

    switch data.parameters.aff
        case 'IA'
            %        Fc,   Fb,   Yb, Yc
            init =  [1000, 100,  1,  0]; % allow no yank from the chain
            upper = [1500, 200,  8,  0];
            lower = [0,    0,    0,  0];
            param = [init; lower; upper];

        case 'II'
            %        Fc,   Fb, Yb, Yc
            init =  [1000, 0,   0,  0]; % allow no bag components
            upper = [1500, 0,   0,  9]; % allow a small chain yank component
            lower = [0,    0,   0,  0];
            param = [init; lower; upper];
    end
    
    CBfit = getFYgains_CB(CBm, spiketimes, ifr, param);
    
    if mod(ii, 3) == 0
        figure
        plot(CBfit.time, CBfit.predictor, 'r')
        hold on
        plot(CBfit.spiketimes, CBfit.ifr, '.k')
        plot(CBfit.time, CBfit.Fc)

        title({['kFb: ' num2str(CBfit.kFc)], ['kFc: ' num2str(CBfit.kFb)]; ...
            ['kYb: ' num2str(CBfit.kYb)], ['kYc: ' num2str(CBfit.kYb)]})
        sgtitle(data.parameters.aff)
        xlim([-.5 1])
    end
    parameters = data.parameters;
    save([savedir filesep D(ii).name], 'CBfit', 'parameters')
end

% run("writeSumTable.m")
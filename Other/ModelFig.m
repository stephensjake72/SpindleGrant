clc
clear
close all
addpath(genpath('Functions'))

% Load data files
path = '\\cosmic.bme.emory.edu\labs\ting\shared_ting\Jake\other\procdata';

D = dir(path);
D = D(3:end);

%%
close all
for ii = 1:numel(D)
    if ~contains(D(ii).name, 'ramp') || ~contains(D(ii).name, 'IA')
        continue
    end
    data = load([D(ii).folder filesep D(ii).name]);
    
    figure
    subplot(211)
    plot(data.procdata.time, data.procdata.Fmt, ...
        data.procdata.time, data.procdata.ymt)
    subplot(212)
    plot(data.procdata.spiketimes, data.procdata.ifr, '.k')
    sgtitle(num2str(ii))
end
% IA: 118
% II: 35
% IB: 170
%%
iadata = load([D(118).folder filesep D(118).name]);
iidata = load([D(35).folder filesep D(35).name]);
ibdata = load([D(170).folder filesep D(170).name]);
%%
% A kexp klin L0 kf ky bf by lam
init = [0 0 0 0 0 0 0 0 0];
lower = [0 0 0 -3 0 0 -1 0 0];
upper = [2 2.5 0 3 1000 50 1 0 0];
parameters = [init; lower; upper];

iafit = getFYgains(iadata.procdata, parameters, 'Blum');
ibfit = getFYgains(ibdata.procdata, parameters, 'Blum');
iifit = getFYgains(iidata.procdata, parameters, 'Blum');
%%
figure
subplot(321)
plot(iadata.procdata.time, iadata.procdata.Fmt)
yyaxis right
plot(iadata.procdata.time, iadata.procdata.ymt)

subplot(322)
plot(iadata.procdata.time, iafit.Fc, ...
    iadata.procdata.time, iafit.Yc)

subplot(323)
plot(iadata.procdata.time, iafit.Fcomp, ...
    iadata.procdata.time, iafit.Ycomp, ...
    iadata.procdata.time, iafit.predictor, ...
    iadata.procdata.spiketimes, iadata.procdata.ifr, '.k')
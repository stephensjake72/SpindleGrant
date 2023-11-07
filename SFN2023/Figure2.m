clc
clear
close all
 
addpath(genpath('Functions'))
source = uigetdir('/Volumes/labs/ting/shared_ting/Jake/SFN/');
 
savedir = uigetdir();
 
D = dir(source);
D = D(3:end);

%% Check for good trials

Animal = 'A100401-22-116';
% 
% for ii = 1:numel(D)
%     if contains(D(ii).name, 'IA') && contains(D(ii).name, Animal)
% 
%         data = load([D(ii).folder filesep D(ii).name]);
%         plotModel(data.fit)
%         sgtitle({num2str(ii); data.parameters.type})
% 
%     elseif contains(D(ii).name, 'II') && contains(D(ii).name, Animal)
% 
%         data = load([D(ii).folder filesep D(ii).name]);
% 
%         plotModel(data.fit)
%         sgtitle({num2str(ii); data.parameters.type})
%     end
% end


%%
close all
IAdata = load([D(90).folder filesep D(90).name]);
IIdata = load([D(75).folder filesep D(75).name]);

% panel 1: forces and yank
F1 = figure(1)
subplot(511)
plot(IAdata.fit.time, IAdata.fit.Fc)
subplot(512)
plot(IAdata.fit.time, IAdata.fit.Yc)
subplot(513)
plot(IIdata.fit.time, IIdata.fit.Fc)
subplot(514)
plot(IIdata.fit.time, IIdata.fit.Yc)
subplot(515)
plot(IAdata.fit.time, IAdata.fit.Lmt)


% panel 2: models
F2 = figure(2)
subplot(211)
hold on
plot(IAdata.fit.time, IAdata.fit.Fcomp, 'Color', [.5 .5 .5])
plot(IAdata.fit.time, IAdata.fit.Ycomp, 'Color', [.5 .5 .5])
plot(IAdata.fit.time, IAdata.fit.predictor, ...
    'Color', [49, 130, 189]/255)
plot(IAdata.fit.spiketimes, IAdata.fit.ifr, '.k')
xlim([-.25 1.75])
ylim([0 600])

subplot(212)
hold on
plot(IIdata.fit.time, IIdata.fit.Fcomp, 'Color', [.5 .5 .5])
plot(IIdata.fit.time, IIdata.fit.Ycomp, 'Color', [.5 .5 .5])
plot(IIdata.fit.time, IIdata.fit.predictor, ...
    'Color', [230, 85, 13]/255)
plot(IIdata.fit.spiketimes, IIdata.fit.ifr, '.k')
xlim([-.25 1.75])
ylim([0 600])

saveas(F1, [savedir filesep 'ModelForces.eps'], 'epsc')
saveas(F1, [savedir filesep 'ModelForces.jpg'], 'jpeg')
saveas(F2, [savedir filesep 'ModelFits.eps'], 'epsc')
saveas(F1, [savedir filesep 'ModelFits.jpg'], 'jpeg')
clc
clear
close all
 
addpath(genpath('Functions'))
source = uigetdir('/Volumes/labs/ting/shared_ting/Jake/A100401/');
 
savedir = '/Volumes/labs/ting/shared_ting/Jake/A100401';
savefolder = [savedir filesep 'figures ' char(datetime('today'))];

if ~isfolder(savefolder)
    mkdir(savefolder)
end
 
D = dir(source);
D = D(3:end);
 
%% check files
close all
for ii = 401:500
    disp(ii)
    data = load([D(ii).folder filesep D(ii).name]);
    if strcmp(data.parameters.type, 'triangle')
        continue
    end
    switch data.parameters.aff
        case 'IA'
            figure('Position', [200 200 400 400])
            hold on
            plot(data.procdata.time, data.fit.predictor, 'r')
            plot(data.procdata.spiketimes, data.procdata.ifr, '.k')
            title(D(ii).name, 'interpreter', 'none')
        case 'II'
            figure('Position', [600 200 400 400])
            hold on
            plot(data.procdata.time, data.fit.predictor, 'r')
            plot(data.procdata.spiketimes, data.procdata.ifr, '.k')
            title(D(ii).name, 'interpreter', 'none')
    end
end
%%
% A100401-22-129_cell_04_IA_51s
% A100401-22-129_cell_09_II_129s
close all
sampleIA = load([source filesep 'A100401-22-129_cell_04_IA_51s.mat']);
sampleII = load([source filesep 'A100401-22-129_cell_09_II_129s.mat']);

% figure
% subplot(411)
% plot(sampleIA.procdata.time, sampleIA.procdata.Lmt)
% ax = gca;
% subplot(412)
% plot(sampleIA.procdata.time, sampleIA.procdata.Fmt, sampleIA.procdata.time, sampleIA.fit.Fc)
% subplot(413)
% plot(sampleIA.procdata.time, sampleIA.procdata.ymt, sampleIA.procdata.time, sampleIA.fit.Yc)
% subplot(414)
% plot(sampleIA.procdata.spiketimes, sampleIA.procdata.ifr, '.k')
% xlim(ax.XAxis.Limits)
% sgtitle(sampleIA.parameters.aff)
% print('ISBmethods.eps', '-depsc','-painters')
% close

figure
plot(sampleIA.procdata.time, sampleIA.fit.predictor)
hold on
plot(sampleIA.procdata.time, sampleIA.fit.Fcomp)
plot(sampleIA.procdata.time, sampleIA.fit.Ycomp)
hold off
print('ISBModel.eps', '-depsc', '-painters')

% figure
% subplot(211)
% plot(sampleIA.procdata.spiketimes, sampleIA.procdata.ifr, '.k', ...
%     sampleIA.procdata.time, sampleIA.fit.predictor, 'r')
% legend({['k_F: ' num2str(sampleIA.fit.kF)], ...
%     ['k_Y: ' num2str(sampleIA.fit.kY)]})
% ax = gca;
% title(sampleIA.parameters.aff)
% subplot(212)
% plot(sampleII.procdata.spiketimes, sampleII.procdata.ifr, '.k', ...
%     sampleII.procdata.time, sampleII.fit.predictor, 'r')
% legend({['k_F: ' num2str(sampleII.fit.kF)], ...
%     ['k_Y: ' num2str(sampleII.fit.kY)]})
% ylim(ax.YAxis.Limits)
% title(sampleII.parameters.aff)
% print(['ISBtimeseries.eps'], '-depsc','-painters')


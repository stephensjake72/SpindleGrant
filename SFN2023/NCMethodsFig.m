clc
clear
close all
 
addpath(genpath('Functions'))
source = '/Volumes/labs/ting/shared_ting/Jake/SFN/Fits-100mN-alteredinterp-07-Nov-2023';
 
savedir = '/Users/jacobstephens/Library/CloudStorage/OneDrive-GeorgiaInstituteofTechnology/Research/Posters/SFN23/Figures';
 
D = dir(source);
D = D(3:end);

IAdata = load([D(90).folder filesep D(90).name]);
fit = IAdata.fit;
%%
F1 = figure(1)
subplot(211)
plot(fit.time, fit.Fmt, 'k')
subplot(212)
plot(fit.time, fit.Lmt, 'k')

F2 = figure(2)
subplot(211)
hold on
plot(fit.time, fit.Fmt, 'Color', [.5 .5 .5])
plot(fit.time, fit.Fc, 'Color', [49,163,84]/255)
legend('MTU', 'Cont.')
subplot(212)
hold on
plot(fit.time, fit.ymt, 'Color', [.5 .5 .5])
plot(fit.time, fit.Yc, 'Color', [49,163,84]/255)

saveas(F1, [savedir filesep 'NCa.eps'], 'epsc')
saveas(F1, [savedir filesep 'NCa.jpg'], 'jpeg')
saveas(F2, [savedir filesep 'NCb.eps'], 'epsc')
saveas(F2, [savedir filesep 'NCb.jpg'], 'jpeg')
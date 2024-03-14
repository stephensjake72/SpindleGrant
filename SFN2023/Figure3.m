clc
clear
close all
savedir = '/Users/jacobstephens/Library/CloudStorage/OneDrive-GeorgiaInstituteofTechnology/Research/Posters/SFN23/Figures';

% load CB model
CBm = load('/Users/jacobstephens/Documents/GitHub/Simha-Ting2023JExptPhysiol/sim_output/08-Nov-2023/rampSim4pCa64Amp56Vel360.mat');
Fb = CBm.force.bag/1e5 - 1.2;
Fc = CBm.force.chain/1e5 - .5;
Yb = CBm.yank.bag/1e5;
t = CBm.t - 2;

% load data
D = dir('/Volumes/labs/ting/shared_ting/Jake/SFN/procdataRamps100mN');
D = D(3:end);

IAdata = load([D(90).folder filesep D(90).name]);
IIdata = load([D(75).folder filesep D(75).name]);
%%
close all
% compute current
rSIA = 700*Fc + 400*Fb;
rDIA = 5.8*Yb;
rTIA = rSIA + rDIA;

rTII = 800*Fc;

F1 = figure();
subplot(411)
plot(t, Fc)
xlim([-.25 .5])
title('static fiber force')

subplot(412)
plot(t, Fb)
xlim([-.25 .5])
title('dynamic fiber force')

subplot(413)
plot(t, Yb)
xlim([-.25 .5])
title('dynamic fiber yank')

subplot(414)
plot(t, CBm.length.bag, t, CBm.length.chain)
xlim([-.25 .5])
title('length')


F2 = figure();
subplot(211)
plot(IAdata.procdata.spiketimes - .075, IAdata.procdata.ifr, '.k')
hold on
plot(t, rTIA)
ylim([0 600])
xlim([-.25 .5])

subplot(212)
plot(IIdata.procdata.spiketimes - .075, IIdata.procdata.ifr, '.k')
hold on
plot(t, rTII)
ylim([0 200])
xlim([-.25 .5])

saveas(F1, [savedir filesep 'CBforces.eps'], 'epsc')
saveas(F1, [savedir filesep 'CBforces.jpg'], 'jpeg')
saveas(F2, [savedir filesep 'CBfits.eps'], 'epsc')
saveas(F1, [savedir filesep 'CBfits.jpg'], 'jpeg')
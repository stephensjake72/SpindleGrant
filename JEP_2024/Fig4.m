clc; clear; close all
addpath(genpath('Functions'))

load('spikesignals.mat')

%% Fig 4A
close all

n = 5; % number of sims
ns = 3; % velocity match number

spindleK = [Cia; Cii];
spindleKinv = spindleK^-1;

% overall model: y = cR

% get scaling factors to scale responses from 0 to 1
spindleF = spindleKinv(1, :)*[S(1).s1'; S(1).s2']; % use Kinv values to get the extremes
spindledF = spindleKinv(2, :)*[S(1).s1'; S(1).s2'];

sf1 = 1/max(spindleF);
sf2 = 1/max(spindledF);

% create vectors for c1 and c2
c0 = spindleKinv(1, :)*sf1; % starting c vector, force alone
cn = spindleKinv(2, :)*sf2; % ending c vector, yank alone

c1 = linspace(c0(1), cn(1), n);
c2 = linspace(c0(end), cn(end), n);

% y1 = 2*[c1(1) c2(1)]*[s1'; s2'];
% y2 = [c1(end) c2(end)]*[s1'; s2']/16;
% 
% subplot(211)
% plot(time, y1)
% subplot(212)
% plot(time, y2)

figure('Position', [0 600 1200 300])
figure(1)
plotnum = 1;
for p = 1:n
    % for q = 1:n
        y = [c1(p) c2(p)]*[S(ns).s1'; S(ns).s2'];

        subplot(1, n, plotnum)
        plot(S(ns).time, y)
        xlim([-0.1 1.5])
        ylim([0 1.2])
        title(num2str([c1(p); c2(p)]))

        plotnum = plotnum + 1;
    % end
end
print('/Users/jacobstephens/Documents/Figures/Multimodal paper/Fig4A', '-depsc', '-painters')

%% Fib 4B, simulating gamma

% case 1, activation of gamma dynamic ////////////////////////

% first take the original contractile yank
trialyank = S(ns).iadata.fit.Yc;
trialyank = interp1(S(ns).iadata.fit.time, trialyank, S(ns).time);
trialyank(trialyank < 0) = 0; % half-wave rectify
% do the same for force
trialforce = S(ns).iadata.fit.Fc;
trialforce = interp1(S(ns).iadata.fit.time, trialforce, S(ns).time);

% use the yank to simulate the activation of a g_dynamic on the Ia
gd_act = 25; % scaling factor for gamma signal
gd_s1 = S(ns).s1 + gd_act*trialyank';

% do the same for g_static
gs_act = 100;
gs_s1 = S(ns).s1 + gs_act*trialforce';

% plot to check
% subplot(211) % check 1, the interpolated yank matches the original
% plot(S(ns).iadata.fit.time, S(ns).iadata.fit.Yc)
% hold on
% plot(S(ns).time, trialyank)
% subplot(212) % check 2, the modeled signal looks similar to gamma act
% plot(S(ns).time, S(ns).s1)
% hold on
% plot(S(ns).time, g_s1)

figure('Position', [0 300 450 300])
figure(2)
subplot(2, 2, [1 2])
plot(S(ns).iadata.fit.time, S(ns).iadata.fit.Fcomp, 'Color', [.75 .75 .75])
hold on
plot(S(ns).iadata.fit.time, S(ns).iadata.fit.Ycomp, 'Color', [.75 .75 .75])
plot(S(ns).iadata.fit.time, S(ns).iadata.fit.predictor, 'Color', 'b')
plot(S(ns).iadata.procdata.spiketimes, S(ns).iadata.procdata.ifr, '.k')
xlim([-.1 1.5])
ax = gca;
title('Ia model')

subplot(2, 2, 3)
plot(S(ns).time, S(ns).s1, 'Color', 'b')
hold on
plot(S(ns).time, gd_s1, 'Color', 'r')
xlim(ax.XAxis.Limits)
ylim([0 600])
title('\gamma_d')

subplot(2, 2, 4)
plot(S(ns).time, S(ns).s1, 'Color', 'b')
hold on
plot(S(ns).time, gs_s1, 'Color', 'r')
xlim(ax.XAxis.Limits)
ylim([0 600])
title('\gamma_s')
print('/Users/jacobstephens/Documents/Figures/Multimodal paper/Fig4B', '-depsc', '-painters')

%% Fig 4C, response w gamma
ny = 4

% simulate a mn with gamma
y0 = [c1(ny) c2(ny)]*[S(ns).s1'; S(ns).s2'];
yd = [c1(ny) c2(ny)]*[gd_s1'; S(ns).s2'];
ys = [c1(ny) c2(ny)]*[gs_s1'; S(ns).s2'];

figure('Position', [600 300 350 300])
figure(3)
subplot(211)
plot(S(ns).time, y0, 'Color', 'b')
hold on
plot(S(ns).time, yd, 'Color', 'r')
xlim(ax.XAxis.Limits)
title('response w \gamma_d')

subplot(212)
plot(S(ns).time, y0, 'Color', 'b')
hold on
plot(S(ns).time, ys, 'Color', 'r')
ylim([0 1])
xlim(ax.XAxis.Limits)
title('response w \gamma_s')

print('/Users/jacobstephens/Documents/Figures/Multimodal paper/Fig4C', '-depsc', '-painters')

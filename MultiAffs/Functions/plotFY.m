function plotFY(data, fit, tstart)
figure('Position', [1100 0 800 800])
subplot(421)
plot(data.time, fit.Fmt)
yyaxis right
plot(data.time, fit.dFmt)
xlim([tstart max(data.spiketimes) + 1])
title('Force/Yank')
ax1 = gca;

subplot(422)
plot(data.time, fit.Fmt)
hold on
plot(data.time, fit. Fc)
xlim(ax1.XAxis.Limits)
title('MTU/C/NC Force')
legend({'MTU', 'C'}, 'Location', 'eastoutside')

subplot(423)
plot(data.time, fit.Fcomp, data.time, fit.Ycomp)
xlim(ax1.XAxis.Limits)
title('Force/Yank Components')

subplot(424)
plot(data.time, fit.dFmt)
hold on
plot(data.time, fit.Yc)
xlim(ax1.XAxis.Limits)
title('MTU/C/NC Yank')
legend({'MTU', 'C'}, 'Location', 'eastoutside')

subplot(425)
plot(data.spiketimes, data.ifr, '.k')
hold on
plot(data.time + fit.lambda, fit.predictor, 'r')
hold off
xlim(ax1.XAxis.Limits)
title('Model Fit')

subplot(426)
plot(fit.Lmt, fit.Fmt)
hold on
plot(fit.Lmt, fit.Fc)
title('Force/Length')
xlabel('L')
ylabel('F')
legend({'MTU', 'C'}, 'Location', 'eastoutside')

subplot(427)
stem(data.spiketimes, fit.resid, 'Marker', '.')
title('Residuals')
xlim(ax1.XAxis.Limits)

% subplot(428)
% plot(data.time, fit.Focclusion, data.time, fit.Yocclusion)
% xlim(ax1.XAxis.Limits)
% title('Occlusion')
% legend('F', 'Y')
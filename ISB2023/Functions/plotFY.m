function plotFY(data, fit, tstart)
figure('Position', [1100 0 800 800])
subplot(421)
plot(data.time, fit.F)
yyaxis right
plot(data.time, fit.Y)
xlim([tstart max(data.spiketimes) + 1])
title('Force/Yank')
ax1 = gca;

subplot(422)
plot(data.time, fit.F)
hold on
plot(data.time, fit.Fnc, 'Color', [.5 .5 .5])
plot(data.time, fit. Fc)
xlim(ax1.XAxis.Limits)
title('MTU/C/NC Force')
legend({'MTU', 'NC', 'C'}, 'Location', 'eastoutside')

subplot(423)
plot(data.time, fit.Fcomp, data.time, fit.Ycomp)
xlim(ax1.XAxis.Limits)
title('Force/Yank Components')

subplot(424)
plot(data.time, fit.Y)
hold on
plot(data.time, fit.Ync, 'Color', [.5 .5 .5])
plot(data.time, fit.Yc)
xlim(ax1.XAxis.Limits)
title('MTU/C/NC Yank')
legend({'MTU', 'NC', 'C'}, 'Location', 'eastoutside')

subplot(425)
plot(data.spiketimes, data.IFR, '.k')
hold on
plot(data.time + fit.lambda, fit.predictor, 'r')
hold off
xlim(ax1.XAxis.Limits)
title('Model Fit')

subplot(426)
plot(fit.L, fit.F)
hold on
plot(fit.L, fit.Fnc, 'Color', [.5 .5 .5])
plot(fit.L, fit.Fc)
title('Force/Length')
xlabel('L')
ylabel('F')
legend({'MTU', 'NC', 'C'}, 'Location', 'eastoutside')

subplot(427)
stem(data.spiketimes, fit.resid, 'Marker', '.')
title('Residuals')
xlim(ax1.XAxis.Limits)

subplot(428)
plot(data.time, fit.Focclusion, data.time, fit.Yocclusion)
xlim(ax1.XAxis.Limits)
title('Occlusion')
legend('F', 'Y')
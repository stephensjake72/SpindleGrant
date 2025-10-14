function plotLVA(data, fit, tstart)
figure('Position', [0 0 800 800])
subplot(511)
plot(data.time, fit.L - fit.L(1))
hold on
plot(data.time, fit.V)
yyaxis right
plot(data.time, fit.A)
hold off
title('L/V/A')
xlim([tstart max(data.time)])
ax1 = gca;

subplot(512)
plot(data.time, fit.Lcomp, data.time, fit.Vcomp, data.time, fit.Acomp)
xlim(ax1.XAxis.Limits)
title('L/V/A Components')

subplot(513)
plot(data.spiketimes, data.IFR, '.k')
hold on
plot(data.time + fit.lambda, fit.predictor, 'r')
hold off
xlim(ax1.XAxis.Limits)
title('Model Fit')

subplot(514)
stem(data.spiketimes, fit.resid, 'Marker', '.')
title('Residuals')
xlim(ax1.XAxis.Limits)

subplot(515)
plot(data.time, fit.Locclusion, data.time, fit.Vocclusion, data.time, fit.Aocclusion)
legend('L', 'V', 'A')
xlim(ax1.XAxis.Limits)
title('Occlusion')
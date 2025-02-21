function plotLVmodel(fit)
figure('Position', [100 100 800 500])

subplot(2, 4, [1 2])
hold on
plot(fit.time, fit.Lcomp, 'Color', [.75 .75 .75])
plot(fit.time, fit.Vcomp, 'Color', [.75 .75 .75])
plot(fit.time, fit.predictor, 'Color', [252,141,89]/255)
plot(fit.spiketimes, fit.ifr, '.k')
xlim([-.25 1.4])

subplot(2, 4, [5 6])
stem(fit.spiketimes, fit.resid, 'Marker', '.')
yline(0, '--')
xlim([-.25 1.4])

p_st = interp1(fit.time, fit.predictor, fit.spiketimes);

subplot(2, 4, [3 4 7 8])
hold on
plot(p_st, p_st, 'Color', [252,141,89]/255)
plot(p_st, fit.ifr, '.k')
xlabel('prediction')
ylabel('recorded ifr')
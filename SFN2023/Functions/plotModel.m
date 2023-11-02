function plotModel(fit)

figure

subplot(311)
plot(fit.spiketimes, fit.ifr, '.k')
hold on
plot(fit.time, fit.predictor, 'r')
hold off

subplot(312)
plot(fit.time, fit.Fcomp)
hold on
plot(fit.time, fit.Ycomp)
hold off

subplot(313)
plot(fit.time, fit.F, 'k')
hold on
plot(fit.time, fit.Fc, 'b')
plot(fit.time, fit.Fnc, 'Color', [.7 .7 .7])
hold off
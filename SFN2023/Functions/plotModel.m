function plotModel(fit)

fittextstr = {['kF = ' num2str(fit.kF)]; 
    ['kY = ' num2str(fit.kY)]};


figure

subplot(311)
plot(fit.time, fit.Fcomp, 'b')
hold on
plot(fit.time, fit.Ycomp, 'Color', [0.8500 0.3250 0.0980])

subplot(312)
plot(fit.time, fit.predictor, 'r')
hold on
plot(fit.spiketimes, fit.ifr, '.k')
hold off
title(fittextstr)

x = interp1(fit.time, fit.predictor, fit.spiketimes);
subplot(313)
plot(x, x, 'r')
hold on
plot(x, fit.ifr, '.k')
hold off
title(num2str(fit.R2))
function plotFYmodel(fit)

fittextstr = {['kF = ' num2str(fit.kF)]; 
    ['kdF = ' num2str(fit.kdF)];
    ['L0 = ' num2str(fit.L0)]};
% 
% 
% figure

subplot(311)
plot(fit.time, fit.rF, 'b')
hold on
plot(fit.time, fit.rdF, 'Color', [0.8500 0.3250 0.0980])
plot(fit.time, fit.b*ones(size(fit.time)), 'g')

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
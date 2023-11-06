function plotModel(fit)

nctextstr = {['A = ' num2str(fit.A)];
    ['k_{exp} = ' num2str(fit.k_exp)];
    ['L_0 = ' num2str(fit.L0)];
    ['k_{lin} = ' num2str(fit.k_lin)]};

fittextstr = {['kF = ' num2str(fit.kF)]; 
    ['kY = ' num2str(fit.kY)]};


figure

subplot(321)
plot(fit.time, fit.F, 'k')
hold on
plot(fit.time, fit.Fnc, 'Color', [0.8500 0.3250 0.0980])
plot(fit.time, fit.Fc, 'Color', 'b')
title(nctextstr)

subplot(323)
plot(fit.time, fit.Y, 'k')
hold on
plot(fit.time, fit.Ync, 'Color', [0.8500 0.3250 0.0980])
plot(fit.time, fit.Yc, 'Color', 'b')

subplot(325)
plot(fit.L, fit.F, 'k')
hold on
plot(fit.L, fit.Fnc, 'Color', [.5 .5 .5])
plot(fit.L, fit.Fc, 'b')

subplot(322)
plot(fit.time, fit.Fcomp, 'b')
hold on
plot(fit.time, fit.Ycomp, 'Color', [0.8500 0.3250 0.0980])

subplot(324)
plot(fit.time, fit.predictor, 'r')
hold on
plot(fit.spiketimes, fit.ifr, '.k')
hold off
title(fittextstr)

x = interp1(fit.time, fit.predictor, fit.spiketimes);
subplot(326)
plot(x, x, 'r')
hold on
plot(x, fit.ifr, '.k')
hold off
title(num2str(fit.R2))
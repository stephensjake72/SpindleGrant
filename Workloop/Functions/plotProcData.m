function plotProcData(procdata, opt)
% Lmt and derivs
subplot(431)
plot(procdata.time, procdata.Lmt)
ylabel('L_{MTU}')
ax = gca;
subplot(432)
plot(procdata.time, procdata.dLmt)
ylabel('v_{MTU}')
subplot(433)
plot(procdata.time, procdata.ddLmt)
ylabel('v_{MTU}')

% Fmt and deriv
subplot(434)
plot(procdata.time, procdata.Fmt)
ylabel('F_{MTU}')
subplot(435)
plot(procdata.time, procdata.dFmt)
ylabel('Y_{MTU}')

% Lf and deriv if it's there
if strcmp(opt, 'sonos')
    subplot(437)
    plot(procdata.time, procdata.Lf)
    ylabel('L_{fas}')
    subplot(438)
    plot(procdata.time, procdata.dLf)
    ylabel('v_{fas}')
end

% ifr
subplot(4, 3, 10)
plot(procdata.spiketimes, procdata.ifr, '.k')
xlim(ax.XAxis.Limits)
xlabel('time')
ylabel('IFR')
clc
clear
close all
addpath(genpath('Functions'))

% Load data files
path = '\\cosmic.bme.emory.edu\labs\ting\shared_ting\Jake\other\procdata';

D = dir(path);
D = D(3:end);

%%
close all
for ii = 1:numel(D)
    if ~contains(D(ii).name, 'workloop')
        continue
    end
    data = load([D(ii).folder filesep D(ii).name]);
    
    x1 = data.procdata.Lf;
%     x1 = x1/(max(x1) - min(x1));
    y1 = data.procdata.Fmt;
%     y1 = y1/(max(y1) - min(y1));
    x2 = interp1(data.procdata.time, x1, data.procdata.spiketimes);
    y2 = data.procdata.ifr;
    y3 = interp1(data.procdata.time, y1, data.procdata.spiketimes);
    
    figure
    hold on
    subplot(311)
    plot(data.procdata.time, x1)
    ax = gca;
    subplot(312)
    plot(data.procdata.spiketimes, data.procdata.ifr, '.k')
    xlim(ax.XAxis.Limits)
    subplot(313)
    plot(x1, y1, 'k')
    hold on
    plot(x2, y3, '.g')
    sgtitle([num2str(ii) data.parameters.aff])
%     switch data.parameters.aff
%         case 'IA'
%             subplot(412)
%             hold on
%             plot(x2, y3, '.b')
%         case 'II'
%             subplot(413)
%             hold on
%             plot(x2, y3, '.g')
%         case 'IB'
%             subplot(414)
%             hold on
%             plot(x2, y3, '.r')
%     end
end

% IB's: 168, 167, 166 168 best
% IA's: 131 130 129 128 55
% II's: 100 99 98 97 12 11
% 168, 167 166, 131, 130
%% make IB video
close all
k = 184;
data = load([D(k).folder filesep D(k).name]);

v = VideoWriter('C:\Users\Jake\Documents\Data\AffLoopIB', 'MPEG-4');
open(v)

x1 = data.procdata.Lf;
y1 = data.procdata.Fmt;
x2 = interp1(data.procdata.time, x1, data.procdata.spiketimes);
y2 = interp1(data.procdata.time, y1, data.procdata.spiketimes);


figure('Position', [500 500 1200 500])
subplot(421)
plot(data.procdata.time, data.procdata.Lmt, 'Color', [8,81,156]/255)
hold on
h1 = xline(0);
xlim([0 8])
xlabel('time')
ylabel('\Delta L_{MTU}')
subplot(423)
plot(data.procdata.time, data.procdata.Lf, 'Color', [8,81,156]/255)
hold on
h2 = xline(0);
xlim([0 8])
xlabel('time')
ylabel('\Delta L_{FAS}')
subplot(425)
plot(data.procdata.time, data.procdata.Fmt, 'Color', [8,81,156]/255)
hold on
h3 = xline(0);
xlim([0 8])
xlabel('time')
ylabel('F_{MTU}')
ax = gca;
subplot(427)
plot(data.procdata.spiketimes, data.procdata.ifr, 'Marker', '.', 'LineStyle', 'none', 'Color', [49,130,189]/255)
hold on
h4 = xline(0);
xlim([0 8])
xlim(ax.XAxis.Limits)
xlabel('time')
ylabel('IFR')

hold off

subplot(4, 2, [2 4 6 8])
xlabel('\Delta L_{FAS}')
ylabel('F_{MTU}')
xlabel('\Delta L_{FAS}')
ylabel('F_{MTU}')

for it = 10:5:numel(data.procdata.time)
    subplot(421)
    h1.Value = data.procdata.time(it);
    subplot(423)
    h2.Value = data.procdata.time(it);
    subplot(425)
    h3.Value = data.procdata.time(it);
    subplot(427)
    h4.Value = data.procdata.time(it);
    
    subplot(4, 2, [2 4 6 8])
    plot(x1(1:it), y1(1:it), 'Color', [.8 .8 .8])
    hold on
    plot(x1(it), y1(it), 'ok')
    plot(x2(data.procdata.spiketimes < data.procdata.time(it)), ...
        y2(data.procdata.spiketimes < data.procdata.time(it)), '.b')
    if ~isempty(x2(data.procdata.spiketimes < data.procdata.time(it)))
        legend('', '', 'spikes')
    else
        legend('')
    end
    hold off
    xlim([-4 1])
    ylim([-2 12])
    xlabel('\Delta L_{FAS}')
    ylabel('F_{MTU}')
    xlabel('\Delta L_{FAS}')
    ylabel('F_{MTU}')
    sgtitle('IB')
    
    frame = getframe(gcf);
    writeVideo(v, frame);
end
close(v)
%% IA video
close all
k = 145;
data = load([D(k).folder filesep D(k).name]);

v = VideoWriter('C:\Users\Jake\Documents\Data\AffLoopIA', 'MPEG-4');
open(v)

x1 = data.procdata.Lf;
y1 = data.procdata.Fmt;
x2 = interp1(data.procdata.time, x1, data.procdata.spiketimes);
y2 = interp1(data.procdata.time, y1, data.procdata.spiketimes);


figure('Position', [500 500 1200 500])
subplot(421)
plot(data.procdata.time, data.procdata.Lmt, 'Color', [165,15,21]/255)
hold on
h1 = xline(0);
xlim([0 8])
xlabel('time')
ylabel('\Delta L_{MTU}')
subplot(423)
plot(data.procdata.time, data.procdata.Lf, 'Color', [165,15,21]/255)
hold on
h2 = xline(0);
xlim([0 8])
xlabel('time')
ylabel('\Delta L_{FAS}')
subplot(425)
plot(data.procdata.time, data.procdata.Fmt, 'Color', [165,15,21]/255)
hold on
h3 = xline(0);
xlim([0 8])
xlabel('time')
ylabel('F_{MTU}')
ax = gca;
subplot(427)
plot(data.procdata.spiketimes, data.procdata.ifr, 'Marker', '.', 'LineStyle', 'none', 'Color', [222,45,38]/255)
hold on
h4 = xline(0);
xlim([0 8])
xlim(ax.XAxis.Limits)
xlabel('time')
ylabel('IFR')

sgtitle('IA')

hold off

subplot(4, 2, [2 4 6 8])
xlabel('\Delta L_{FAS}')
ylabel('F_{MTU}')
xlabel('\Delta L_{FAS}')
ylabel('F_{MTU}')

for it = 10:5:numel(data.procdata.time)
    subplot(421)
    h1.Value = data.procdata.time(it);
    subplot(423)
    h2.Value = data.procdata.time(it);
    subplot(425)
    h3.Value = data.procdata.time(it);
    subplot(427)
    h4.Value = data.procdata.time(it);
    
    subplot(4, 2, [2 4 6 8])
    plot(x1(1:it), y1(1:it), 'Color', [.8 .8 .8])
    hold on
    plot(x1(it), y1(it), 'ok')
    plot(x2(data.procdata.spiketimes < data.procdata.time(it)), ...
        y2(data.procdata.spiketimes < data.procdata.time(it)), ...
        'Marker', '.', 'LineStyle', 'none', 'Color', [222,45,38]/255)
    if ~isempty(x2(data.procdata.spiketimes < data.procdata.time(it)))
        legend('', '', 'spikes')
    else
        legend('')
    end
    hold off
    xlim([-4 1])
    ylim([-2 12])
    xlabel('\Delta L_{FAS}')
    ylabel('F_{MTU}')
    xlabel('\Delta L_{FAS}')
    ylabel('F_{MTU}')
    
    frame = getframe(gcf);
    writeVideo(v, frame);
end
close(v)
%% II video
close all
k = 24;
data = load([D(k).folder filesep D(k).name]);

v = VideoWriter('C:\Users\Jake\Documents\Data\AffLoopII', 'MPEG-4');
open(v)

x1 = data.procdata.Lf;
y1 = data.procdata.Fmt;
x2 = interp1(data.procdata.time, x1, data.procdata.spiketimes);
y2 = interp1(data.procdata.time, y1, data.procdata.spiketimes);


figure('Position', [500 500 1200 500])
subplot(421)
plot(data.procdata.time, data.procdata.Lmt, 'Color', [0 109 44]/255)
hold on
h1 = xline(0);
xlim([0 max(data.procdata.time)])
xlabel('time')
ylabel('\Delta L_{MTU}')
subplot(423)
plot(data.procdata.time, data.procdata.Lf, 'Color', [0 109 44]/255)
hold on
h2 = xline(0);
xlim([0 max(data.procdata.time)])
xlabel('time')
ylabel('\Delta L_{FAS}')
subplot(425)
plot(data.procdata.time, data.procdata.Fmt, 'Color', [0 109 44]/255)
hold on
h3 = xline(0);
xlim([0 max(data.procdata.time)])
xlabel('time')
ylabel('F_{MTU}')
ax = gca;
subplot(427)
plot(data.procdata.spiketimes, data.procdata.ifr, 'Marker', '.', 'LineStyle', 'none', 'Color', [44,162,95]/255)
hold on
h4 = xline(0);
xlim([0 max(data.procdata.time)])
xlim(ax.XAxis.Limits)
xlabel('time')
ylabel('IFR')

sgtitle('II')

hold off

for it = 10:5:numel(data.procdata.time)
    subplot(421)
    h1.Value = data.procdata.time(it);
    subplot(423)
    h2.Value = data.procdata.time(it);
    subplot(425)
    h3.Value = data.procdata.time(it);
    subplot(427)
    h4.Value = data.procdata.time(it);
    
    subplot(4, 2, [2 4 6 8])
    plot(x1(1:it), y1(1:it), 'Color', [.8 .8 .8])
    hold on
    plot(x1(it), y1(it), 'ok')
    plot(x2(data.procdata.spiketimes < data.procdata.time(it)), ...
        y2(data.procdata.spiketimes < data.procdata.time(it)), ...
        'Marker', '.', 'LineStyle', 'none', 'Color', [44,162,95]/255)
    if ~isempty(x2(data.procdata.spiketimes < data.procdata.time(it)))
        legend('', '', 'spikes')
    else
        legend('')
    end
    hold off
    xlim([-2.5 2])
    ylim([0 5])
    xlabel('\Delta L_{FAS}')
    ylabel('F_{MTU}')
    xlabel('\Delta L_{FAS}')
    ylabel('F_{MTU}')
    
    frame = getframe(gcf);
    writeVideo(v, frame);
end
close(v)

%%
ibdata = load([D(184).folder filesep D(184).name]);
iadata = load([D(145).folder filesep D(145).name]);


v = VideoWriter('C:\Users\Jake\Documents\Data\AffLoopIA_IB', 'MPEG-4');
open(v)

x1 = ibdata.procdata.Lf;
x1 = x1 - min(x1);
x1 = x1/max(x1);
x2 = iadata.procdata.Lf;
x2 = x2 - min(x2);
x2 = x2/max(x2);
y1 = ibdata.procdata.Fmt;
y2 = iadata.procdata.Fmt;

x1s = interp1(ibdata.procdata.time, x1, ibdata.procdata.spiketimes);
x2s = interp1(iadata.procdata.time, x2, iadata.procdata.spiketimes);
y1s = interp1(ibdata.procdata.time, y1, ibdata.procdata.spiketimes);
y2s = interp1(iadata.procdata.time, y2, iadata.procdata.spiketimes);

ibst = ibdata.procdata.spiketimes;
iast = iadata.procdata.spiketimes;

% x1 = data.procdata.Lf;
% y1 = data.procdata.Fmt;
% x2 = interp1(data.procdata.time, x1, data.procdata.spiketimes);
% y2 = interp1(data.procdata.time, y1, data.procdata.spiketimes);

figure('Position', [500 500 1200 500])
subplot(521)
plot(ibdata.procdata.time, ibdata.procdata.Lmt, 'k')
hold on
h1 = xline(0);
xlim([0 8])
xlabel('time')
ylabel('\Delta L_{MTU}')
subplot(523)
plot(iadata.procdata.time, iadata.procdata.Lf, 'Color', [165,15,21]/255)
hold on
plot(ibdata.procdata.time, ibdata.procdata.Lf, 'Color', [8,81,156]/255)
h2 = xline(0);
xlim([0 8])
xlabel('time')
ylabel('\Delta L_{FAS}')
subplot(525)
plot(iadata.procdata.time, iadata.procdata.Fmt, 'Color', [165,15,21]/255)
hold on
plot(ibdata.procdata.time, ibdata.procdata.Fmt, 'Color', [8,81,156]/255)
h3 = xline(0);
xlim([0 8])
xlabel('time')
ylabel('F_{MTU}')
ax = gca;
subplot(527)
plot(iadata.procdata.spiketimes, iadata.procdata.ifr, 'Marker', '.', 'LineStyle', 'none', 'Color', [222,45,38]/255)
hold on
h4 = xline(0);
xlim([0 8])
xlim(ax.XAxis.Limits)
xlabel('time')
ylabel('IFR')
legend('IA')
subplot(529)
plot(ibdata.procdata.spiketimes, ibdata.procdata.ifr, 'Marker', '.', 'LineStyle', 'none', 'Color', [49,130,189]/255)
hold on
h5 = xline(0);
xlim(ax.XAxis.Limits)
xlabel('time')
ylabel('IFR')
legend('IB')
 
for it = 10:5:numel(ibdata.procdata.time)
    
    tstop = ibdata.procdata.time(it);
    
    subplot(521)
    h1.Value = tstop;
    subplot(523)
    h2.Value = tstop;
    subplot(525)
    h3.Value = tstop;
    subplot(527)
    h4.Value = tstop;
    subplot(529)
    h5.Value = tstop;
    
    subplot(5, 2, [2 4 6 8 10])
    plot(x1(1:it), y1(1:it), 'Color', [.8 .8 .8])
    hold on
    plot(x2(1:it), y2(1:it), 'Color', [.8 .8 .8])
    plot(x1(it), y1(it), 'ok')
    plot(x2(it), y2(it), 'ok')
    plot(x1s(ibst < tstop), y1s(ibst < tstop), 'Marker', '.', 'LineStyle', 'none', 'Color', [49,130,189]/255)
    plot(x2s(iast < tstop), y2s(iast < tstop), 'Marker', '.', 'LineStyle', 'none', 'Color', [222,45,38]/255)
    hold off
    xlim([0 1])
    ylim([-1 12])
    xlabel('\Delta L_{FAS} (%max)')
    ylabel('F_{MTU}')
    
    frame = getframe(gcf);
    writeVideo(v, frame);
end
close(v)

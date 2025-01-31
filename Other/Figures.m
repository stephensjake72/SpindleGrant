clc
clear
close all
addpath(genpath('Functions'))

% Load data files
% path = '\\cosmic.bme.emory.edu\labs\ting\shared_ting\Jake\other\procdata';
path = '/Volumes/labs/ting/shared_ting/Jake/other/procdata';
% var = uigetdir(path)
%%
D = dir(path);
D = D(3:end);

savepath = '/Users/jacobstephens/Documents/workloopFigs';
if ~exist(savepath, 'dir')
    mkdir(savepath)
end


% %%
% close all
% for ii = 1:numel(D)
%     if ~contains(D(ii).name, 'workloop')
%         continue
%     end
    % data = load([D(ii).folder filesep D(ii).name]);
    % 
    % x1 = data.procdata.Lf;
    % x1 = x1/(max(x1) - min(x1));
    % y1 = data.procdata.Fmt;
    % y1 = y1/(max(y1) - min(y1));
    % x2 = interp1(data.procdata.time, x1, data.procdata.spiketimes);
    % y2 = data.procdata.ifr;
    % y3 = interp1(data.procdata.time, y1, data.procdata.spiketimes);
    % 
    % figure
    % hold on
    % subplot(311)
    % plot(data.procdata.time, x1)
    % ax = gca;
    % subplot(312)
    % plot(data.procdata.spiketimes, data.procdata.ifr, '.k')
    % xlim(ax.XAxis.Limits)
    % subplot(313)
    % plot(x1, y1, 'k')
    % hold on
    % plot(x2, y3, '.g')
    % sgtitle([num2str(ii) data.parameters.aff])
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
% end

% IB's: 168, 167, 166 168 best
% IA's: 131 130 129 128 55
% II's: 100 99 98 97 12 11
% 168, 167 166, 131, 130
%% make IB Fmt vs Lf video
close all
% selected file - A18042-20-30_cell_5_IB_workloop_571s.mat
ibk = 200;
data = load([D(ibk).folder filesep D(ibk).name]);

% v = VideoWriter([savepath filesep 'AffLoopIB_Lf'], 'MPEG-4');
% open(v)

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
%%
close
f = imshow(frame.cdata);
print([savepath filesep 'AffLoopIB_Lf'], '-depsc2')
print([savepath filesep 'AffLoopIB_Lf'], '-djpeg')
%% make IB Fmt vs Lmt video
close all
data = load([D(ibk).folder filesep D(ibk).name]);

v = VideoWriter([savepath filesep 'AffLoopIB_Lmt'], 'MPEG-4');
open(v)

x1 = data.procdata.Lmt;
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
    xlim([.5 3.5])
    ylim([-2 12])
    xlabel('\Delta L_{MTU}')
    ylabel('F_{MTU}')
    sgtitle('IB')
    
    frame = getframe(gcf);
    writeVideo(v, frame);
end
close(v)

close
f = imshow(frame.cdata);
print([savepath filesep 'AffLoopIB_Lmt'], '-depsc2')
print([savepath filesep 'AffLoopIB_Lmt'], '-djpeg')
%% IA Fmt vs Lf video
close all
% selected file- A18042-20-26_cell_3_IA_workloop_239s
iak = 156;
data = load([D(iak).folder filesep D(iak).name]);

v = VideoWriter([savepath filesep 'AffLoopIA_Lf'], 'MPEG-4');
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

% for it = 10:5:numel(data.procdata.time)
%     subplot(421)
%     h1.Value = data.procdata.time(it);
%     subplot(423)
%     h2.Value = data.procdata.time(it);
%     subplot(425)
%     h3.Value = data.procdata.time(it);
%     subplot(427)
%     h4.Value = data.procdata.time(it);
% 
%     subplot(4, 2, [2 4 6 8])
%     plot(x1(1:it), y1(1:it), 'Color', [.8 .8 .8])
%     hold on
%     plot(x1(it), y1(it), 'ok')
%     plot(x2(data.procdata.spiketimes < data.procdata.time(it)), ...
%         y2(data.procdata.spiketimes < data.procdata.time(it)), ...
%         'Marker', '.', 'LineStyle', 'none', 'Color', [222,45,38]/255)
%     if ~isempty(x2(data.procdata.spiketimes < data.procdata.time(it)))
%         legend('', '', 'spikes')
%     else
%         legend('')
%     end
%     hold off
%     xlim([-4 1])
%     ylim([-2 12])
%     xlabel('\Delta L_{FAS}')
%     ylabel('F_{MTU}')
%     xlabel('\Delta L_{FAS}')
%     ylabel('F_{MTU}')
% 
%     frame = getframe(gcf);
%     writeVideo(v, frame);
% end
% close(v)
% 
% close
f = imshow(frame.cdata);
print([savepath filesep 'AffLoopIA_Lf'], '-depsc2')
print([savepath filesep 'AffLoopIA_Lf'], '-djpeg')
%% IA Fmt vs Lmt video
close all
% k = 145;
data = load([D(iak).folder filesep D(iak).name]);

% generate standalone workloop figures
timewin = data.procdata.time < 3.4 | data.procdata.time > 5.4;
subplot(121)
hold on
plot(data.procdata.Lmt(~timewin), data.procdata.Fmt(~timewin), 'Color', [65 171 93]/255, 'LineWidth', 1)
plot(data.procdata.Lmt(timewin), data.procdata.Fmt(timewin), 'Color', [8 104 172]/255, 'LineWidth', 1)
legend({'active', 'passive'})
xlabel('\Delta L_{MTU}'); ylabel('F_{MTU}')

timewin = data.procdata.time < 3.4 | data.procdata.time > 5.4;
subplot(122)
hold on
plot(data.procdata.Lf(~timewin), data.procdata.Fmt(~timewin), 'Color', [65 171 93]/255, 'LineWidth', 1)
plot(data.procdata.Lf(timewin), data.procdata.Fmt(timewin), 'Color', [8 104 172]/255, 'LineWidth', 1)
legend({'active', 'passive'})
xlabel('\Delta L_{FAS}'); ylabel('F_{MTU}')

%%
v = VideoWriter([savepath filesep 'AffLoopIA_Lmt'], 'MPEG-4');
open(v)

x1 = data.procdata.Lmt;
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
    xlim([.5 3.5])
    ylim([-2 12])
    xlabel('\Delta L_{MTU}')
    ylabel('F_{MTU}')
    
    frame = getframe(gcf);
    writeVideo(v, frame);
end
close(v)

close
f = imshow(frame.cdata);
print([savepath filesep 'AffLoopIA_Lmt'], '-depsc2')
print([savepath filesep 'AffLoopIA_Lmt'], '-djpeg')
%% II video
% close all
% k = 50;
% data = load([D(k).folder filesep D(k).name]);
% 
% % v = VideoWriter('C:\Users\Jake\Documents\Data\AffLoopII', 'MPEG-4');
% % open(v)
% 
% x1 = data.procdata.Lf;
% y1 = data.procdata.Fmt;
% x2 = interp1(data.procdata.time, x1, data.procdata.spiketimes);
% y2 = interp1(data.procdata.time, y1, data.procdata.spiketimes);
% 
% 
% figure('Position', [500 500 1200 500])
% subplot(421)
% plot(data.procdata.time, data.procdata.Lmt, 'Color', [0 109 44]/255)
% hold on
% h1 = xline(0);
% xlim([0 max(data.procdata.time)])
% xlabel('time')
% ylabel('\Delta L_{MTU}')
% subplot(423)
% plot(data.procdata.time, data.procdata.Lf, 'Color', [0 109 44]/255)
% hold on
% h2 = xline(0);
% xlim([0 max(data.procdata.time)])
% xlabel('time')
% ylabel('\Delta L_{FAS}')
% subplot(425)
% plot(data.procdata.time, data.procdata.Fmt, 'Color', [0 109 44]/255)
% hold on
% h3 = xline(0);
% xlim([0 max(data.procdata.time)])
% xlabel('time')
% ylabel('F_{MTU}')
% ax = gca;
% subplot(427)
% plot(data.procdata.spiketimes, data.procdata.ifr, 'Marker', '.', 'LineStyle', 'none', 'Color', [44,162,95]/255)
% hold on
% h4 = xline(0);
% xlim([0 max(data.procdata.time)])
% xlim(ax.XAxis.Limits)
% xlabel('time')
% ylabel('IFR')
% 
% sgtitle('II')
% 
% hold off
% 
% for it = 10:5:numel(data.procdata.time)
%     subplot(421)
%     h1.Value = data.procdata.time(it);
%     subplot(423)
%     h2.Value = data.procdata.time(it);
%     subplot(425)
%     h3.Value = data.procdata.time(it);
%     subplot(427)
%     h4.Value = data.procdata.time(it);
% 
%     subplot(4, 2, [2 4 6 8])
%     plot(x1(1:it), y1(1:it), 'Color', [.8 .8 .8])
%     hold on
%     plot(x1(it), y1(it), 'ok')
%     plot(x2(data.procdata.spiketimes < data.procdata.time(it)), ...
%         y2(data.procdata.spiketimes < data.procdata.time(it)), ...
%         'Marker', '.', 'LineStyle', 'none', 'Color', [44,162,95]/255)
%     if ~isempty(x2(data.procdata.spiketimes < data.procdata.time(it)))
%         legend('', '', 'spikes')
%     else
%         legend('')
%     end
%     hold off
%     xlim([-2.5 2])
%     ylim([0 5])
%     xlabel('\Delta L_{FAS}')
%     ylabel('F_{MTU}')
%     xlabel('\Delta L_{FAS}')
%     ylabel('F_{MTU}')
% 
%     frame = getframe(gcf);
%     writeVideo(v, frame);
% end
% close(v)

%% IA/IB Fmt vs Lf Video
ibk = 200;
iak = 156;
ibdata = load([D(ibk).folder filesep D(ibk).name]);
iadata = load([D(iak).folder filesep D(iak).name]);


v = VideoWriter([savepath filesep 'AffLoopIA_IB_Lf'], 'MPEG-4');
open(v)

x1 = ibdata.procdata.Lf; % originally Lf
x1 = x1 - min(x1);
x1 = x1/max(x1);
x2 = iadata.procdata.Lf;
x2 = x2 - min(x2);
x2 = x2/max(x2);
y1 = ibdata.procdata.Fmt; %/max(ibdata.procdata.Fmt);
y2 = iadata.procdata.Fmt; %/max(iadata.procdata.Fmt);

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
 
for it = 1:5:numel(ibdata.procdata.time)
    
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

% close
% f = imshow(frame.cdata);
print([savepath filesep 'AffLoopIA_IB_Lf'], '-depsc2')
print([savepath filesep 'AffLoopIA_IB_Lf'], '-djpeg')
%% IA/IB Fmt vs Lmt Video
ibdata = load([D(ibk).folder filesep D(ibk).name]);
iadata = load([D(iak).folder filesep D(iak).name]);


v = VideoWriter([savepath filesep 'AffLoopIA_IB_Lmt'], 'MPEG-4');
open(v)

x1 = ibdata.procdata.Lmt; % originally Lf
x1 = x1 - min(x1);
% x1 = x1/max(x1);
x2 = iadata.procdata.Lmt;
x2 = x2 - min(x2);
% x2 = x2/max(x2);
y1 = ibdata.procdata.Fmt; %/max(ibdata.procdata.Fmt);
y2 = iadata.procdata.Fmt; %/max(iadata.procdata.Fmt);

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
plot(ibdata.procdata.time, x1, 'k')
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
    xlim([-.5 2.5])
    ylim([-1 12])
    xlabel('\Delta L_{MTU}')
    ylabel('F_{MTU}')
    
    frame = getframe(gcf);
    writeVideo(v, frame);
end
close(v)
%%
% close
f = imshow(frame.cdata);
%%
print([savepath filesep 'AffLoopIA_IB_Lmt'], '-depsc2')
print([savepath filesep 'AffLoopIA_IB_Lmt'], '-djpeg')
%%

figure('Position', [500 500 1000 800])
subplot(511)
plot(ibdata.procdata.time, x1, 'k')
hold on
h1 = xline(0);
xlim([3.4 5.4])
ax = gca;
xlabel('time')
ylabel('\Delta L_{MTU}')
subplot(512)
plot(iadata.procdata.time, iadata.procdata.Lf, 'Color', [165,15,21]/255)
hold on
plot(ibdata.procdata.time, ibdata.procdata.Lf, 'Color', [8,81,156]/255)
h2 = xline(0);
xlim(ax.XAxis.Limits)
xlabel('time')
ylabel('\Delta L_{FAS}')
subplot(513)
plot(iadata.procdata.time, iadata.procdata.Fmt, 'Color', [165,15,21]/255)
hold on
plot(ibdata.procdata.time, ibdata.procdata.Fmt, 'Color', [8,81,156]/255)
h3 = xline(0);
xlim(ax.XAxis.Limits)
xlabel('time')
ylabel('F_{MTU}')
ax = gca;
subplot(514)
plot(iadata.procdata.spiketimes, iadata.procdata.ifr, 'Marker', '.', 'LineStyle', 'none', 'Color', [222,45,38]/255)
hold on
h4 = xline(0);
xlim(ax.XAxis.Limits)
xlabel('time')
ylabel('IFR')
legend('IA')
subplot(515)
plot(ibdata.procdata.spiketimes, ibdata.procdata.ifr, 'Marker', '.', 'LineStyle', 'none', 'Color', [49,130,189]/255)
hold on
h5 = xline(0);
xlim(ax.XAxis.Limits)
xlabel('time')
ylabel('IFR')
legend('IB')

%% IA vs IB spike counts
close all

figure('Position', [500 500 1200 500])
subplot(411)
plot(ibdata.procdata.time, x1, 'k')
hold on
h1 = xline(0);
xlim([0 8])
xlabel('time')
ylabel('\Delta L_{MTU}')
subplot(412)
plot(iadata.procdata.time, iadata.procdata.Lf, 'Color', [165,15,21]/255)
hold on
plot(ibdata.procdata.time, ibdata.procdata.Lf, 'Color', [8,81,156]/255)
h2 = xline(0);
xlim([0 8])
xlabel('time')
ylabel('\Delta L_{FAS}')
subplot(413)
plot(iadata.procdata.time, iadata.procdata.Fmt, 'Color', [165,15,21]/255)
hold on
plot(ibdata.procdata.time, ibdata.procdata.Fmt, 'Color', [8,81,156]/255)
h3 = xline(0);
xlim([0 8])
xlabel('time')
ylabel('F_{MTU}')
ax = gca;


binwidth = .05;
bins = 0:binwidth:max(ibdata.procdata.time);
iasc = zeros(size(bins));
ibsc = zeros(size(bins));

for ii = 1:length(bins) - 1
    iasc(ii) = length(find(iadata.procdata.spiketimes > bins(ii) & iadata.procdata.spiketimes <= bins(ii+1)));
    ibsc(ii) = length(find(ibdata.procdata.spiketimes > bins(ii) & ibdata.procdata.spiketimes <= bins(ii+1)));
end

a = .6;
subplot(414)
b = bar(bins, iasc);
b.FaceColor = [165,15,21]/255;
b.FaceAlpha = a;
hold on
b2 = bar(bins, ibsc);
b2.FaceColor = [8,81,156]/255;
b2.FaceAlpha = a;
ylim([0 20])
legend({'IA', 'IB'})
xlabel('time')
ylabel('spike count')

print([savepath filesep 'AffLoopIA_IB_SC'], '-depsc2')
print([savepath filesep 'AffLoopIA_IB_SC'], '-djpeg')
%%
figure('Position', [500 500 1200 500])
subplot(411)
plot(ibdata.procdata.time, x1, 'k')
hold on
h1 = xline(0);
xlim([3.3 5.3])
xlabel('time')
ylabel('\Delta L_{MTU}')
ax = gca;
subplot(412)
plot(iadata.procdata.time, iadata.procdata.Lf, 'Color', [165,15,21]/255)
hold on
plot(ibdata.procdata.time, ibdata.procdata.Lf, 'Color', [8,81,156]/255)
h2 = xline(0);
xlim(ax.XAxis.Limits)
xlabel('time')
ylabel('\Delta L_{FAS}')
subplot(413)
plot(iadata.procdata.time, iadata.procdata.Fmt, 'Color', [165,15,21]/255)
hold on
plot(ibdata.procdata.time, ibdata.procdata.Fmt, 'Color', [8,81,156]/255)
h3 = xline(0);
xlim(ax.XAxis.Limits)
xlabel('time')
ylabel('F_{MTU}')

a = .6;
subplot(414)
plot(iadata.procdata.spiketimes, iadata.procdata.ifr, 'Marker', '.', ...
    'LineStyle', 'none', 'Color', [222,45,38]/255)
hold on
plot(ibdata.procdata.spiketimes, ibdata.procdata.ifr, 'Marker', '.', ...
    'LineStyle', 'none', 'Color', [49,130,189]/255)
% b = bar(bins, iasc);
% b.FaceColor = [165,15,21]/255;
% b.FaceAlpha = a;
% hold on
% b2 = bar(bins, ibsc);
% b2.FaceColor = [8,81,156]/255;
% b2.FaceAlpha = a;
xlim(ax.XAxis.Limits)
legend({'IA', 'IB'})
xlabel('time')
ylabel('spike count')
clc
clear
close all
addpath(genpath('Functions'))

% Load data files
% path = '\\cosmic.bme.emory.edu\labs\ting\shared_ting\Jake\other\procdata';
path = '/Volumes/labs/ting/shared_ting/Jake/other/procdata';

D = dir(path);
D = D(3:end);

savepath = '/Users/jacobstephens/Documents/SICBworkloopFigs';
if ~exist(savepath, 'dir')
    mkdir(savepath)
end

% create data structure
iafile = '26_cell_3';
iifile = '26_cell_2';
ibfile = '30_cell_5';
count = [1 1 1];

for n = 1:numel(D)
    if contains(D(n).name, iafile) && contains(D(n).name, 'workloop')
        iadata(count(1)) = load([D(n).folder filesep D(n).name]);
        count(1) = count(1) + 1;
    elseif contains(D(n).name, iifile) && contains(D(n).name, 'workloop')
        iidata(count(2)) = load([D(n).folder filesep D(n).name]);
        count(2) = count(2) + 1;
    elseif contains(D(n).name, ibfile) && contains(D(n).name, 'workloop')
        ibdata(count(3)) = load([D(n).folder filesep D(n).name]);
        count(3) = count(3) + 1;
    end
end
%% Fig 2, time series
close all

nia = 2;
nii = 4;
nib = 4;
figure
subplot(421)
plot(iadata(nia).procdata.time, iadata(nia).procdata.Lmt - iadata(nia).procdata.Lmt(1), 'k')
xlim([0 8])
ax = gca;
ylabel('\Delta L_{MTU} (mm)')

subplot(423)
plot(iadata(nia).procdata.time, iadata(nia).procdata.Lf, 'Color', [31,120,180]/255)
hold on
plot(ibdata(nib).procdata.time, ibdata(nib).procdata.Lf, 'Color', [227,26,28]/255)
xlim(ax.XAxis.Limits)
ylabel('\Delta L_{MUS} (mm)')

subplot(425)
plot(iadata(nia).procdata.time, iadata(nia).procdata.Fmt, 'Color', [31,120,180]/255)
hold on
plot(ibdata(nib).procdata.time, ibdata(nib).procdata.Fmt, 'Color', [227,26,28]/255)
xlim(ax.XAxis.Limits)
ylabel('F_{MTU} (N)')

subplot(427)
plot(iadata(nia).procdata.spiketimes, iadata(nia).procdata.ifr, ...
    'Marker', '.', 'LineStyle', 'none', 'Color', [31,120,180]/255)
hold on
plot(ibdata(nib).procdata.spiketimes, ibdata(nib).procdata.ifr, ...
    'Marker', '.', 'LineStyle', 'none', 'Color', [227,26,28]/255)
xlim(ax.XAxis.Limits)
ylabel('IFR (pps)')

subplot(424)
plot(iadata(nia).procdata.time, iadata(nia).procdata.Lf, 'Color', [31,120,180]/255)
hold on
plot(ibdata(nib).procdata.time, ibdata(nib).procdata.Lf, 'Color', [227,26,28]/255)
xlim([3 4.3])

subplot(426)
plot(iadata(nia).procdata.time, iadata(nia).procdata.Fmt, 'Color', [31,120,180]/255)
hold on
plot(ibdata(nib).procdata.time, ibdata(nib).procdata.Fmt, 'Color', [227,26,28]/255)
xlim([3 4.3])

subplot(428)
plot(iadata(nia).procdata.spiketimes, iadata(nia).procdata.ifr, ...
    'Marker', '.', 'LineStyle', 'none', 'Color', [31,120,180]/255)
hold on
plot(ibdata(nib).procdata.spiketimes, ibdata(nib).procdata.ifr, ...
    'Marker', '.', 'LineStyle', 'none', 'Color', [227,26,28]/255)
xlim([3 4.3])

print([savepath filesep 'SICB_2_2A'], '-depsc2')

%% workloops//////////////////////////////////////////////////////////////
close all

nia = 2;
nib = 4;

xia = interp1(iadata(nia).procdata.time, iadata(nia).procdata.Lmt, iadata(nia).procdata.spiketimes);
yia = interp1(iadata(nia).procdata.time, iadata(nia).procdata.Fmt, iadata(nia).procdata.spiketimes);
xib = interp1(ibdata(nib).procdata.time, ibdata(nib).procdata.Lmt, ibdata(nib).procdata.spiketimes);
yib = interp1(ibdata(nib).procdata.time, ibdata(nib).procdata.Fmt, ibdata(nib).procdata.spiketimes);

xia = xia - iadata(nia).procdata.Lmt(1);
xib = xib - ibdata(nib).procdata.Lmt(1);

figure('Position', [100 100 400 800])
% subplot(311)
% plot(iadata(nia).procdata.time, ...
%     iadata(nia).procdata.Fmt)
% hold on
% plot(ibdata(nib).procdata.time, ...
%     ibdata(nib).procdata.Fmt)
% xlim([0 8])

% subplot(3, 1, [2 3])
subplot(211)
plot(iadata(nia).procdata.Lmt - iadata(nia).procdata.Lmt(1), ...
    iadata(nia).procdata.Fmt, 'Color', [.75 .75 .75])
hold on
plot(xia, yia, 'Marker', '.', 'LineStyle', 'none', 'Color', [31,120,180]/255)
ylabel('F_{MTU}')

subplot(212)
hold on
plot(ibdata(nib).procdata.Lmt - ibdata(nib).procdata.Lmt(1), ...
    ibdata(nib).procdata.Fmt, 'Color', [.75 .75 .75])
plot(xib, yib, 'Marker', '.', 'LineStyle', 'none', 'Color', [227,26,28]/255)
xlabel('\Delta L_{MTU}')
ylabel('F_{MTU}')
xlim([-1 1])

print([savepath filesep 'SICB_2_2B'], '-depsc2')
%%
% /////////////////////////////////////////////////////////////////
close all

nia = 3;
nib = 3;

figure
subplot(421)
plot(iadata(nia).procdata.time, iadata(nia).procdata.Lmt - iadata(nia).procdata.Lmt(1), 'k')
xlim([0 8])
ax = gca;
ylabel('\Delta L_{MTU} (mm)')

subplot(423)
plot(iadata(nia).procdata.time, iadata(nia).procdata.Lf, 'Color', [31,120,180]/255)
hold on
plot(ibdata(nib).procdata.time, ibdata(nib).procdata.Lf, 'Color', [227,26,28]/255)
xlim(ax.XAxis.Limits)
ylabel('\Delta L_{MUS} (mm)')

subplot(425)
plot(iadata(nia).procdata.time, iadata(nia).procdata.Fmt, 'Color', [31,120,180]/255)
hold on
plot(ibdata(nib).procdata.time, ibdata(nib).procdata.Fmt, 'Color', [227,26,28]/255)
xlim(ax.XAxis.Limits)
ylabel('F_{MTU} (N)')

subplot(427)
plot(iadata(nia).procdata.spiketimes, iadata(nia).procdata.ifr, ...
    'Marker', '.', 'LineStyle', 'none', 'Color', [31,120,180]/255)
hold on
plot(ibdata(nib).procdata.spiketimes, ibdata(nib).procdata.ifr, ...
    'Marker', '.', 'LineStyle', 'none', 'Color', [227,26,28]/255)
xlim(ax.XAxis.Limits)
ylabel('IFR (pps)')

subplot(424)
plot(iadata(nia).procdata.time, iadata(nia).procdata.Lf, 'Color', [31,120,180]/255)
hold on
plot(ibdata(nib).procdata.time, ibdata(nib).procdata.Lf, 'Color', [227,26,28]/255)
xlim([3 4.3])

subplot(426)
plot(iadata(nia).procdata.time, iadata(nia).procdata.Fmt, 'Color', [31,120,180]/255)
hold on
plot(ibdata(nib).procdata.time, ibdata(nib).procdata.Fmt, 'Color', [227,26,28]/255)
xlim([3 4.3])

subplot(428)
plot(iadata(nia).procdata.spiketimes, iadata(nia).procdata.ifr, ...
    'Marker', '.', 'LineStyle', 'none', 'Color', [31,120,180]/255)
hold on
plot(ibdata(nib).procdata.spiketimes, ibdata(nib).procdata.ifr, ...
    'Marker', '.', 'LineStyle', 'none', 'Color', [227,26,28]/255)
xlim([3 4.3])

print([savepath filesep 'SICB_2_2C'], '-depsc2')
%%

xia = interp1(iadata(nia).procdata.time, iadata(nia).procdata.Lmt, iadata(nia).procdata.spiketimes);
yia = interp1(iadata(nia).procdata.time, iadata(nia).procdata.Fmt, iadata(nia).procdata.spiketimes);
xib = interp1(ibdata(nib).procdata.time, ibdata(nib).procdata.Lmt, ibdata(nib).procdata.spiketimes);
yib = interp1(ibdata(nib).procdata.time, ibdata(nib).procdata.Fmt, ibdata(nib).procdata.spiketimes);

xia = xia - iadata(nia).procdata.Lmt(1);
xib = xib - ibdata(nib).procdata.Lmt(1);

figure('Position', [100 100 400 800])
% subplot(311)
% plot(iadata(nia).procdata.time, ...
%     iadata(nia).procdata.Fmt)
% hold on
% plot(ibdata(nib).procdata.time, ...
%     ibdata(nib).procdata.Fmt)
% xlim([0 8])

% subplot(3, 1, [2 3])
subplot(211)
plot(iadata(nia).procdata.Lmt - iadata(nia).procdata.Lmt(1), ...
    iadata(nia).procdata.Fmt, 'Color', [.75 .75 .75])
hold on
plot(xia, yia, 'Marker', '.', 'LineStyle', 'none', 'Color', [31,120,180]/255)
ylabel('F_{MTU}')

subplot(212)
hold on
plot(ibdata(nib).procdata.Lmt - ibdata(nib).procdata.Lmt(1), ...
    ibdata(nib).procdata.Fmt, 'Color', [.75 .75 .75])
plot(xib, yib, 'Marker', '.', 'LineStyle', 'none', 'Color', [227,26,28]/255)
xlabel('\Delta L_{MTU}')
ylabel('F_{MTU}')
xlim([-1 1])

print([savepath filesep 'SICB_2_2D'], '-depsc2')
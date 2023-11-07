clc
clear
close all
 
addpath(genpath('Functions'))
source = uigetdir('/Volumes/labs/ting/shared_ting/Jake/SFN/');
 
savedir = uigetdir();
 
D = dir(source);
D = D(3:end);

%% MAKE RASTERS
close

nIA = sum(contains({D.name}, 'IA'));
nII = sum(contains({D.name}, 'II'));

% matrices for making mean fr plots
IAFR = zeros(nIA, 200);
IAST = 50*ones(nIA, 200);
IIFR = zeros(nII, 200);
IIST = 50*ones(nII, 200);

iact = 0;
iict = 0;

F1 = figure();

for ii = 1:numel(D)
    if contains(D(ii).name, 'IA')

        data = load([D(ii).folder filesep D(ii).name]);
        spiketimes = data.procdata.spiketimes;

        x1 = spiketimes';
        x2 = spiketimes';
        y1 = zeros(size(spiketimes))';
        y2 = ones(size(spiketimes))';

        hold on
        subplot(511)
        plot([x1; x2], [y1; y2] + iact, 'k')
        xlim([-.5 2])

        iact = iact + 1;

        IAST(iact, 1:numel(spiketimes)) = x1; % save st's to matrix
        IAFR(iact, 1:numel(spiketimes)) = data.procdata.ifr; % save fr's to matrix

    elseif contains(D(ii).name, 'II')

        data = load([D(ii).folder filesep D(ii).name]);
        spiketimes = data.procdata.spiketimes;

        x1 = spiketimes';
        x2 = spiketimes';
        y1 = zeros(size(spiketimes))';
        y2 = ones(size(spiketimes))';

        hold on
        subplot(514)
        plot([x1; x2], [y1; y2] + iict, 'k')
        xlim([-.5 2])

        iict = iict + 1;

        IIST(iict, 1:numel(spiketimes)) = x1; % save st's to matrix
        IIFR(iict, 1:numel(spiketimes)) = data.procdata.ifr; % save fr's to matrix

    end
end

% MAKE MEAN FR TRACES

binsize = .005;
bins = -.5:binsize:2;

iatrace = zeros(size(bins));
iitrace = zeros(size(bins));


iasd = zeros(size(bins));
iisd = zeros(size(bins));

for jj = 1:numel(bins) - 1

    iatrace(jj) = sum(sum(IAFR(IAST > bins(jj) & IAST < bins(jj+1))))/nIA;
    iasd(jj) = std(IAFR(IAST > bins(jj) & IAST < bins(jj+1)));

    iitrace(jj) = sum(sum(IAFR(IIST > bins(jj) & IIST < bins(jj+1))))/nII;
    iisd(jj) = std(IIFR(IIST > bins(jj) & IIST < bins(jj+1)));
end

iasd(isnan(iasd)) = 0;
iisd(isnan(iisd)) = 0;
% 
x1 = [bins flip(bins)];
y1 = [(iatrace - iasd) flip(iatrace + iasd)];
y2 = [(iitrace - iisd) flip(iitrace + iisd)];

a = .2;

subplot(5, 1, [2 3])
hold on
fill(x1, y1, [49, 130, 189]/255, 'FaceAlpha', a, 'EdgeColor', 'none')
plot(bins, iatrace, 'Color', [49, 130, 189]/255)
fill(x1, y2, [230, 85, 13]/255, 'FaceAlpha', a, 'EdgeColor', 'none')
plot(bins, iitrace, 'Color', [230, 85, 13]/255)
hold off
ylim([-50 350])

subplot(515)
plot(data.procdata.time, data.procdata.Lmt)
xlim([-.5 2])

saveas(F1, [savedir filesep 'Raster.eps'], 'epsc')
saveas(F1, [savedir filesep 'Raster.jpg'], 'jpeg')
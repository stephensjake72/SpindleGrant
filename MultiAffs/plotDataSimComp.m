% create csv
clc; clear; close all;

addpath(genpath('Functions'))
 
D = dir('/Volumes/labs/ting/shared_ting/Jake/MultiAffs_mat');
D = D(3:end);
opts = {D.name};
opts = opts';
sel = listdlg('ListString', opts);
folders = opts(sel);
close

%% ramps

vars = {'address', 'animal', 'cellID', 'affType', 'stretchV', 'inburst', ...
    'dr', 'sr'};
datatypes = {'string', 'string', 'string', 'string', 'double', 'double', 'double', 'double'};
rampT = table('Size', [1e4 length(vars)], 'VariableNames', ...
    vars, 'VariableTypes', datatypes);

count = 1;

for n = 1:length(folders)
    subdir = dir([D(1).folder filesep folders{n} filesep 'procdata']);
    subdir = subdir(3:end);
    for m = 1:length(subdir)
        check1 = contains(subdir(m).name, 'ramp');
        check2 = contains(subdir(m).name, 'IA') || contains(subdir(m).name, 'II');
        if check1 && check2
            data = load([subdir(m).folder filesep subdir(m).name]);

            rampT.address{count} = [subdir(m).folder filesep subdir(m).name];
            rampT.animal{count} = data.parameters.ID;
            rampT.cellID{count} = [data.parameters.ID '-' data.parameters.cellnum];
            rampT.affType{count} = data.parameters.afftype;
            rampT.stretchV(count) = floor(max(data.procdata.dLmt));
            rampT.inburst(count) = computeinitialburst(data.procdata);
            rampT.dr(count) = computedynamicresponse(data.procdata);
            rampT.sr(count) = computestaticresponse(data.procdata);

            count = count + 1;
        end
    end
end

rampT(count:end, :) = [];
%%
clear n m
cells = unique(rampT.cellID(rampT.affType == 'IA'));

colors = mapColors([31,120,180]/255, [31,120,180]/255, length(cells));

for n = 1:length(cells)
    smalltable = rampT(rampT.cellID == cells(n), :);
    
    [x1, y1] = computeTrendLine(smalltable.stretchV, smalltable.inburst); 
    subplot(321)
    hold on
    scatter(smalltable.stretchV, smalltable.inburst, 8, colors(n, :), 'filled')
    plot(x1, y1, 'Color', colors(n, :))
    xlim([14 30])
    title('Initial burst')
    

    [x2, y2] = computeTrendLine(smalltable.stretchV, smalltable.dr); 
    subplot(323)
    hold on
    scatter(smalltable.stretchV, smalltable.dr, 8, colors(n, :), 'filled')
    plot(x2, y2, 'Color', colors(n, :))
    xlim([14 30])
    title('Dynamic response')
    

    [x3, y3] = computeTrendLine(smalltable.stretchV, smalltable.sr); 
    subplot(325)
    hold on
    scatter(smalltable.stretchV, smalltable.sr, 8, colors(n, :), 'filled')
    plot(x3, y3, 'Color', colors(n, :))
    xlim([14 30])
    title('Static response')
end

% plot sim
[file, path] = uigetfile('/Users/jacobstephens/Documents/SimResults');
sim = load([path file]);

% process
iasim_ib = zeros(1, 5);
iasim_dr = zeros(1, 5);
iasim_sr = zeros(1, 5);
t = sim.results.ia.r_t;
r = sim.results.ia.r;

for n = 1:5
    t = sim.results.ia.r_t(n, :);
    r = sim.results.ia.r(n, :);

    iasim_ib(n) = max(r(t > 0 & t < .1));
    iasim_dr(n) = max(r(t > 0.05 & t < .5));
    iasim_sr(n) = r(find(t > 0.6, 1, 'first'));
end

subplot(321)
hold on
plot([15 17 20 24 30], iasim_ib, 'k', ...
    'LineWidth', 2, ...
    'Marker', 'o', ...
    'MarkerSize', 4, ...
    'MarkerFaceColor', [0 0 0], ...
    'MarkerEdgeColor', [0 0 0])

subplot(323)
hold on
plot([15 17 20 24 30], iasim_dr, 'k', ...
    'LineWidth', 2, ...
    'Marker', 'o', ...
    'MarkerSize', 4, ...
    'MarkerFaceColor', [0 0 0], ...
    'MarkerEdgeColor', [0 0 0])

subplot(325)
hold on
plot([15 17 20 24 30], iasim_sr, 'k', ...
    'LineWidth', 2, ...
    'Marker', 'o', ...
    'MarkerSize', 4, ...
    'MarkerFaceColor', [0 0 0], ...
    'MarkerEdgeColor', [0 0 0])

%
clear n m cells
cells = unique(rampT.cellID(rampT.affType == 'II'));

colors2 = mapColors([255,127,0]/255, [255,127,0]/255, 10);

for n = 1:length(cells)
    smalltable = rampT(rampT.cellID == cells(n), :);

    [x2, y2] = computeTrendLine(smalltable.stretchV, smalltable.dr); 
    subplot(324)
    hold on
    scatter(smalltable.stretchV, smalltable.dr, 8, colors2(n, :), 'filled')
    plot(x2, y2, 'Color', colors2(n, :))
    xlim([14 30])
    title('Dynamic response')

    [x3, y3] = computeTrendLine(smalltable.stretchV, smalltable.sr); 
    subplot(326)
    hold on
    scatter(smalltable.stretchV, smalltable.sr, 8, colors2(n, :), 'filled')
    plot(x3, y3, 'Color', colors2(n, :))
    xlim([14 30])
    title('Static response')
end

% process
iisim_ib = zeros(1, 5);
iisim_dr = zeros(1, 5);
iisim_sr = zeros(1, 5);
t = sim.results.ii.r_t;
r = sim.results.ii.r;

for n = 1:5
    t = sim.results.ii.r_t(n, :);
    r = sim.results.ii.r(n, :);

    iisim_ib(n) = max(r(t > 0 & t < .1));
    iisim_dr(n) = max(r(t > 0.05 & t < .5));
    iisim_sr(n) = r(find(t > 0.6, 1, 'first'));
end

subplot(324)
hold on
plot([15 17 20 24 30], iisim_dr, 'k', ...
    'LineWidth', 2, ...
    'Marker', 'o', ...
    'MarkerSize', 4, ...
    'MarkerFaceColor', [0 0 0], ...
    'MarkerEdgeColor', [0 0 0])

subplot(326)
hold on
plot([15 17 20 24 30], iisim_sr, 'k', ...
    'LineWidth', 2, ...
    'Marker', 'o', ...
    'MarkerSize', 4, ...
    'MarkerFaceColor', [0 0 0], ...
    'MarkerEdgeColor', [0 0 0])

print('/Users/jacobstephens/Documents/Figures/SICBFig1C', '-depsc', '-painters')

%% triangles  ////////////////////////////////////////////////////////////
clear vars datatypes
vars = {'address', 'animal', 'cellID', 'affType', 'sc1', 'sc2', 'sc3'};
datatypes = {'string', 'string', 'string', 'string', 'double', 'double', 'double'};
triT = table('Size', [1e4 length(vars)], 'VariableNames', ...
    vars, 'VariableTypes', datatypes);

count = 1;

for n = 1:length(folders)
    subdir = dir([D(1).folder filesep folders{n} filesep 'procdata']);
    subdir = subdir(3:end);
    for m = 1:length(subdir)
        check1 = contains(subdir(m).name, 'triangle');
        check2 = contains(subdir(m).name, 'IA') || contains(subdir(m).name, 'II');
        if check1 && check2
            data = load([subdir(m).folder filesep subdir(m).name]);
            if data.parameters.startTime < 50
                continue
            end

            triT.address{count} = [subdir(m).folder filesep subdir(m).name];
            triT.animal{count} = data.parameters.ID;
            triT.cellID{count} = [data.parameters.ID '-' data.parameters.cellnum];
            triT.affType{count} = data.parameters.afftype;
            triT.stretchV(count) = floor(max(data.procdata.dLmt));

            sc = computeTriSC(data.procdata.spiketimes);
            triT.sc1(count) = sc(1);
            triT.sc2(count) = sc(2);
            triT.sc3(count) = sc(3);
            clear sc

            count = count + 1;
        end
    end
end

triT(count:end, :) = [];
%%

clear n m
cells = unique(triT.cellID(triT.affType == 'IA'));

colors = mapColors([31,120,180]/255, [31,120,180]/255, length(cells));

for n = 1:length(cells)
    smalltable = triT(triT.cellID == cells(n), :);
    x = [1 2 3]; 
    subplot(321)
    hold on
    plot(x, [smalltable.sc1, smalltable.sc2, smalltable.sc3], ...
        'Color', colors(n, :), ...
        'Marker', 'o', ...
        'MarkerFaceColor', colors(n, :))
end
%%
% plot sim
% trisim = load('trisims.mat');

% % process
% iasim_ib = zeros(1, 5);
% iasim_dr = zeros(1, 5);
% iasim_sr = zeros(1, 5);
% t = sim.results.ia.r_t;
% r = sim.results.ia.r;
% 
% for n = 1:5
%     t = sim.results.ia.r_t(n, :);
%     r = sim.results.ia.r(n, :);
% 
%     iasim_ib(n) = max(r(t > 0 & t < .1));
%     iasim_dr(n) = max(r(t > 0.05 & t < .5));
%     iasim_sr(n) = r(find(t > 0.6, 1, 'first'));
% end
% 
% subplot(321)
% hold on
% plot([15 17 20 24 30], iasim_ib, 'k', ...
%     'LineWidth', 2, ...
%     'Marker', 'o', ...
%     'MarkerSize', 4, ...
%     'MarkerFaceColor', [0 0 0], ...
%     'MarkerEdgeColor', [0 0 0])
% 
% subplot(323)
% hold on
% plot([15 17 20 24 30], iasim_dr, 'k', ...
%     'LineWidth', 2, ...
%     'Marker', 'o', ...
%     'MarkerSize', 4, ...
%     'MarkerFaceColor', [0 0 0], ...
%     'MarkerEdgeColor', [0 0 0])
% 
% subplot(325)
% hold on
% plot([15 17 20 24 30], iasim_sr, 'k', ...
%     'LineWidth', 2, ...
%     'Marker', 'o', ...
%     'MarkerSize', 4, ...
%     'MarkerFaceColor', [0 0 0], ...
%     'MarkerEdgeColor', [0 0 0])
% 
% %
% clear n m cells
% cells = unique(triT.cellID(triT.affType == 'II'));
% 
% colors2 = mapColors([255,127,0]/255, [255,127,0]/255, 10);
% 
% for n = 1:length(cells)
%     smalltable = triT(triT.cellID == cells(n), :);
% 
%     [x2, y2] = computeTrendLine(smalltable.stretchV, smalltable.dr); 
%     subplot(324)
%     hold on
%     scatter(smalltable.stretchV, smalltable.dr, 8, colors2(n, :), 'filled')
%     plot(x2, y2, 'Color', colors2(n, :))
%     xlim([14 30])
%     title('Dynamic response')
% 
%     [x3, y3] = computeTrendLine(smalltable.stretchV, smalltable.sr); 
%     subplot(326)
%     hold on
%     scatter(smalltable.stretchV, smalltable.sr, 8, colors2(n, :), 'filled')
%     plot(x3, y3, 'Color', colors2(n, :))
%     xlim([14 30])
%     title('Static response')
% end
% 
% % process
% iisim_ib = zeros(1, 5);
% iisim_dr = zeros(1, 5);
% iisim_sr = zeros(1, 5);
% t = sim.results.ii.r_t;
% r = sim.results.ii.r;
% 
% for n = 1:5
%     t = sim.results.ii.r_t(n, :);
%     r = sim.results.ii.r(n, :);
% 
%     iisim_ib(n) = max(r(t > 0 & t < .1));
%     iisim_dr(n) = max(r(t > 0.05 & t < .5));
%     iisim_sr(n) = r(find(t > 0.6, 1, 'first'));
% end
% 
% subplot(324)
% hold on
% plot([15 17 20 24 30], iisim_dr, 'k', ...
%     'LineWidth', 2, ...
%     'Marker', 'o', ...
%     'MarkerSize', 4, ...
%     'MarkerFaceColor', [0 0 0], ...
%     'MarkerEdgeColor', [0 0 0])
% 
% subplot(326)
% hold on
% plot([15 17 20 24 30], iisim_sr, 'k', ...
%     'LineWidth', 2, ...
%     'Marker', 'o', ...
%     'MarkerSize', 4, ...
%     'MarkerFaceColor', [0 0 0], ...
%     'MarkerEdgeColor', [0 0 0])
% 
% print('/Users/jacobstephens/Documents/Figures/SICBFig1D', '-depsc', '-painters')

%%

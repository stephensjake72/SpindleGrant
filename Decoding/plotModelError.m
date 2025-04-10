clc
clear
close all

folder = uigetdir('/Users/jacobstephens/Documents/Data')
d = dir(folder)

cellstr = {'IA', 'II', 'IB', 'IX'};
sel = listdlg('ListString', cellstr);
cellsel = cellstr(sel);

stretchstr = {'ramp', 'triangle', 'sine'};
sel2 = listdlg('ListString', stretchstr);
stretchsel = stretchstr(sel2);
%%

% get number of rows and columns
check1 = contains({d.name}, '.mat');
check2 = contains({d.name}, cellsel);
check3 = contains({d.name}, stretchsel);
numplots = sum(check1 & check2 & check3);
numrows = ceil(sqrt(numplots));
%%

close all
% SPIKETIMES = zeros

plotct = 1;
for n = 1:length(d)
    if ~contains(d(n).name, '.mat') || ...
            ~contains(d(n).name, cellsel) || ...
            ~contains(d(n).name, stretchsel)
        continue
    end
    data = load([d(n).folder filesep d(n).name]);
    fittype = fieldnames(data);
    fit = fittype{1};
    
    % ifr vs predictor
    figure(1)
    subplot(211)
    hold on
    plot(data.(fit).pred_s, data.(fit).pred_s, 'r')
    plot(data.(fit).pred_s, data.(fit).ifr, '.k')
    xlabel('predicted ifr')
    ylabel('recorded ifr')
    sgtitle(cellsel)
    % residuals
    subplot(212)
    hold on
    stem(data.(fit).spiketimes, data.(fit).resid, 'Marker', '.')
    xlabel('time')
    ylabel('error')

    figure(2)
    subplot(numrows, numrows, plotct)
    plot(data.(fit).time, data.(fit).predictor, 'r')
    hold on
    plot(data.(fit).spiketimes, data.(fit).ifr, '.k')

    plotct = plotct + 1;
end
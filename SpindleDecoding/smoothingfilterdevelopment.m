clc;
clear;
close all

d = dir('/Volumes/labs/ting/shared_ting/Jake/decoding_models_procdata/');
%%
clc

% get sample trial
for n = 1:numel(d)
    disp([num2str(n) ' ' d(n).name])
    % if contains(d(n).name, 'IA')
    %     load([d(n).folder filesep d(n).name]);
    %     break
    % end
end

nia = 63;
nii = 140;
nib = 25;
% iadata(1) = load([d(nia).folder filesep d(nia).name]);
% iidata(1) = load([d(nii).folder filesep d(nii).name]);
% ibdata(1) = load([d(nib).folder filesep d(nib).name]);

for n = 1:3
    iadata(n) = load([d(nia+n-1).folder filesep d(nia+n-1).name]);
    iidata(n) = load([d(nii+n-1).folder filesep d(nii+n-1).name]);
    ibdata(n) = load([d(nib+n-1).folder filesep d(nib+n-1).name]);

    hold on
    plot(iadata(n).procdata.time, iadata(n).procdata.Lmt)
    plot(iidata(n).procdata.time, iidata(n).procdata.Lmt + 1)
    plot(ibdata(n).procdata.time, ibdata(n).procdata.Lmt + 2)
end
%%
close all
% create binary spike train vector

[tia, yia] = genspiketrain(iadata); % make binary vector from spiketimes
y = yia(1, :); % take a single trial

% create isi vector to base the filter width on
interval = zeros(size(y));
si = find(y == 1); % spike index
for n = 1:length(si) - 1
    interval(si(n):si(n+1)) = tia(si(n+1)) - tia(si(n));
end
% interval = smooth(interval, 100); % smooth
plot(interval*1000)
xlabel('time')
ylabel('isi (ms)')
title('interspike interval')

% convolve the interval vector so that its time aligned with the smoothed
% rate vectors later
f1 = genfilter(tia, .001, 'gaussian');
int1 = conv(f1, interval, 'same');
int1 = int1*max(interval)/max(int1); % scale
plot(tia, interval)
hold on
plot(tia, int1)
title('convolved isi')

% create signal matrix
x = -4:.01:-1;
S = 10.^x;
% S = [.001 .0015 .002 .0025 .0035 .005 .0075 .01]; %initial guesses to establish the method
R = zeros(length(S), length(tia)); % matrix for smoothed signals at various widths

figure
plot(S*1000)
xlabel('S')
ylabel('filter width (ms)')

figure
tiledlayout('flow')
for m = 1:length(S)
    f = genfilter(tia, S(m), 'gaussian');
    R(m, :) = conv(y, f, 'same');
    if mod(m+1, 10) == 0
        nexttile
        plot(tia, R(m, :))
        title(['\sigma = ', num2str(S(m)*1000) ' ms'])
        % nexttile
    end
end
sgtitle('variable filter widths')

row = zeros(size(tia));
r = zeros(size(tia));
F = zeros(size(tia));

for p = 1:length(tia) % loop through time
    % pick the filter width based on the isi at time point p
    [~, row(p)] = min(abs(int1(p) - S)); 
    F(p) = S(row(p));
    w = genweights(S, 15, row(p));
    r(p) = dot(R(:, p), w);
end
figure
subplot(211)
plot(tia, r)
% xlim([.2 .6])
hold on
plot(iadata(1).procdata.spiketimes + .375, iadata(1).procdata.ifr, '.k')
subplot(212)
plot(tia, F*1000)
% xlim([.2 .6])
ylabel('principal filter width (ms)')
xlabel('time')

%%
function y = genfilter(t, width, type)
    if strcmp(type, 'gaussian')
        y = (1/sqrt(2*pi*width^2))*exp(-(t - max(t)/2).^2/(2*width^2));
    elseif strcmp(type, 'exp')
        y = (4/width^2)*(t - max(t)/2).*exp(-2*(t - max(t)/2)/width);
        y(y < 0) = 0;
    elseif strcmp(type, 'reverse exp')
        y = (4/width^2)*(-t + max(t)/2).*exp(-2*(-t + max(t)/2)/width);
        y(y < 0) = 0;
    elseif strcmp(type, 'isoc triangle')
        y = -4*abs(t - max(t)/2)/width^2 + 2/width;
        y(y < 0) = 0;
    elseif strcmp(type, 'right triangle')
        y = -2*abs(t - max(t)/2)/width^2 + 2/width;
        y(t > max(t)/2) = 0;
        y(y < 0) = 0;
    elseif strcmp(type, 'rev right triangle')
        y = -2*abs(t - max(t)/2)/width^2 + 2/width;
        y(t < max(t)/2) = 0;
        y(y < 0) = 0;
    end
end

function [t, y] = genspiketrain(data)
    t = data(1).procdata.time;
    y = zeros(3, length(t));
    
    for n = 1:3
        st = data(n).procdata.spiketimes;
        for m = 1:length(st)
            [~, ist] = min(abs(t - st(m)));
            y(n, ist) = 1;
        end
    end
end

function W = genweights(S, width, row)
    nw = (width + 1)/2; % number of weights
    ndiff = [row - nw, length(S)-(row+nw) + 1]; % difference in row num and weight num
    ndiff(ndiff > 0) = 0;
    ndiff = min(ndiff);

    A = zeros(nw); % empty matrix
    A(1, :) = 1;
    A(1, 2:end+ndiff) = 2;
    A(2:end, 1:nw-1) = eye(nw-1);
    A(2:end, nw) = -nw:1:-2;
    % A

    x = [1; zeros(nw-1, 1)];

    w = (A^-1)*x;
    W = zeros(size(S)); % use weights to create weight vector
    W(row) = w(1);
    if nw > 1
        for m = 1:nw-1
            if row - m >= 1
                W(row - m) = w(m + 1);
            end
            if row + m <= length(W)
                W(row + m) = w(m + 1);
            end
        end
    end
end
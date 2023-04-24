clc
clear
close all

[filename, addy] = uigetfile();
data = load([addy filesep filename]);
%%
fit = data.FYfit;
time = data.procdata.time;

sf = .1;
r = sf*fit.predictor/max(fit.predictor);

binwidth = .0025; % 2.5 ms
bintime = min(time):binwidth:max(time);
rint = interp1(time, r, bintime);
thresh = rand(1, numel(bintime));

spikes = rint>thresh;
spiketimes = bintime(spikes == 1);
ifr = 1./(spiketimes(2:end) - spiketimes(1:end - 1));

subplot(211)
plot(bintime, rint)
hold on
stem(bintime, .1*spikes, 'Marker', 'none')
hold off
subplot(212)
plot(spiketimes(2:end), ifr, '.k') 
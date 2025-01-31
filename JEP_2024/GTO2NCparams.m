%% fit NC parameters for data
clc; clear; close all;

addpath(genpath('Functions'))
%%
animal = 'A100142-24-62';
d = dir(['/Volumes/labs/ting/shared_ting/Jake/MultiAffs_mat/' animal '/procdata']);

ibnum = '-10-';
count = 1;

pn = 1;
figure(1)
for m = 1:numel(d)
    if contains(d(m).name, 'ramp') && contains(d(m).name, ibnum)
        ibdata(count) = load([d(m).folder filesep d(m).name]);

        subplot(15, 1, count)
        plot(ibdata(count).procdata.spiketimes, ibdata(count).procdata.ifr, '.k')
        set(gca, 'xtick', [])

        count = count+1;
    end
end
%%
close all

NC = getNCparameters(ibdata);

for n = 1:15
    Fnc = NC.A*exp(NC.kexp*(ibdata(n).procdata.Lmt - NC.L0));
    figure
    subplot(211)
    plot(ibdata(n).procdata.time, ibdata(n).procdata.Fmt)
    hold on
    plot(ibdata(n).procdata.time, ibdata(n).procdata.Fmt - Fnc)
    subplot(212)
    plot(ibdata(n).procdata.time, NC.kF*(ibdata(n).procdata.Fmt - Fnc))
    hold on
    plot(ibdata(n).procdata.spiketimes, ibdata(n).procdata.ifr, '.k')
end

save('NC.mat', 'NC')
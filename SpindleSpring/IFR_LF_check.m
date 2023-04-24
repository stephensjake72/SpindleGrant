clc
clear
close all
load('summaryTable.mat')
addpath(genpath('Functions'))

for ii = 1:height(summaryTable)
    check1 = summaryTable.passive{ii} == 1;
    check2 = summaryTable.badtrial{ii} == 0;
    check3 = strcmp(summaryTable.type{ii}, 'ramp');
    check4 = strcmp(summaryTable.aff{ii}, 'IA');
    check5 = strcmp(summaryTable.KT{ii}, 'C');
    if check1 && check2 && check3 && check4 && check5
        data = load(summaryTable.address{ii});
        
        Lf = data.procdata.Lf;
        time = data.procdata.time;
        st = data.procdata.spiketimes;
        ifr = data.procdata.ifr;
        
        Lfst = interp1(time, Lf, st);
        
        colorvec = zeros(1, numel(st));
        colorvec(st > 1.2) = .5;
        sz = 4*ones(numel(st), 1);
        
        subplot(311)
        hold on
        plot(time, Lf)
        subplot(312)
        hold on
        scatter(st, ifr, sz, [colorvec' colorvec' colorvec'])
        subplot(325)
        hold on
        scatter(Lfst/max(Lfst), ifr, sz, [colorvec' colorvec' colorvec'])
        subplot(326)
        hold on
        scatter(Lfst/max(Lfst), ifr, sz, [colorvec' colorvec' colorvec'])
        xlim([.95 1])
        clear data
    end
end
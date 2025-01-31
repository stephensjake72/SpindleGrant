clc; clear; close all
addpath(genpath('Functions'))

load('spikesignals.mat')

%%
% part 1, plot NC model
sample = S(1);

subplot(421)
plot(sample.ibdata.procdata.time, sample.ibdata.procdata.Fmt)
xlim([-.1 1.5])
ax = gca;

subplot(423)
plot(sample.ibdata.procdata.time, sample.ibdata.procdata.Lmt)
xlim(ax.XAxis.Limits)

subplot(422)
plot(sample.ibdata.fit.time, sample.ibdata.fit.Fc)
xlim(ax.XAxis.Limits)
ylim(ax.YAxis.Limits)

subplot(223)
plot(sample.ibdata.fit.time, sample.ibdata.fit.Fc)
xlim(ax.XAxis.Limits)

subplot(224)
plot(sample.ibdata.fit.time, sample.ibdata.fit.Fcomp)
hold on
plot(sample.ibdata.fit.spiketimes, sample.ibdata.fit.ifr, '.k')
xlim(ax.XAxis.Limits)
print('/Users/jacobstephens/Documents/Figures/Multimodal paper/Fig3B', '-depsc', '-painters')

%% plot II/IB model

% first make stretch velocity table to match
via = zeros(15, 1);
vii = zeros(15, 1);
vib = zeros(15, 1);
T = table(via, vii, vib);
for n = 1:15
    T.via(n) = S(n).iadata.stretchV;
    T.vii(n) = S(n).iidata.stretchV;
    T.vib(n) = S(n).ibdata.stretchV;
end

Kinv = [Cii; Cib]^-1;

vels = [15 17 20 24 30];
iicolors = mapColors([51,160,44]/255, [178,223,138]/255, 5);
ibcolors = mapColors([63,0,125]/255, [188,189,220]/255, 5);
ycolors = mapColors([122,1,119]/255, [252,197,192]/255, 5);

% part 1, passive ////////////////////////////////////////////////////////
figure('Position', [0 0 800 200])
for m = 1:5
    ii_inds = find(T.vii == vels(m));
    ib_inds = find(T.vib == vels(m));
    for p = 1:3
        nii = ii_inds(p);
        nib = ib_inds(p);

        subplot(221)
        hold on
        plot(S(nii).time, S(nii).s2, 'Color', iicolors(m, :))
        xlim([-.1 1.5])

        subplot(223)
        hold on
        plot(S(nib).time, S(nib).s3, 'Color', ibcolors(m, :))
        xlim([-.1 1.5])

        spindleforce = S(nii).s2/Cii(1); % approx spindle force by taking Rii/kF
        gtoforce = S(nib).s3/Cib(1); % do the same for gto

        extforce = spindleforce;
        intforce = gtoforce-spindleforce;
        intforce(intforce < 0) = 0;

        subplot(222)
        hold on
        plot(S(nii).time, extforce, 'Color', ycolors(m, :))
        xlim([-.1 1.5])

        subplot(224)
        hold on
        plot(S(nii).time, intforce, 'Color', ycolors(m, :))
        xlim([-.1 1.5])
        ylim([0 0.4])
    end
end

print('/Users/jacobstephens/Documents/Figures/Multimodal paper/Fig3C', '-depsc', '-painters')

%%
close all

% part 2, eccentric //////////////////////////////////////////////////////

figure('Position', [0 0 800 200])

for m = 1:5
    ii_inds = find(T.vii == vels(m));
    ib_inds = find(T.vib == vels(m));
    for p = 1:3
        nii = ii_inds(p);
        nib = ib_inds(p);

        c = 25;
        s3 = S(nib).s3 + c; % add muscle tone offset

        subplot(221)
        hold on
        plot(S(nii).time, S(nii).s2, 'Color', iicolors(m, :))
        xlim([-.1 1.5])

        subplot(223)
        hold on
        plot(S(nib).time, s3, 'Color', ibcolors(m, :))
        yline(c, '--')
        xlim([-.1 1.5])

        spindleforce = S(nii).s2/Cii(1); % approx spindle force by taking Rii/kF
        gtoforce = s3/Cib(1); % do the same for gto

        extforce = spindleforce;
        intforce = gtoforce-spindleforce;
        intforce(intforce < 0) = 0;

        subplot(222)
        hold on
        plot(S(nii).time, extforce, 'Color', ycolors(m, :))
        xlim([-.1 1.5])

        subplot(224)
        hold on
        plot(S(nii).time, intforce, 'Color', ycolors(m, :))
        xlim([-.1 1.5])
        ylim([0 0.4])
    end
end

print('/Users/jacobstephens/Documents/Figures/Multimodal paper/Fig3D', '-depsc', '-painters')

%%
% part 3, throw in Ia ////////////////////////////////////////////////////
close all

iacolors = mapColors([31,120,180]/255, [166,206,227]/255, 5);

figure('Position', [0 0 800 200])
for m = 1:5
    ia_inds = find(T.via == vels(m));
    ii_inds = find(T.vii == vels(m));
    ib_inds = find(T.vib == vels(m));
    for p = 1:3
        nia = ia_inds(p);
        nii = ii_inds(p);
        nib = ib_inds(p);

        Kinv = [Cia; Cii]^-1;
        spindlefy = Kinv*[S(nia).s1'; S(nii).s2'];
        gtof = S(nib).s3/Cib(1);

        subplot(321)
        hold on
        plot(S(nia).time, S(nia).s1, 'Color', iacolors(m, :))
        xlim([-.1 1.5])

        subplot(323)
        hold on
        plot(S(nii).time, S(nii).s2, 'Color', iicolors(m, :))
        xlim([-.1 1.5])

        subplot(325)
        hold on
        plot(S(nib).time, S(nib).s3, 'Color', ibcolors(m, :))
        xlim([-.1 1.5])

        Y = spindlefy(2, :)-4*gtof';
        subplot(3, 2, [2 4])
        hold on
        plot(S(nia).time, Y, 'Color', ycolors(m, :))
        yline(0, '--')
        ylim([-5 25])
        xlim([-.1 1.5])
    end
end

print('/Users/jacobstephens/Documents/Figures/Multimodal paper/Fig3E', '-depsc', '-painters')

clc; clear;

addpath(genpath('Functions'));

%% load data and create data structures
animal = 'A100142-24-62';
d = dir(['/Volumes/labs/ting/shared_ting/Jake/MultiAffs_mat/' animal '/procdata']);

ianum = '-7-';
iinum = '-3-';
ibnum = '-10-';
count = [1 1 1];

pn = 1;
figure(1)
for m = 1:numel(d)
    if contains(d(m).name, 'ramp') && contains(d(m).name, ianum)
        iadata(count(1)) = load([d(m).folder filesep d(m).name]);

        subplot(15, 3, 3*count(1)-2)
        plot(iadata(count(1)).procdata.spiketimes, iadata(count(1)).procdata.ifr, '.k')
        set(gca, 'xtick', [])
        xlim([-.1 1.5])

        count(1) = count(1)+1;
        
    elseif contains(d(m).name, 'ramp') && contains(d(m).name, iinum)
        iidata(count(2)) = load([d(m).folder filesep d(m).name]);

        subplot(15, 3, 3*count(2)-1)
        plot(iidata(count(2)).procdata.spiketimes, iidata(count(2)).procdata.ifr, '.k')
        set(gca, 'xtick', [])
        xlim([-.1 1.5])
        
        count(2) = count(2)+1;

    elseif contains(d(m).name, 'ramp') && contains(d(m).name, ibnum)
        ibdata(count(3)) = load([d(m).folder filesep d(m).name]);

        subplot(15, 3, 3*count(3))
        plot(ibdata(count(3)).procdata.spiketimes, ibdata(count(3)).procdata.ifr, '.k')
        set(gca, 'xtick', [])
        xlim([-.1 1.5])

        count(3) = count(3)+1;
    end
end

%% make tables to velocity-match stretches
clc; close all

% organizing tables
Tia = table('Size', [15, 4], ...
    'VariableTypes', {'double', 'double', 'double', 'double'}, ...
    'VariableNames', {'StretchV', 'n', 'kF', 'kY'});
Tii = table('Size', [15, 4], ...
    'VariableTypes', {'double', 'double', 'double', 'double'}, ...
    'VariableNames', {'StretchV', 'n', 'kF', 'kY'});
Tib = table('Size', [15, 4], ...
    'VariableTypes', {'double', 'double', 'double', 'double'}, ...
    'VariableNames', {'StretchV', 'n', 'kF', 'kY'});

for n = 1:15
    % save stretch velocity to data structure
    iadata(n).stretchV = getStretchV(iadata(n).procdata);
    iidata(n).stretchV = getStretchV(iidata(n).procdata);
    ibdata(n).stretchV = getStretchV(ibdata(n).procdata);

    % get index and stretch velocity to match up trials
    Tia.n(n) = n;
    Tii.n(n) = n;
    Tib.n(n) = n;
    Tia.StretchV(n) = iadata(n).stretchV;
    Tii.StretchV(n) = iidata(n).stretchV;
    Tib.StretchV(n) = ibdata(n).stretchV;
end
%% fit models
clear n

% model fit parameters
parameters = [100, 0, 0, 0; 
              0, 0, 0, 0; 
              500, 50, 0, 0];
ibparameters = [50, 0, 0, 0; 
              0, 0, 0, 0; 
              200, 0, 0, 0];
% load non-contractile element model
load('NC.mat')
NC.klin = 0; % no linear component
iaNC = NC;
iiNC = NC;
ibNC = NC;

iaNC.L0 = 0.425;
iiNC.L0 = 0.45;

for p = 1:15
    % fit models for each cell type
    iadata(p).fit = getFYgains(iadata(p).procdata, iaNC, parameters);
    iidata(p).fit = getFYgains(iidata(p).procdata, iiNC, parameters);
    ibdata(p).fit = getFYgains(ibdata(p).procdata, ibNC, ibparameters);

    % get coefficients to get K matrix later
    Tia.kF(p) = iadata(p).fit.kF;
    Tia.kY(p) = iadata(p).fit.kY;
    Tii.kF(p) = iidata(p).fit.kF;
    Tii.kY(p) = iidata(p).fit.kY;
    Tib.kF(p) = ibdata(p).fit.kF;
    Tib.kY(p) = ibdata(p).fit.kY;
end
save('iadata.mat', 'iadata')
save('iidata.mat', 'iidata')
save('ibdata.mat', 'ibdata')

%% panel B //////////////////////////////////////////////////////////////

% plot example model fits for panels B
nia = Tia.n(find(Tia.StretchV == 15, 1, 'first')); % find sample trials at v1
nii = Tii.n(find(Tii.StretchV == 15, 1, 'first'));

% panel B, noncontractile element model
subplot(221)
plot(iadata(nia).fit.time, iadata(nia).fit.Fmt, 'k')
set(gca, 'Box', 'off')
xlim([-.1 1.5])
ax = gca;
subplot(223)
plot(iadata(nia).fit.time, iadata(nia).fit.Lmt, 'k')
set(gca, 'Box', 'off')
xlim(ax.XAxis.Limits)
subplot(222)
plot(iadata(nia).fit.time, iadata(nia).fit.Fc)
set(gca, 'Box', 'off')
xlim(ax.XAxis.Limits)
ylim(ax.YAxis.Limits)

print('/Users/jacobstephens/Documents/Figures/Multimodal paper/Fig2B', '-depsc', '-painters')

%% panel C, spindle model fits ////////////////////////////////////////////

% ia fit
subplot(421)
plot(iadata(nia).fit.time, iadata(nia).fit.Fc)
set(gca, 'Box', 'off')
xlim([-.1 1.5])
ax = gca;
subplot(423)
plot(iadata(nia).fit.time, iadata(nia).fit.Yc)
set(gca, 'Box', 'off')
xlim(ax.XAxis.Limits)
subplot(422)
plot(iadata(nia).fit.time, iadata(nia).fit.predictor)
hold on
plot(iadata(nia).fit.spiketimes, iadata(nia).fit.ifr, '.k')
set(gca, 'Box', 'off')
xlim(ax.XAxis.Limits)

subplot(425)
plot(iidata(nii).fit.time, iidata(nii).fit.Fc)
set(gca, 'Box', 'off')
xlim(ax.XAxis.Limits)
subplot(427)
plot(iidata(nii).fit.time, iidata(nii).fit.Yc)
set(gca, 'Box', 'off')
xlim(ax.XAxis.Limits)
subplot(426)
plot(iidata(nii).fit.time, iidata(nii).fit.predictor)
hold on
plot(iidata(nii).fit.spiketimes, iidata(nii).fit.ifr, '.k')
set(gca, 'Box', 'off')
xlim(ax.XAxis.Limits)

print('/Users/jacobstephens/Documents/Figures/Multimodal paper/Fig2C', '-depsc', '-painters')

%% inverse model
close all

% create C vectors for coefficients using the slow stretches, C = [kF kY]
trainv = 15;
Cia = [mean(Tia.kF(Tia.StretchV == trainv)) mean(Tia.kY(Tia.StretchV == trainv))];
Cii = [mean(Tii.kF(Tii.StretchV == trainv)) mean(Tii.kY(Tii.StretchV == trainv))];
Cib = [mean(Tib.kF(Tib.StretchV == trainv)) mean(Tib.kY(Tib.StretchV == trainv))];

% get K matrix
K = [Cia; Cii]; % kfia, kyia; kfii kyii
Kinv = K^-1;

% set up plot colors
colorsF = mapColors([215,48,31]/255, [253,212,158]/255, 5);
colorsL = mapColors([0, 0,  0]/255, [200 200 200]/255, 5);
colorsIA = mapColors([31,120,180]/255, [166,206,227]/255, 5);
colorsII = mapColors([51,160,44]/255, [178,223,138]/255, 5);

figure('Position', [0 0 800 500])
figure('Position', [800 0 800 300])

Tia = sortrows(Tia, "StretchV");
Tii = sortrows(Tii, "StretchV");
Tib = sortrows(Tib, "StretchV");
for q = 1:15
    nia = Tia.n(q);
    nii = Tii.n(q);
    nib = Tib.n(q);

    [time, s1, s2, s3] = interpSpikeRate(iadata(nia).procdata, ...
        iidata(nii).procdata, ...
        ibdata(nib).procdata);

    f = 1;
    s1 = smooth(s1, f);
    s2 = smooth(s2, f);
    s3 = smooth(s3, f);

    % save variables to a single structure
    S(q).iadata = iadata(nia);
    S(q).iidata = iidata(nii);
    S(q).ibdata = ibdata(nib);
    S(q).s1 = s1;
    S(q).s2 = s2;
    S(q).s3 = s3;
    S(q).time = time;

    % % plot to check
    % figure
    % subplot(311)
    % plot(time, s1, 'b')
    % hold on
    % plot(iadata(nia).procdata.spiketimes, iadata(nia).procdata.ifr, '.k')
    % subplot(312)
    % plot(time, s2, 'g')
    % hold on
    % plot(iidata(nii).procdata.spiketimes, iidata(nii).procdata.ifr, '.k')
    % subplot(313)
    % plot(time, s3, 'b')
    % hold on
    % plot(ibdata(nib).procdata.spiketimes, ibdata(nib).procdata.ifr, '.k')
    
    X = Kinv*[s1'; s2'];

    if mod(q, 1) == 0
        ncolor = ceil(q/3);
        figure(1)
        subplot(3, 2, 1)
        hold on
        plot(time, s1, 'Color', colorsIA(ncolor, :))
        scatter(iadata(nia).procdata.spiketimes, iadata(nia).procdata.ifr, 8, colorsIA(ncolor, :), 'filled')
        ax = gca;
        ax.XAxis.Visible = 'off';
        ax.XAxis.Limits = [-.1 1.5];
    
        subplot(3, 2, 3)
        hold on
        plot(time, s2, 'Color', colorsII(ncolor, :))
        scatter(iidata(nii).procdata.spiketimes, iidata(nii).procdata.ifr, 8, colorsII(ncolor, :), 'filled')
        xlim(ax.XAxis.Limits)
        ylim(ax.YAxis.Limits)
    
        subplot(3, 2, 2)
        hold on
        plot(time, X(1, :), 'Color', colorsF(ncolor, :))
        yline(0, '--')
        xlim(ax.XAxis.Limits)
    
        subplot(3, 2, 4)
        hold on
        plot(time, X(2, :), 'Color', colorsF(ncolor, :))
        yline(0, '--')
        xlim(ax.XAxis.Limits)
    
        subplot(6, 2, 9)
        hold on
        plot(iadata(nia).procdata.time, iadata(nia).procdata.Lmt, 'Color', colorsL(ncolor, :))
        xlim(ax.XAxis.Limits)

        figure(2)
        subplot(231)
        hold on
        plot(time, X(1, :), 'Color', colorsF(ncolor, :))
        yline(0, '--')
        ylim([-.6 1])
        ax2 = gca;
        ax2.XAxis.Limits = [-.1 0.5];

        subplot(234)
        hold on
        plot(time, X(2, :), 'Color', colorsF(ncolor, :))
        yline(0, '--')
        ylim([-10 20])
        xlim(ax2.XAxis.Limits)

        subplot(233)
        hold on
        plot(iadata(nia).procdata.time, iadata(nia).procdata.Lf, ...
            'Color', colorsL(ncolor, :))
        ylim(1.5*ax2.YAxis.Limits)
        xlim(ax2.XAxis.Limits)
        yline(0, '--')

        subplot(236)
        hold on
        plot(iadata(nia).procdata.time, iadata(nia).procdata.dLf, ...
            'Color', colorsL(ncolor, :))
        ylim([-10 20])
        xlim(ax2.XAxis.Limits)
        yline(0, '--')

        subplot(232)
        hold on
        plot(iadata(nia).fit.time, iadata(nia).fit.Fc, ...
            'Color', colorsF(ncolor, :))
        yline(0, '--')
        xlim(ax2.XAxis.Limits)
        ylim(ax2.YAxis.Limits)

        subplot(235)
        hold on
        plot(iadata(nia).fit.time, iadata(nia).fit.Yc, ...
            'Color', colorsF(ncolor, :))
        yline(0, '--')
        ylim([-10 20])
        xlim(ax2.XAxis.Limits)

    end
end
%%
figure(1)

print('/Users/jacobstephens/Documents/Figures/Multimodal paper/Fig2D', '-depsc', '-painters')
%%
figure(2)

print('/Users/jacobstephens/Documents/Figures/Multimodal paper/Fig2E', '-depsc', '-painters')
%%
close all

save('spikesignals.mat', 'S', 'Cia', 'Cii', 'Cib')

% plot to check signals are matched
for z = 1:15
    subplot(15, 3, 3*z - 2)
    plot(S(z).iadata.procdata.spiketimes, S(z).iadata.procdata.ifr, '.k')
    hold on
    plot(S(z).time, S(z).s1)
    ax = gca;
    ax.XAxis.Visible = 'off';

    subplot(15, 3, 3*z - 1)
    plot(S(z).iidata.procdata.spiketimes, S(z).iidata.procdata.ifr, '.k')
    hold on
    plot(S(z).time, S(z).s2)
    ax = gca;
    ax.XAxis.Visible = 'off';

    subplot(15, 3, 3*z)
    plot(S(z).ibdata.procdata.spiketimes, S(z).ibdata.procdata.ifr, '.k')
    hold on
    plot(S(z).time, S(z).s3)
    ax = gca;
    ax.XAxis.Visible = 'off';
end
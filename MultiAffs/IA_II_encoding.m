% mess around
clc; clear; close all

animal = 'A100142-24-62';
d = dir(['/Volumes/labs/ting/shared_ting/Jake/MultiAffs_mat/' animal '/procdata']);

% load IA and II data
ianum = '-1-';
iinum = '-3-';
count = [1 1];

for ii = 1:numel(d)
    if contains(d(ii).name, 'ramp') && contains(d(ii).name, ianum)
        iadata(count(1)) = load([d(ii).folder filesep d(ii).name]);
        count(1) = count(1)+1;
    elseif contains(d(ii).name, 'ramp') && contains(d(ii).name, iinum)
        iidata(count(2)) = load([d(ii).folder filesep d(ii).name]);
        count(2) = count(2)+1;
    end
end

%% guess a noncontractile model

% first pull everything into a matrix
n = 3100;
FMT = zeros(29, n);
DFMT = zeros(29, n);
LMT = zeros(29, n);
DLMT = zeros(29, n);

for jj = 1:14
    FMT(jj, :) = iadata(jj).procdata.Fmt(1:n);
    DFMT(jj, :) = iadata(jj).procdata.dFmt(1:n);
    LMT(jj, :) = iadata(jj).procdata.Lmt(1:n);
    DLMT(jj, :) = iadata(jj).procdata.dLmt(1:n);
end
for kk = 15:29
    FMT(kk, :) = iidata(kk-14).procdata.Fmt(1:n);
    DFMT(kk, :) = iidata(kk-14).procdata.dFmt(1:n);
    LMT(kk, :) = iidata(kk-14).procdata.Lmt(1:n);
    DLMT(kk, :) = iidata(kk-14).procdata.dLmt(1:n);
end

A = 0.0175;
k_exp = 1.2;
k_lin = 0.0;
L0 = 0.1;

FNC = A*exp(k_exp*(LMT - L0)) + k_lin*(LMT - L0);
FC = FMT - FNC;
% plot(FC')

DFNC = A*k_exp*DLMT.*exp(k_exp*(LMT - L0)) + k_lin*DLMT;
DFC = DFMT - DFNC;

subplot(221)
plot(FMT')
subplot(222)
plot(FC')
subplot(223)
plot(DFMT')
subplot(224)
plot(DFC')

%%
% kF = gains(1);
% kY = gains(2);
% bF = gains(3);
% bY = gains(4);

kvals = table('Size', [29, 3], 'VariableTypes', {'double', 'double', 'string'}, ...
    'VariableNames', {'kf', 'ky', 'celltype'});
c = 1;

NC.A = A; NC.kexp = k_exp; NC.L0 = L0; NC.klin = k_lin;
parameters = [100, 0, 0, 0; 0, 0, 0, 0; 500, 50, 0, 0];

for mm = 1:length(iadata)
    fit = getFYgains(iadata(mm).procdata, NC, parameters);
    iadata(mm).fit = fit;
    kvals.kf(c) = fit.kF;
    kvals.ky(c) = fit.kY;
    kvals.celltype{c} = iadata(mm).parameters.afftype;

    c = c+1;

    figure(1)
    subplot(5, 3, mm)
    plot(fit.time + fit.lambda, fit.predictor, fit.spiketimes, fit.ifr, '.k')
    figure(3)
    hold on
    scatter(1 + (randi(10)/100 -.05), fit.kF, 'xr')
    scatter(2 + (randi(10)/100 -.05), fit.kY, 'xr')
end

for nn = 1:length(iidata)
    fit = getFYgains(iidata(nn).procdata, NC, parameters);
    iidata(nn).fit = fit;
    kvals.kf(c) = fit.kF;
    kvals.ky(c) = fit.kY;
    kvals.celltype{c} = iidata(nn).parameters.afftype;

    c = c+1;

    figure(2)
    subplot(5, 3, nn)
    plot(fit.time + fit.lambda, fit.predictor, fit.spiketimes, fit.ifr, '.k')
    figure(3)
    hold on
    scatter(1 + (randi(10)/100 -.05), fit.kF, 'xb')
    scatter(2 + (randi(10)/100 -.05), fit.kY, 'xb')
end

%% do some more data structuring

K = [mean(kvals.kf(strcmp(kvals.celltype, 'IA'))), mean(kvals.ky(strcmp(kvals.celltype, 'IA'))); 
    mean(kvals.kf(strcmp(kvals.celltype, 'II'))), mean(kvals.ky(strcmp(kvals.celltype, 'II')))];

Kinv = K^-1;

T = table('Size', [29, 5], 'VariableTypes', {'cell', 'cell', 'double', 'cell', 'cell'}, ...
    'VariableNames', {'spiketimes', 'ifr', 'stretchv', 'afftype', 'startt'});
for qq = 1:length(iadata)
    T.spiketimes{qq} = iadata(qq).procdata.spiketimes;
    T.ifr{qq} = iadata(qq).procdata.ifr;
    v = iadata(qq).procdata.dLmt;
    T.stretchv(qq) = round(mean(v(v > 0.95*max(v))));
    T.afftype{qq} = iadata(qq).parameters.afftype;
    T.startt{qq} = iadata(qq).parameters.startTime;
end

for rr = 1:length(iidata)
    T.spiketimes{rr + qq} = iidata(rr).procdata.spiketimes;
    T.ifr{rr + qq} = iidata(rr).procdata.ifr;
    v = iidata(rr).procdata.dLmt;
    T.stretchv(rr + qq) = round(mean(v(v > 0.95*max(v))));
    T.afftype{rr + qq} = iidata(rr).parameters.afftype;
    T.startt{rr + qq} = iidata(rr).parameters.startTime;
end

% now the model part
close all

colors = mapColors([178,223,138]/255, [31,120,180]/255, length(unique(T.stretchv)));


for iarow = 1:14
    % use ia trial to match with a group II trial
    velcheck = T.stretchv == T.stretchv(iarow);
    cellcheck = strcmp(T.afftype, 'II');
    iirow = find(velcheck & cellcheck, 1, 'first');
    T.afftype{iirow} = 'IIprocessed';
    disp([iarow iirow])

    tia = T.spiketimes{iarow};
    tii = T.spiketimes{iirow};
    tmin = max([tia(1) tii(1)]);
    tmax = min([tia(end) tii(end)]);
    t = tmin:.0001:tmax;

    ria = interp1(tia, T.ifr{iarow}, t);
    rii = interp1(tii, T.ifr{iirow}, t);

    % figure
    % plot(t, ria, t, rii)
    % xlim([-.5 1.5])

    FF = Kinv*[ria; rii];
    
    colorrow = find(unique(T.stretchv) == T.stretchv(iarow));
    color = colors(colorrow, :);
    
    subplot(321)
    hold on
    plot(t, ria, 'Color', color)
    title('R_{IA}')
    subplot(322)
    hold on
    plot(t, rii, 'Color', color)
    title('R_{II}')

    subplot(312)
    hold on
    plot(t, FF(1, :), 'Color', color)
    xlim([-.25 1.5])
    title('decoded Force')
    subplot(313)
    hold on
    plot(t, FF(2, :), 'Color', color)
    xlim([-.25 1.5])
    title('decoded Yank')

end

print('/Users/jacobstephens/Documents/Figures/demixed.eps', '-depsc', '-painters')
%%
count = [1 1];

for n = 1:numel(d)
    if contains(d(n).name, 'triangle') && contains(d(n).name, ianum)
        iatridata(count(1)) = load([d(n).folder filesep d(n).name]);
        count(1) = count(1)+1;
    elseif contains(d(n).name, 'triangle') && contains(d(n).name, iinum)
        iitridata(count(2)) = load([d(n).folder filesep d(n).name]);
        count(2) = count(2)+1;
    end
end

for iarow = 1:14
    % use ia trial to match with a group II trial
    tia = iatridata(2).procdata.spiketimes;
    tii = iitridata(2).procdata.spiketimes;
    tmin = max([tia(1) tii(1)]);
    tmax = min([tia(end) tii(end)]);
    t = tmin:.0001:tmax;

    ria = interp1(tia, iatridata(2).procdata.ifr, t);
    rii = interp1(tii, iitridata(2).procdata.ifr, t);

    % figure
    % plot(t, ria, t, rii)
    % xlim([-.5 1.5])

    FF = Kinv*[ria; rii];
    
    colorrow = find(unique(T.stretchv) == T.stretchv(iarow));
    color = colors(colorrow, :);
    
    subplot(321)
    hold on
    plot(t, ria, 'Color', color)
    title('R_{IA}')
    xlim([-.5 4])
    subplot(322)
    hold on
    plot(t, rii, 'Color', color)
    title('R_{II}')
    xlim([-.5 4])

    subplot(312)
    hold on
    plot(t, FF(1, :), 'Color', color)
    title('decoded Force')
    xlim([-.5 4])

    subplot(313)
    hold on
    plot(t, FF(2, :), 'Color', color)
    title('decoded Yank')
    xlim([-.5 4])

end
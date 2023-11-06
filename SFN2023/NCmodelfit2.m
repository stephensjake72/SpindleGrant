clc
clear
close all

path = '\\cosmic.bme.emory.edu\labs\ting\shared_ting\Jake\SFN\procdata';
D = dir(path);
D = D(3:end);

savedir = '\\cosmic.bme.emory.edu\labs\ting\shared_ting\Jake\SFN\procdataNC_11_4';
if ~exist(savedir, 'dir')
    mkdir(savedir);
end

%% TRY W SQRT(LMTU)
close all

animals = {'A100401-21-78', 'A100401-21-82', 'A100401-22-116', 'A100401-22-129', 'A100401-22-96'};
ii = 5;
An = animals{ii};

K = zeros(1, 1e3);

L0est = 3;
Aest = .25;
kexpest = .3229;

for jj = 1:numel(D)
    
    % choose 1 animal at a time
    if ~contains(D(jj).name, An)
        continue
    end
    
    data = load([path filesep D(jj).name]);
    
    % skip if it's a 200 or 300 mN stretch
    if data.procdata.Fmt(1) > .12
        continue
    end
    
    % take data during lengthening, ignoring SRS
    win = data.procdata.Lmt > .5 & data.procdata.Lmt < 2.5 & data.procdata.vmt > 0;
    y = data.procdata.ymt(win);
    x = data.procdata.Fmt(win);
%     x0 = data.procdata.Fmt(win);
    
    % fit linear model to ymt/fmt curve during lengthening
    m = fitlm(x, y);
    
    % only use the slow triangles to estimate the k_exp
    if max(data.procdata.vmt) < 15
        K(jj) = m.Coefficients.Estimate(2)/max(data.procdata.vmt);
    end
    
%     figure(1)
    subplot(311)
    hold on
    plot(data.procdata.Fmt, data.procdata.ymt)
    subplot(312)
    hold on
    plot(x, y)
    subplot(313)
    hold on
    plot(data.procdata.Lmt, data.procdata.Fmt)
    plot(data.procdata.Lmt, Aest*exp(kexpest*(data.procdata.Lmt - L0est)), 'k')
    
    procdata = data.procdata;
    parameters = data.parameters;
    NC.k_exp = kexpest;
    NC.L0 = L0est;
    
    save([savedir filesep D(jj).name], 'procdata', 'parameters', 'NC')
end

K(K == 0) = [];
kest = mle(K);
kest(1)
%% fit A and L0 and check

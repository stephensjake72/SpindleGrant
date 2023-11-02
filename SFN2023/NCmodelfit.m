clc
clear
close all

path = '\\cosmic.bme.emory.edu\labs\ting\shared_ting\Jake\SFN\procdata';
D = dir(path);
D = D(3:end);

savedir = '\\cosmic.bme.emory.edu\labs\ting\shared_ting\Jake\SFN\procdataNC';
if ~exist(savedir, 'dir')
    mkdir(savedir);
end

%% FIND KEXP
close all

animals = {'A100401-21-78', 'A100401-21-82', 'A100401-22-116', 'A100401-22-129', 'A100401-22-96'};


ii = 4;
An = animals{ii};

K = zeros(1e3, 1);

for jj = 1:numel(D)
    if ~contains(D(jj).name, An)
        continue
    end
    data = load([path filesep D(jj).name]);

    win = data.procdata.vmt > .9*max(data.procdata.vmt);
    mdl = fitlm(data.procdata.Fmt(win), data.procdata.ymt(win));

    % extract model coefficients
    m = mdl.Coefficients.Estimate(2);
    b = mdl.Coefficients.Estimate(1);

    % estimate k_exp
    K(jj) = m/max(data.procdata.vmt);

%     plot(data.procdata.Fmt, data.procdata.ymt)
%     hold on
%     plot(data.procdata.Fmt, data.procdata.Fmt*m + b, 'k')
end
% hold off

K = K(K~=0);
kexp = mean(K);

% save kexp values to each file
for kk = 1:numel(D)
    if ~contains(D(kk).name, An)
        continue
    end
    
    % save parameter for the NC force model
    NCmod.kexp = 1.6*kexp;
    
    % load data
    data = load([path filesep D(kk).name]);
    
    procdata = data.procdata;
    parameters = data.parameters;
    
    % save data with NC model attached
    save([savedir filesep D(kk).name], 'procdata', 'parameters', 'NCmod')
end
%%
% Est L0
clear ii jj kk
close

minF = zeros(1, 1e3);

for jj = 1:numel(D)
    if ~contains(D(jj).name, An)
        continue
    end

    % load data
    data = load([savedir filesep D(jj).name]);
    
    % save parameters
    NCmod = data.NCmod;
    L0est = 3-(log(max(data.procdata.Fmt)))/(.5*NCmod.kexp);
    
    NCmod.L0 = L0est;
    
    F0 = data.procdata.Fmt(find(data.procdata.Lmt >= L0est, 1, 'first'));
    if ~isempty(F0)
        minF(jj) = F0;
    end
    
    hold on
    plot(data.procdata.Lmt - NCmod.L0, data.procdata.Fmt)
    save([savedir filesep D(jj).name], 'NCmod', '-append')
    
    clear NCmod
end
hold off
%%
minF = minF(minF ~= 0);
Aest = .175*min(minF);

for kk = 1:numel(D)
    if ~contains(D(kk).name, An)
        continue
    end
    
    % load data
    data = load([savedir filesep D(kk).name]);
    
    % save parameters
    NCmod = data.NCmod;
    NCmod.A = Aest;
    
    save([savedir filesep D(kk).name], 'NCmod', '-append')
    
    Fnc = NCmod.A*exp(NCmod.kexp*(data.procdata.Lmt - NCmod.L0));
    
    figure(1)
    hold on
    plot(data.procdata.Lmt - data.NCmod.L0, data.procdata.Fmt)
    plot(data.procdata.Lmt - NCmod.L0, Fnc, 'k')
    
    figure(2)
    hold on
    plot(data.procdata.time, data.procdata.Fmt - Fnc)
    
    figure(3)
    hold on
    plot(data.procdata.Lmt - data.NCmod.L0, data.procdata.Fmt - Fnc)
end
hold off

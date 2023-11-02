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

%% TRY W SQRT(LMTU)
close all

animals = {'A100401-21-78', 'A100401-21-82', 'A100401-22-116', 'A100401-22-129', 'A100401-22-96'};
ii = 1;
An = animals{ii};

K = zeros(1, 1e3);
R = zeros(1, 1e3);

for jj = 1:numel(D)
    
    if ~contains(D(ii).name, An)
        continue
    end
    
    data = load([path filesep D(jj).name]);
    
    win = data.procdata.Lmt > .5 & data.procdata.Lmt < 2.5 & data.procdata.vmt > 0;
    y = data.procdata.ymt(win);
    x = data.procdata.Lmt(win);
    x0 = data.procdata.Fmt(win);
    
    m = fitlm(x, y);
    K(jj) = m.Coefficients.Estimate(2);
    R(jj) = m.Rsquared.Ordinary;
    
    figure(1)
    subplot(211)
    hold on
    plot(x, y)
    
    subplot(212)
    hold on
    plot(x, log(y))
    
    figure(2)
    subplot(211)
    hold on
    scatter(x0(1), K(jj))
    title('slope vs F1')
    subplot(212)
    hold on
    scatter(x0(1), R(jj))
end

% hold off
% figure(1)
% subplot(211)
% xlabel('\Delta L_{MT}')
% ylabel('F_{MT}')
% subplot(212)
% xlabel('\Delta L_{MT}')
% ylabel('ln(F_{MT})')
% 
% figure(2)
% xlabel('F(\Delta L_{MT} = 1mm)')
% ylabel('ln(F)/\Delta L_{MT}')
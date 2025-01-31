clc; clear; figure
% close all
addpath(genpath('/Users/jacobstephens/Documents/GitHub/CustomMyoSimForSpindle/Results'))

parms.fp_custMyoSim = '/Users/jacobstephens/Documents/GitHub/SpindleGrant/MultiAffs';
addpath(genpath(parms.fp_custMyoSim));
parms.ActCurveDate = 20240711;

% intrafusal muscle models; bag
sarcB.pCa=[];
sarcB.act=[];
sarcB.initial_act = 15; % 15 for passive, 0 for taylor
sarcB.activating_act = 15; % 10 for taylor %  50 for active
sarcB.f=1200; % 600
sarcB.g=35; % 7
sarcB.power_stroke=2.5;
sarcB.hs_length=1300;
sarcB.hsl_slack=1050;
sarcB.k_passive=100;
sarcB.compliance_factor=0.5;
sarcB.checkSlack=1;
sarcB.isActin=1;
sarcB.act_phaseShift_s=0;
sarcB.act_amplitude=(sarcB.activating_act-sarcB.initial_act)/100;
sarcB.act_freq=1.5;

% intrafusal muscle models; chain
sarcC.pCa=[];
sarcC.act=[];
sarcC.initial_act = 10; % 35 for taylor; 15 forpassive
sarcC.activating_act = 65;% 65 for taylor; 50 for active
sarcC.f=275; % 400, 200
sarcC.g=50; % 300, 5, 200
sarcC.power_stroke=2.5;
sarcC.hs_length=1300;
sarcC.hsl_slack=1200;
sarcC.k_passive=250;
sarcC.compliance_factor=0.5;
sarcC.checkSlack=1;
sarcC.isActin=1;
sarcC.act_phaseShift_s=-0.33;
sarcC.act_amplitude=(sarcC.activating_act-sarcC.initial_act)/100;
sarcC.act_freq=1.5;

%% length change definition; pull from sonos

load('trisample.mat')

tic;
tinit = -1:mean(diff(trisample.time)):trisample.time(1);
t = [tinit, trisample.time]; % Time vector
pertStart = find(t > 0, 1, 'first');

numSims = 1

%%  activation definition

% delta_f_activated is a dummy. i need to change code so that we can delete
% it here and it doesn't give any errors. 
delta_f_activated = zeros(numSims, length(t));
delta_f_activated(1,1) = 0.3;

% the following is what actually defines the activation for the models

% active tonic
% sarcE.act = [(sarcE.initial_act/100)*ones(1,pertStart-500) (sarcE.activating_act/100)*ones(1,numel(t)-(pertStart-500))];
shift = 800;
sarcC.act = [(sarcC.initial_act/100)*ones(1,pertStart-shift) (sarcC.activating_act/100)*ones(1,numel(t)-(pertStart-shift))];
sarcB.act = [(sarcB.initial_act/100)*ones(1,pertStart-shift) (sarcB.activating_act/100)*ones(1,numel(t)-(pertStart-shift))];

% convert act to pCa

% pCatoAct = pCatoActFromSimForSpindle(parms, sarcE, sarcB, sarcC);
pCatoAct=load('ActivationCurve20240408.mat');

% sarcE.pCa = interp1(pCatoAct.fracBoundNormE,pCatoAct.pCaList,sarcE.act);
sarcC.pCa = interp1(pCatoAct.fracBoundNormC,pCatoAct.pCaList,sarcC.act);
sarcB.pCa = interp1(pCatoAct.fracBoundNormB,pCatoAct.pCaList,sarcB.act);

%% muscles generate force

delta_cdlI = zeros(numSims, length(t)+1);

for a = 1:numSims

    % sonos to cdl scaling factor
    % multiply by dt to get from vel to length change, divide by 25 mm to
    % get percent L0, then multiply by half sarc length
    sf = 0.75*sarcB.hs_length*15/25;

   % delta_cdlI=zeros(1,round(pertStart));
   delta_cdlI(a, :) = [zeros(1, length(tinit) + 1) sf*trisample.dLf(a, :)];
   % delta_cdlI(a,:) = delta_cdlE(a,:);

   [hsB(a, :), dataB(a, :), hsC(a, :), dataC(a, :)] = ...
       sarcSimDriverIntrafusal20240310(t, ...
       delta_f_activated, ...
       delta_cdlI(a,:), ...
       sarcB, ...
       sarcC);
   

   disp(['Done with simulation number ' num2str(a)])

end

load('done.mat')
sound(y, 44100); toc;

%% force to spindle firing
for a = 1:numSims
    [r_t(a,:), hsL(a,:), mL(a,:), r(a,:),rs(a,:),rd(a,:)] = ...
        sarc2spindle_20240310(dataB(a), ...
        dataC(a), ...
        600, ... %kFc 1.5
        50, ... %kFb 0.4
        100, ... %kYb .005
        0, ... %occ 0
        1100); % thr 0
end

% save results
results.ia.dataB = dataB;
results.ia.dataC = dataC;
results.ia.r = r;
results.ia.r_t = r_t;
results.ia.rd = rd;
results.ia.rs = rs;
results.ia.sarcB = sarcB;
results.ia.sarcC = sarcC;


for a = 1:numSims
    [r_t(a,:), hsL(a,:), mL(a,:), r(a,:),rs(a,:),rd(a,:)] = ...
        sarc2spindle_20240310(dataB(a), ...
        dataC(a), ...
        400, ... %kFc 1.5
        0, ... %kFb 0.4
        0, ... %kYb .005
        0, ... %occ 0
        700); % thr 0
end
results.ii.dataB = dataB;
results.ii.dataC = dataC;
results.ii.r = r;
results.ii.r_t = r_t;
results.ii.rd = rd;
results.ii.rs = rs;
results.ii.sarcB = sarcB;
results.ii.sarcC = sarcC;

% d = dir(savedir);
% simNum = sum(contains({d.name}', char(datetime('today')))) + 1;
% save([savedir filesep 'trisims' char(datetime('today')) 'sim' num2str(simNum) '.mat'], 'results')
save('trisims.mat', 'results')

beep; toc;
% plotting
% convert pCa abck to activation using activation code that should have been previouly run and results saved
% sarcE.actToPlot = interp1(pCatoAct.pCaList,pCatoAct.fracBoundNormE,(sarcE.pCa));
sarcC.actToPlot = interp1(pCatoAct.pCaList,pCatoAct.fracBoundNormC,(sarcC.pCa));
sarcB.actToPlot = interp1(pCatoAct.pCaList,pCatoAct.fracBoundNormB,(sarcB.pCa));  

for ii = 1:numSims
    subplot(3, 2, [1 2])
    hold on
    plot(r_t', r')
    title({['bag f: ' num2str(sarcB.f) ' bag g: ' num2str(sarcB.g)]; ...
        ['chain f: ' num2str(sarcC.f) ' chain g: ' num2str(sarcC.g)]})
    subplot(323)
    hold on
    plot(dataB(ii).t, dataB(ii).hs_force)
    title('bag_1 force')
    subplot(324)
    hold on
    plot(dataC(ii).t, dataC(ii).hs_force)
    title('bag_2 c force')
    subplot(325)
    hold on
    plot(dataB(ii).t, dataB(ii).hs_length)
    title('bag_1 length')
    subplot(326)
    hold on
    plot(dataC(ii).t, dataC(ii).hs_length)
    title('bag_2 c length')
end

% breaks = [0, 1.5, 3];
% p1 = r_t > 0 & r_t < 1;
% p2 = r_t > 1.5 & r_t < 2.5;
% p3 = r_t > 3 & r_t < 4;
% A1 = trapz(r(p1))
% A2 = trapz(r(p2))
% A3 = trapz(r(p3))
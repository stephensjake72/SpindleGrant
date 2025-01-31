%% pCa to act values
% this code runs some isometric simualtion trials at differnet pCa levels
% to get the activation curve for the muscle model of choice. it converts
% pCa. pCa is a measure of the concentration of calcium ions in a
% solutions. It goes from pCa 4.5 to 9, where 4.5 is the highest pCa is a
% direct input for our crossbridge models. To convert it to activatoin
% levels, this code determines the fraction of crossbridges bound at each
% pCa level. It then determines the fraction of crossbridges at each
% activation level as a percentage of that bound at pCa 4.5 (i.e.,max
% activation). We use this as percent activation and is the y-axis of the
% activation curve

function pCatoAct = pCatoActFromSimForSpindle(parms, sarcE, sarcB, sarcC)
% clear
% close all

% Location of the path where code lives
parms.fp_custMyoSim = '/Users/surabhisimha/GitHub/Emory/CustomMyoSimForSpindle/';
addpath(genpath(parms.fp_custMyoSim));


cm = parula(5);
parms.MTUtoFibre=0.8; % this does not matter here since we do not include a tendon in estimating the activation curve
parms.time_step = 0.001;

%used in saving of file name and location
parms.act_for_fn = 'pCa45'; %'pCa64'; 'Act3';
parms.date = 20240408;


% properties of the extrafusal and intrafusal fibers
sarcE.pCa=[];
% sarcE.power_stroke=2.5;
sarcE.isTendon=0;

% sarcE.hsl_slack=850;
sarcE.k_passive=0;
% sarcE.compliance_factor=0.5;
% sarcE.tendon_stiffness=5e3;
sarcE.initial_pCa=9;
sarcE.activating_pCa=4.5;
% sarcE.hs_length=1300;

sarcB.pCa=[];
% sarcB.f=600;
% sarcB.g=7;
% sarcB.power_stroke=2.5;
% sarcB.hs_length=1300;
% sarcB.hsl_slack=1050;
% sarcB.k_passive=100;
% sarcB.compliance_factor=0.5;
% sarcB.checkSlack=0;
% sarcB.isActin=1;

sarcC.pCa=[];
% sarcC.f=400;
% sarcC.g=300;
% sarcC.power_stroke=2.5;
% sarcC.hs_length=1300;
% sarcC.hsl_slack=1200;
% sarcC.k_passive=250;
% sarcC.compliance_factor=0.5;
% sarcC.checkSlack=0;
% sarcC.isActin=1;

%% protocol definition

trialDur = 1*1/parms.time_step;
delta_cdl=zeros(1,round(trialDur));
t = [0:parms.time_step:(numel(delta_cdl)-1)*parms.time_step];

% delta_f_activated is not needed anymore. i need to fix code to take this
% out, until then it is here
delta_f_activated = zeros(size(delta_cdl)); 
delta_f_activated(1,1) = 0;

pCaList = [9, 8.75, 8.5, 8.25, 8, 7.75, 7.5, 7.25 linspace(7,5.5,30), 5.25, 5, 4.75, 4.5];
% [9, 8.8, 8.6, 8.4, 8.2, 8, 7.8, 7.6, 7.4, 7.2, 7, 6.875, 6.75 6.625, 6.5, 6.375, 6.25 6, 5.5, 5, 4.5];

for i=1:numel(pCaList)

    parms.pCa = pCaList(i);
    sarcE.pCa = parms.pCa*ones(size(t));
    sarcC.pCa = parms.pCa*ones(size(t));
    sarcB.pCa = parms.pCa*ones(size(t));

    [hsE, dataE] = musTenDriver20240322(t,delta_f_activated,delta_cdl,sarcE);
    [hsB,dataB,hsC,dataC] = sarcSimDriverIntrafusal20240310(t,delta_f_activated,delta_cdl,sarcB,sarcC);

    fracBoundE(i) = dataE.f_bound(end);
    fracBoundB(i) = dataB.f_bound(end);
    fracBoundC(i) = dataC.f_bound(end);
    maxForceE(i) = dataE.hs_force(end);
    maxForceB(i) = dataB.hs_force(end);
    maxForceC(i) = dataC.hs_force(end);

    figure(99);hold on;
    subplot(211);hold on; grid on;plot(dataE.t,dataE.hs_force)
      ylabel('stress [Nm^2]')
    subplot(212);hold on; grid on;plot(dataE.t,dataE.f_bound)
      ylabel('fraction xbridges bound')
      xlabel('time [s]')

end
%%
fracBoundNormE = fracBoundE/(max(fracBoundE));fracBoundNormE(1)=0;
fracBoundNormC = fracBoundC/(max(fracBoundC));fracBoundNormC(1)=0;
fracBoundNormB = fracBoundB/(max(fracBoundB));fracBoundNormB(1)=0;

pCatoAct.fracBoundNormE = fracBoundNormE;
pCatoAct.fracBoundNormB = fracBoundNormB;
pCatoAct.fracBoundNormC = fracBoundNormC;

maxForceNormE = (maxForceE-min(maxForceE))/(max(maxForceE-min(maxForceE)));maxForceNormE(1)=0;
maxForceNormC = (maxForceC-min(maxForceC))/(max(maxForceC-min(maxForceC)));maxForceNormC(1)=0;
maxForceNormB = (maxForceB-min(maxForceB))/(max(maxForceB-min(maxForceB)));maxForceNormB(1)=0;

save(strcat(parms.fp_custMyoSim,'/Results/ActivationCurve',num2str(parms.date),'.mat'),'fracBoundNormC','fracBoundNormB','fracBoundNormE','pCaList')
% %%
% % load(strcat(parms.fp_custMyoSim,'/Results/ActivationCurve',num2str(parms.date),'.mat'))
% figure(100);clf;hold on;grid on;figurefyTalk
%   plot(pCaList,maxForceNormE,'Color',cm(4,:))
%   plot(pCaList,maxForceNormC,'Color',cm(3,:))
%   plot(pCaList,maxForceNormB,'Color',cm(2,:))
%   xlabel('pCa')
%   ylabel('percentage max xbridges bound')
%   legend('extrafusal','chain','bag')
% 
% figure(3);clf;hold on;figurefyTalk
%     subplot(211);hold on; grid on; figurefyTalk
%       plot(hsE.x_bins,hsE.f,'Color',cm(4,:))
%       plot(hsC.x_bins,hsC.f,'Color',cm(3,:))
%       plot(hsB.x_bins,hsB.f,'Color',cm(2,:))
%       ylabel('attachment rate [s^{-1}]')
%       legend('extrafusal','chain','bag')
%     subplot(212);hold on; grid on; figurefyTalk
%       plot(hsE.x_bins,hsE.g,'Color',cm(4,:))
%       plot(hsC.x_bins,hsC.g,'Color',cm(3,:))
%       plot(hsB.x_bins,hsB.g,'Color',cm(2,:))
%       legend('extrafusal','chain','bag')
%       xlabel('delta x');
%       ylabel('detachment rate [s^{-1}]')
%     figurefyTalk
end
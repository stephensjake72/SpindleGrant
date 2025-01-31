clear
addpath(genpath('/Users/jacobstephens/Documents/GitHub/CustomMyoSimForSpindle/Results'))
parms.fp_custMyoSim = '/Users/jacobstephens/Documents/GitHub/SpindleGrant/MultiAffs';
% /Users/surabhisimha/GitHub/Emory/CustomMyoSimForSpindle/';
addpath(genpath(parms.fp_custMyoSim));
parms.ActCurveDate = 20240711;

% defining properties of the muscle models

% extrafusal muscle model
sarcE.pCa=[];
sarcE.act=[];
sarcE.initial_act = 25; % 25 for Taylor 2006; 15 for "passive"
sarcE.activating_act = 50; % 50 for Taylor 2006 50 for "active"
sarcE.power_stroke=2.5;
sarcE.hs_length=1300;
sarcE.hsl_slack=850;
sarcE.k_passive=5;
sarcE.compliance_factor=0.5;
sarcE.tendon_stiffness=5e3;
sarcE.act_phaseShift_s=-0.33;
sarcE.act_amplitude=(sarcE.activating_act-sarcE.initial_act)/100;
sarcE.act_freq=1.5;
sarcE.isTendon=1;

% intrafusal muscle models; bag
sarcB.pCa=[];
sarcB.act=[];
sarcB.initial_act = 15; % 15 for passive, 0 for taylor
sarcB.activating_act = 10; % 10 for taylor %  50 for active
sarcB.f=600;
sarcB.g=7;
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
sarcC.initial_act = 35; % 35 for taylor; 15 forpassive
sarcC.activating_act = 65;% 65 for taylor; 50 for active
sarcC.f=400;
sarcC.g=300;
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

 %% length change definition; sinusoid

    tic
    time_step = 0.001; %Temporal precision
    t = 0:time_step:3.5; % Time vector
    pertStart = 1500; % when the length changes start
    numSims = 1;       % Number of simulations to run in parallel
    delta_cdlprePertE=zeros(1,round(pertStart)); % change in command length for all sims
    ampList = 2;
    freq = 1.5; %0.25 Hz taken from Day et al. 2017 for passive but using 1.5 because 0.25 is so slow!; 1.5Hz from Emonet-Denand 1977 for active

    for i=1:numel(ampList)
        cdl(i,:) =((ampList(i)/100)*sarcE.hs_length)*sin(2*pi*freq*(t(pertStart:end)-t(pertStart)));
        delta_cdlE(i,:) = [delta_cdlprePertE(1:end), diff(cdl(i,:))]; %sine
    end
    numSims=numel(ampList);


%%  % activation definition
% delta_f_activated is a dummy. i need to change code so that we can delete
% it here and it doesn't give any errors. 
    delta_f_activated = zeros(size(delta_cdlE));
    delta_f_activated(1,1) = 0.3;

% the following is what actually defines the activation for the models

    % active tonic
    % sarcE.act = [(sarcE.initial_act/100)*ones(1,pertStart-500) (sarcE.activating_act/100)*ones(1,numel(t)-(pertStart-500))];
    sarcC.act = [(sarcC.initial_act/100)*ones(1,pertStart-500) (sarcC.activating_act/100)*ones(1,numel(t)-(pertStart-500))];
    sarcB.act = [(sarcB.initial_act/100)*ones(1,pertStart-500) (sarcB.activating_act/100)*ones(1,numel(t)-(pertStart-500))];

% convert act to pCa

% pCatoAct = pCatoActFromSimForSpindle(parms, sarcE, sarcB, sarcC);
pCatoAct=load('ActivationCurve20240408.mat');

% sarcE.pCa = interp1(pCatoAct.fracBoundNormE,pCatoAct.pCaList,sarcE.act);
sarcC.pCa = interp1(pCatoAct.fracBoundNormC,pCatoAct.pCaList,sarcC.act);
sarcB.pCa = interp1(pCatoAct.fracBoundNormB,pCatoAct.pCaList,sarcB.act);

%% muscles generate force

% pull sonos data for length changes

   for a = 1:numSims
       % [hsE(a), mtData(a)] = musTenDriver20240322(t,delta_f_activated(a,:),delta_cdlE(a,:),sarcE);

%        delta_cdlI=zeros(1,round(pertStart));
       delta_cdlI(a,:) = [0 diff(mtData(a).hs_length)];
%        delta_cdlI(a,:) = delta_cdlE(a,:);

       [hsB(a),dataB(a),hsC(a),dataC(a)] = sarcSimDriverIntrafusal20240310(t,delta_f_activated(a,:),delta_cdlI(a,:),sarcB,sarcC);
       disp(['Done with simulation number ' num2str(a)])
    end
    
    beep; toc;
%% force to spindle firing
    for a = 1:numSims
        [r_t(a,:), hsL(a,:), mL(a,:), r(a,:),rs(a,:),rd(a,:)] = sarc2spindle_20240310(dataB(a),dataC(a),0.5,0.4,0.005,0,0); %1.5,0.4,0.005,0,0 
    end
    
    beep; toc;
    %% plotting
  % convert pCa abck to activation using activation code that should have been previouly run and results saved
 % sarcE.actToPlot = interp1(pCatoAct.pCaList,pCatoAct.fracBoundNormE,(sarcE.pCa));
 sarcC.actToPlot = interp1(pCatoAct.pCaList,pCatoAct.fracBoundNormC,(sarcC.pCa));
 sarcB.actToPlot = interp1(pCatoAct.pCaList,pCatoAct.fracBoundNormB,(sarcB.pCa));  

%     cm=parula(10);
%     lineOpacity=1;
% for i=1:size(dataB,2) 
%     figure(899);hold on;
%     ax(3)=subplot(313);hold on;
%         plot(mtData(i).t,sarcE.actToPlot,'color',[cm(9,:) lineOpacity],'LineWidth',4);
%         plot(dataC(i).t,sarcC.actToPlot,'color',[cm(4,:) lineOpacity],'LineWidth',3);
%         plot(dataB(i).t,sarcB.actToPlot,'color',[cm(6,:) lineOpacity],'LineWidth',2);
% %         plot(dataB(i).t,sarcB.pCa,'color',[cm(6,:) lineOpacity],'LineWidth',2);
%         ylabel('activation');xlabel('time (s)');
%         ylim([0 1])
%     ax(2)=subplot(312);hold on;
%         plot(t,((cumsum(delta_cdlE(i,:))+sarcE.hs_length)./sarcE.hs_length),'k-','LineWidth',3);
%         plot(mtData(i).t,mtData(i).hs_length/sarcE.hs_length,'Color',[cm(9,:) lineOpacity],'LineWidth',9);
%         plot(dataC(i).t,dataC(i).hs_length/sarcC.hs_length,'color',[cm(4,:) lineOpacity],'LineWidth',6);
%         plot(dataB(i).t,dataB(i).hs_length/sarcB.hs_length,'color',[cm(6,:) lineOpacity],'LineWidth',3);
%         ylabel('length/L0');xlabel('time (s)');legend('commanded','extrafusal','chain','bag')  
% %         legend('extrafusal','chain','bag'); ylim([0 1])
% %     ax(4)=subplot(412);hold on;grid on;figurefyTalk()
% %         plot(mtData(i).t,mtData(i).hs_force,'color',[cm(9,:) lineOpacity],'LineWidth',3);
% %         plot(dataC(i).t,dataC(i).hs_force,'color',[cm(4,:) lineOpacity],'LineWidth',3);
% %         plot(dataB(i).t,dataB(i).hs_force,'color',[cm(6,:) lineOpacity],'LineWidth',3);
% %         ylabel('force');xlabel('time (s)');legend('extrafusal','chain','bag')
%     ax(1)=subplot(311);hold on;
% %         plot(r_t(i,:),rs(i,:),'color',[cm(3,:) lineOpacity],'LineWidth',3);
% %         plot(r_t(i,:),rd(i,:),'color',[cm(2,:) lineOpacity],'LineWidth',3);
%         plot(r_t(i,:),(r(i,:)-r(1)),'color',[cm(1,:) lineOpacity],'LineWidth',3);
% %         plot(xlim,[r(pertStart-1) r(pertStart-1)],'Color',[0 0 0 0.3])
%         ylabel('current');xlabel('time (s)');
%         ylim([0 0.8]) 
%         linkaxes(ax,'x');xlim([0 3]);
%     %     pause
% 
% mtData.cmd_lengthNorm = mtData.cmd_length/sarcE.hs_length;
% mtData.hs_lengthNorm =  mtData.hs_length/sarcE.hs_length;
% dataC.hs_lengthNorm = dataC.hs_length/sarcC.hs_length;
% dataB.hs_lengthNorm = dataB.hs_length/sarcB.hs_length;
% 
% end

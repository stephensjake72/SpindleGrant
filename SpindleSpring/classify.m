% Classifying stretch types
% Author: JDS
% Updated 5/22/23
clc
clear
close all

% Load data files
source = '/Volumes/labs/ting/shared_ting/Jake/';
path = uigetdir(source);
D = dir(path);

D = D(3:end);
%% create sample traces with which to sort stretches
sampleRampData = load([path filesep D(3).name]);
sampleRamp = (sampleRampData.recdata.Lmt - sampleRampData.recdata.Lmt(1))/3;
n = 5e4;
sampleTriData = load([path filesep D(12).name]);
sampleTri = (sampleTriData.recdata.Lmt(1:n) - sampleTriData.recdata.Lmt(1))/3;
sampleSineData = load([path filesep D(123).name]);
sampleSine = (sampleSineData.recdata.Lmt(1:n) - sampleSineData.recdata.Lmt(1))/2;

subplot(311)
plot(sampleRamp)
subplot(312)
plot(sampleTri)
subplot(313)
plot(sampleSine)
%% sort
close all
ntrial = numel(D);
R1 = zeros(1, ntrial);
R2 = zeros(1, ntrial);
R3 = zeros(1, ntrial);

for ii = 1:ntrial
    % load MTU length trace
    data = load([path filesep D(ii).name]);
    Lmt = data.recdata.Lmt - data.recdata.Lmt(1);
    % only take the early part of the stretch
    if length(Lmt) > 6e4
        Lmt = Lmt(1:6e4);
    end
    %scale
    Lmt = Lmt/max(Lmt);
    
    % load parameters
    parameters = data.parameters;
    
    % get correlations
    r1 = xcorr(Lmt, sampleRamp);
    r2 = xcorr(Lmt, sampleTri);
    r3 = xcorr(Lmt, sampleSine);
    % save correlations to vectors to plot and find discrimination
    % thresholds
    R1(ii) = max(r1);
    R2(ii) = max(r2);
    R3(ii) = max(r3);
    
    % sort according to correlation thresholds
    % thresholds were determined by plotting ramp, tri and sine correlation
    % values against each other and trial and error
    if R2(ii) < 4e3 % sine threshold
        parameters.type = 'sine';
        
        subplot(131)
        hold on
        plot(data.recdata.Lmt - data.recdata.Lmt(1))
    elseif R2(ii) > 4e3 && R2(ii) < 11.5e3 % triangle threshold
        parameters.type = 'triangle';
        
        subplot(132)
        hold on
        plot(data.recdata.Lmt - data.recdata.Lmt(1))
    else
        parameters.type = 'ramp';
        
        subplot(133)
        hold on
        plot(data.recdata.Lmt - data.recdata.Lmt(1))
    end
    
    save([path filesep D(ii).name], 'parameters', '-append')
end
% plot correlation values against each other to check separability
% figure
% subplot(311)
% scatter(R1, R2, 'xk')
% xlabel('R1')
% ylabel('R2')
% subplot(312)
% scatter(R2, R3, 'xk')
% xlabel('R2')
% ylabel('R3')
% subplot(313)
% scatter(R1, R3, 'xk')
% xlabel('R1')
% ylabel('R3')
%% plot to check
figure
for jj = 1:numel(D)
    data = load([path filesep D(jj).name]);
    
    switch data.parameters.type
        case 'ramp'
            subplot(311)
            hold on
            plot(data.recdata.Lmt)
        case 'triangle'
            subplot(312)
            hold on
            plot(data.recdata.Lmt)
        case 'sine'
            subplot(313)
            hold on
            plot(data.recdata.Lmt)
    end
end
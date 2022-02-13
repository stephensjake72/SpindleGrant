% Data Sorting
% Author: JDS
% Updated: 2/11/2022
% the purpose of this script is to go through the data exported from Spike2
% and put them in the proper format for analysis
clear
clc
% Load data files
source = '\\cosmic.bme.emory.edu\labs\ting\shared_ting\Jake\Spindle_Grant\RawData';

D = dir(source);
D = D(3:end);

for ii = 1:numel(D)
    data = load([D(ii).folder filesep D(ii).name]);
    
    % unpack data to recdata structure
    recdata.Fmt.times = data.motor_F.times;
    recdata.Fmt.values = data.motor_F.values;
    recdata.Lmt.times = data.motor_L.times;
    recdata.Lmt.values = data.motor_L.values;
    recdata.Lf.times = data.sonos.times;
    recdata.Lf.values = data.sonos.values;
    recdata.spiketimes = data.Memory.times;
    recdata.startTime = data.ramptrig.times;
    
    expName = D(ii).name;
    % use spaces to get parameters from title
    stops = find(expName == ' ');
    ratIDstr = expName(1:stops(1) - 1);
    cellstr = expName(stops(2):stops(3));
    fstr = expName(stops(3):stops(4));
    astr = expName(stops(4):end);
    % separate string chunks to get numerical values
    parameters.ID = ratIDstr(1:end);
    parameters.cell = cellstr(2:end-1);
    parameters.freq = str2double(fstr(find(fstr == '_') + 1:end - 1));
    parameters.amp = str2double(astr(find(astr == '_') + 1:strfind(astr, '.smrx') - 1));
    
    folderName = ratIDstr;
    saveName = ['exp' num2str(ii)];
    saveDir = '\\cosmic.bme.emory.edu\labs\ting\shared_ting\Jake\Spindle_Grant\Data';
    if ~exist(saveDir, 'dir')
        mkdir(saveDir)
    end
    if ~exist([saveDir filesep folderName], 'dir')
        mkdir([saveDir filesep folderName])
    end
    save([saveDir filesep folderName filesep saveName], 'recdata', 'parameters', '-mat')
end
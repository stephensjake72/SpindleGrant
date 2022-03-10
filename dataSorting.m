% Data Sorting
% Author: JDS
% Updated: 2/14/2022
% The purpose of this script is to go through the data exported from Spike2
% and put them in the proper format for analysis.
% The code is currently written for animal A100401-22-91. Code may need to
% be adjusted according to individual animals.
clear
clc
close all
% Load data files
source = 'C:\\Users\Jake\Documents\Spindle_Grant\RawData';

D = dir(source);
D = D(3:end);

% keys to pair variable names with channel numbers
ckeys = {'Vm', 'Ch2'; 
    'Fmt', 'Ch3'; 
    'Lmt', 'Ch4'; 
    'ramptrig', 'Ch7'; 
    'Lf', 'Ch9'};

for ii = 1:numel(D)
    disp(ii)
    data = load([D(ii).folder filesep D(ii).name]);
    
    % get channel names
    cnames = fieldnames(data);
    % get channel numbers
    cnums = zeros(1, length(cnames));
    for jj = 1:numel(cnums)
        % convert channel number in the title to an actual numerical value
        cnums(jj) = str2double(cnames{jj}(3:end));
    end
    
    % NUMERICAL DATA EXTRACTION
    affcount = 1;
    for kk = 1:numel(cnames)
        if cnums(kk) > 10
            % channels numbered > 10 correspond to spiketimes
            % if the number is > 10, assign to an afferent variable
            % affcount will increase each iteration so if another aff
            % channel is encountered, it will assign it to a variable
            % 'aff2'
            recdata.(['aff' num2str(affcount)]).times = data.(cnames{kk}).times;
            affcount = affcount + 1;
        else
            % find the variable name corresponding to the channel name from
            % the keys cell
            [row, ~] = find(strcmp(ckeys, cnames{kk}) == 1);
            % if the current channel is the ramp trigger channel
            if strcmp(ckeys{row, 1}, 'ramptrig')
                parameters.(ckeys{row, 1}).time = data.(cnames{kk}).times;
            else
                recdata.(ckeys{row, 1}) = data.(cnames{kk}).values;
            end
        end
    end
    recdata.time = (1:length(recdata.Vm))*data.Ch2.interval - data.Ch2.interval;
    
    % PARAMETER EXTRACTING
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
    
    if strcmp(parameters.cell, '1') || strcmp(parameters.cell, '1a')
        if length(recdata.aff1.times) > length(recdata.aff2.times)
            parameters.aff1type = 'II';
            parameters.aff2type = 'Ib';
        else
            parameters.aff1type = 'Ib';
            parameters.aff2type = 'II';
        end
    else
        parameters.aff1type = 'Ia';
    end
    
    folderName = ratIDstr;
    saveName = ['exp' num2str(ii) '.mat'];
    saveDir = '\\cosmic.bme.emory.edu\labs\ting\shared_ting\Jake\Spindle_Grant\Data';
    if ~exist(saveDir, 'dir')
        mkdir(saveDir)
    end
    if ~exist([saveDir filesep folderName], 'dir')
        mkdir([saveDir filesep folderName])
    end
    save([saveDir filesep folderName filesep saveName], 'recdata', 'parameters')
    clear recdata
end
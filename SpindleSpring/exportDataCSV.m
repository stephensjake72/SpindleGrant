% Export big data csv
clc
clear
close all

% access functions
addpath(genpath('Functions'));

% Load data files
path = uigetdir();
D = dir(path);
savedir = path(1:find(path == filesep, 1, 'last'));
D = D(3:end);

%% create empty table
% load sample file
sample = load([D(1).folder filesep D(1).name]);

% pull variable names from sample file
datafields = [fieldnames(sample.parameters); fieldnames(sample.procdata)];

% take variable names, ignoring the start time and activation fields
% because these are only relevant to processing the raw data
VarNames = datafields(~strcmp(datafields, 'startT') & ~strcmp(datafields, 'act'));

% set variable types for the table
VarTypes = {'string', 'string', 'string', 'string', 'string', ...
    'double', 'double', 'double', 'double', 'double', 'double', 'double', ...
    'doublenan', 'doublenan'};
% the columns for spiketimes and firing rates will be initially saved as NaN
% because they'll be a different length than the other data vectors

% create the data table
dataTable = table('Size', [2e6 numel(VarNames)], ...
    'VariableNames', VarNames, 'VariableTypes', VarTypes);

%% populate the table
% set a row counter
rowStart = 1;

% set our fields to pull data from
fields = {'parameters', 'procdata'};

% loop through trial files
for ii = 1:numel(D)
    disp(ii)
    
    % load data
    data = load([D(ii).folder filesep D(ii).name]);
    
    % iterate through the parameter and numerical data substructures
    for jj = 1:2
        
        % set the subfield
        subfield = fields{jj};
        
        % grab the entries
        % for the parameter subfield this is the ID, cell number, etc
        % for the procdata subfield, this is time, motor disp., etc
        entries = fieldnames(data.(subfield));
        
        % get the vector length for the numerical data
        rowStop = rowStart + length(data.procdata.time) - 1;
        
        % iterate through the entries
        for kk = 1:numel(entries)
            
            % grab the name of the current entry
            entryName = entries{kk};
            
            % skip if it's not an entry in the table
            if ~any(strcmp(VarNames, entryName))
                continue
            end
            
            % check whether the entry is a string/character or numerical
            % vector
            switch class(data.(subfield).(entryName))
                
                % if a string/character
                case 'char'
                    dataTable.(entryName){rowStart} = data.(subfield).(entryName);
                    dataTable.(entryName)(rowStart + 1:rowStop) = '';
                    
                % if numerical data
                case 'double'
                    
                    % grab the length of the data vector
                    vecL = length(data.(subfield).(entryName));
                    
                    % fill in the data
                    dataTable.(entryName)(rowStart:rowStart + vecL - 1) = data.(subfield).(entryName);
            end
        end    
    end
    
    % shift the starting row for the next trial
    rowStart = rowStop + 1;
%     disp(rowStart)
end
%%
writetable(dataTable, [savedir filesep 'dataTable.csv'])
% run this script after dataProcessing

clc; clear; close all


addpath(genpath('Functions'))

% loc = '/Volumes/labs/ting/shared_ting/Jake/Workloop/';
loc = '/Users/jacobstephens/Documents/Data/Workloop/';

d = dir(loc);

%%
vars = {'FileAddress', 'Animal', 'cellid', 'cellnum', 'celltype', 'stretchtype', ...
    'amp', 'phase'};
datatypes = {'string', 'string', 'string', 'string', 'string', 'string', ...
    'double', 'double'};

T = table('Size', [1e4, length(vars)], 'VariableTypes', datatypes, ...
    'VariableNames', vars);
%%
row = 1;
for n = 1:length(d)
    if ~contains(d(n).name, 'A100')
        continue
    else
        subdir = dir([d(n).folder filesep d(n).name filesep 'procdata']);
    end

    if isempty(subdir)
        continue
    end

    for m = 3:length(subdir)
        if ~contains(subdir(m).name, '.mat')
            continue
        end
        fileaddress = [subdir(m).folder filesep subdir(m).name];
        data = load(fileaddress);
        
        T.FileAddress{row} = fileaddress;
        T.Animal{row} = data.parameters.ID;
        T.cellnum{row} = data.parameters.cell;
        T.cellid{row} = [data.parameters.ID '-' data.parameters.cell];
        T.celltype{row} = data.parameters.aff;
        T.stretchtype{row} = data.parameters.type;
        T.amp(row) = data.parameters.amp;
        T.phase(row) = data.parameters.stimphase;

        row = row + 1;
    end
end
T(row:end, :) = [];
%%
save('lookuptable.mat', 'T', '-mat')
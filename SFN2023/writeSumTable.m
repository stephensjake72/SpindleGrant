clc
clear
close all
addpath(genpath('Functions'))

source = uigetdir('/Volumes/labs/ting/shared_ting/Jake/SFN');
savedir = '/Volumes/labs/ting/shared_ting/Jake/SFN';

D = dir(source);
D = D(3:end);
%%
sample = load([D(1).folder filesep D(1).name]);
 
datafields = fieldnames(sample);
VarNames = cell(100, 1);
VarTypes = cell(100, 1);
n = 1;
for ii = 1:numel(datafields)
    subfields = fieldnames(sample.(datafields{ii}));
    for jj = 1:numel(subfields)
        check1 = strcmp(class(sample.(datafields{ii}).(subfields{jj})), 'char');
        check2 = strcmp(class(sample.(datafields{ii}).(subfields{jj})), 'double');
        check3 = length(sample.(datafields{ii}).(subfields{jj})) == 1;
        if check1
            VarNames{n} = subfields{jj};
            VarTypes{n} = 'string';
            n = n + 1;
        elseif check2 && check3
            VarNames{n} = subfields{jj};
            VarTypes{n} = 'double';
            n = n + 1;
        end
    end
end
 
keep = find(~cellfun(@isempty, VarNames));
VarNames = [VarNames(keep); 'Address'];
VarTypes = [VarTypes(keep); 'string'];
%%
sumTable = table('Size', [numel(D) numel(VarNames)], ...
    'VariableNames', VarNames, 'VariableTypes', VarTypes);
 
for pp = 1:numel(D)
    disp(pp)
    data = load([D(pp).folder filesep D(pp).name]);
    fields = fieldnames(data);
    
    sumTable.Address{pp} = [D(pp).folder filesep D(ii).name];
    for qq = 1:numel(fields)
        field = fields{qq};
        subfields = fieldnames(data.(field));
        for rr = 1:numel(subfields)
            subfield = subfields{rr};
            if strcmp(class(data.(field).(subfield)), 'char')
                sumTable.(subfield){pp} = convertStringsToChars(data.(field).(subfield));
            elseif strcmp(class(data.(field).(subfield)), 'double') && length(data.(field).(subfield)) == 1
                sumTable.(subfield)(pp) = data.(field).(subfield);
            end
        end
    end
end
 
writetable(sumTable, [savedir filesep 'summary' char(datetime('today')) '.csv'])

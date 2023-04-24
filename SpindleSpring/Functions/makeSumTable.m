function SumTable = makeSumTable(path)
% the purpose of this function is to summarize all the variables and
% parameters in the data set following analysis, that way a table can be
% made to quickly analyze data based on groups. It does so by searching
% data files and pulling out any value that's a string (for parameters like
% series elastic stiffness) or single scalars like initial burst. To
% run, input a path to whatever data folder and the script will make a
% table summarizing the data in that folder. It also requires all the data
% files to have the same fields, so in the script if a data point isn't
% applicable (example initial burst for a group Ib afferent) the field
% should be saved as a NaN
disp('Making table ...')

D = dir(path); % geet directory info for the selected path
filerows = contains({D.name}', '.mat'); % get indices corresponding to .mat files
D = D(filerows); % ignore indices that aren't data files
nrow = length(D); % get number of rows for the table

data = load([D(1).folder filesep D(1).name]); % load example file

VarNames = cell(1000, 1); % create cell array for variable names
VarTypes = cell(1000, 1); % create cell for variable types
varn = 1; % variable counter
fields = fieldnames(data); % get fields of the data structure
for jj = 1:length(fields) % loop through fields
    subfields = fieldnames(data.(fields{jj})); % get subfields
    for kk = 1:length(subfields) % loop through subfields
        check1 = ischar(data.(fields{jj}).(subfields{kk})); % check if subfield is a character array
        check2 = isnumeric(data.(fields{jj}).(subfields{kk})) && ...
            length(data.(fields{jj}).(subfields{kk})) == 1; % check if it's a scalar
        if check1 || check2
            VarNames{varn} = subfields{kk}; % save variable name to VarName array
            VarTypes{varn} = class(data.(fields{jj}).(subfields{kk}));
            varn = varn + 1;
        end
    end
end
VarNames = VarNames(~cellfun(@isempty, VarNames)); % trim all the empty cells
VarTypes = VarTypes(~cellfun(@isempty, VarTypes));

SumTable = table('

disp('Done')
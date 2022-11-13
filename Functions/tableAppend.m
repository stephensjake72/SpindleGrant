function outT = tableAppend(T, vars)
disp('Making table ...')
for ii = 1:numel(vars) % loop through the variables to be appended
    var = vars{ii};
    
    % if variable doesn't already exist in the table, create a new column
    if ~strcmp(T.Properties.VariableNames, var)
        T.(var) = cell(height(T), 1);
    end
    
    % loop through rows of the table
    for jj = 1:height(T)
        data = load(T.address{jj});
        
        T.(var){jj} = NaN; % save NaN as default cell entry
        fields = fieldnames(data);
        
        % check if variable to be appended is a data field itself
        if isfield(data, var)
            T.(var){jj} = data.(var);
        else % otherwise if the variable is within a field
            for kk = 1:numel(fields) % loop through data fields
                field = fields{kk};
                
                % if the variable to be appended is in the field, overwrite
                % the NaN
                if isfield(data.(field), var)
                    T.(var){jj} = data.(field).(var);
                end
            end
        end
    end
end
outT = T;
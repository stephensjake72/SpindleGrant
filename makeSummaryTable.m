% make summary table
clc
clear
close all

D = dir('C:\\Users\Jake\Documents\Data\Spindle_spring_struct');
D = D(3:end);

count = 0;
for ii = 1:numel(D)
    subD = dir([D(ii).folder filesep D(ii).name]);
    subD = subD(3:end);
    
    count = count + numel(subD);
end

summaryTable = table('Size', [count, 1], ...
    'VariableTypes', {'cell'}, ...
    'VariableNames', {'address'});

n = 1;
for jj = 1:numel(D)
    subD = dir([D(jj).folder filesep D(jj).name]);
    subD = subD(3:end);
    for kk = 1:numel(subD)
        summaryTable.address{n} = [subD(kk).folder filesep subD(kk).name];
        n = n + 1;
    end
end

save('summaryTable.mat', 'summaryTable')
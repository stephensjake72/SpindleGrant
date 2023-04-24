% append experiment parameters to summary table
clc
clear
close all

addpath(genpath('Functions'))
load('summaryTable.mat')

for ii = 1:height(summaryTable)
    data = load(summaryTable.address{ii});
    
    parameters = data.parameters;
    timewin = data.procdata.time < 2;
    
    if summaryTable.trimdatacheck{ii} == 1
        parameters.amp = round((max(data.trimdata.Lmt) - data.trimdata.Lmt(1))*2)/2;
    else
        parameters.amp = round((max(data.procdata.Lmt(timewin)) - data.procdata.Lmt(1))*2)/2;
    end
    save(summaryTable.address{ii}, 'parameters', '-append')
    clear parameters
end
%%
vars = {'type', 'animal', 'cell', 'aff', 'KT', 'passive', 'amp', 'badtrial'};
summaryTable = tableAppend(summaryTable, vars);

save('summaryTable.mat', 'summaryTable')
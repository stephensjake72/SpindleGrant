% classify signals
clc
clear
close all
load('summaryTable.mat')

for ii = 1835:height(summaryTable)
    data = load(summaryTable.address{ii});
    
    figure('Position', [500 400 400 400])
    plot(data.recdata.Lmt)
    title(num2str(ii))
    
    % open dialog box to pick the stretch type
    typelist = {'ramp', 'triangle', 'sine', 'NA'};
    [index, ~] = listdlg('ListString', typelist);
    
    % save stretch type to parameters structure
    parameters = data.parameters;
    parameters.type = typelist{index};
    
    clear index
    save(summaryTable.address{ii}, 'parameters', '-append')
    
    close
end
%%
vars = {'type'};
summaryTable = tableAppend(summaryTable, vars);
save('summaryTable.mat', 'summaryTable')
%% plot to verify
figure
for jj = 1:height(summaryTable)
    hold on
    if strcmp(summaryTable.type{jj}, 'ramp')
        data = load(summaryTable.address{jj});
        plot(data.procdata.time, data.procdata.Lmt)
    end
end
hold off
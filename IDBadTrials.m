% ID bad trials
% this code is written to be run in blocks rather than checking all the
% data one by one
% this code is also only written for 3mm ramps and trimmed active sines
% because I don't want to manually verify the ~1900 trials manually and
% those are the only ones used in analysis
clc
clear
close all
addpath(genpath('Functions'))
load('summaryTable.mat')
%% find bad ramps based on spikes and Lmt
close all
for ii = 1:height(summaryTable)
    check1 = strcmp(summaryTable.type{ii}, 'ramp');
    check2 = summaryTable.amp{ii} == 3;
    check3 = ~strcmp(summaryTable.aff{ii}, 'II');
    check4 = ~strcmp(summaryTable.aff{ii}, 'IB');
    check5 = summaryTable.passive{ii} == 1;
    if check1 && check2 && check3 && check4 && check5
        data = load(summaryTable.address{ii});
        
        figure('Position', [500 400 400 400])
        subplot(211)
        plot(data.procdata.time, data.procdata.Lmt)
        title(num2str(ii))
        ax = gca;
        subplot(212)
        plot(data.procdata.spiketimes, data.procdata.ifr, '.')
        xlim(ax.XAxis.Limits)
        
        % open dialog box to pick the stretch type
        typelist = {'good', 'bad'};
        [index, ~] = listdlg('ListString', typelist);

        % save stretch type to parameters structure
        if index == 2
            badtrial = 1;
            save(summaryTable.address{ii}, 'badtrial', '-append')
        elseif isempty(index)
            break
        end
        clear index
        close
    end
end
%% find bad triangles based on spikes and Lmt
close all
for ii = 1:height(summaryTable)
    check1 = strcmp(summaryTable.type{ii}, 'triangle');
    check2 = summaryTable.amp{ii} == 3;
    check3 = ~strcmp(summaryTable.aff{ii}, 'II');
    check4 = ~strcmp(summaryTable.aff{ii}, 'IB');
    check5 = summaryTable.passive{ii} == 1;
    if check1 && check2 && check3 && check4 && check5
        data = load(summaryTable.address{ii});
        
        figure('Position', [500 400 400 400])
        subplot(211)
        plot(data.procdata.time, data.procdata.Lmt)
        title(num2str(ii))
        ax = gca;
        subplot(212)
        plot(data.procdata.spiketimes, data.procdata.ifr, '.')
        xlim(ax.XAxis.Limits)
        
        % open dialog box to pick the stretch type
        typelist = {'good', 'bad'};
        [index, ~] = listdlg('ListString', typelist);

        % save stretch type to parameters structure
        if index == 2
            badtrial = 1;
            save(summaryTable.address{ii}, 'badtrial', '-append')
        elseif isempty(index)
            break
        end
        clear index
        close
    end
end
%% id bad sines based on ifr
close all
for ii = 1:height(summaryTable)
    check1 = summaryTable.trimdatacheck{ii} == 1;
    check2 = ~strcmp(summaryTable.aff{ii}, 'II');
    check3 = ~strcmp(summaryTable.aff{ii}, 'IB');
    if check1 && check2 && check3
        data = load(summaryTable.address{ii});
        
        figure('Position', [500 400 400 400])
        subplot(211)
        plot(data.trimdata.time, data.trimdata.Lmt)
        title(num2str(ii))
        ax = gca;
        subplot(212)
        plot(data.trimdata.spiketimes, data.trimdata.ifr, '.')
        xlim(ax.XAxis.Limits)
        
        % open dialog box to pick the stretch type
        typelist = {'good', 'bad'};
        [index, ~] = listdlg('ListString', typelist);

        % save stretch type to parameters structure
        if index == 2
            badtrial = 1;
            save(summaryTable.address{ii}, 'badtrial', '-append')
        elseif isempty(index)
            break
        end
        clear index
        clear badtrial
        close
    end
end
%% id bad triangles based on force
for jj = 1600:height(summaryTable)
    check1 = summaryTable.badtrial{jj} == 0;
    check2 = strcmp(summaryTable.type{jj}, 'triangle');
    check3 = summaryTable.amp{jj} == 3;
    check4 = summaryTable.passive{jj} == 1;
    if check1 && check2 && check3 && check4
        data = load(summaryTable.address{jj});
        
        figure('Position', [400 400 400 400])
        subplot(211)
%         hold on
        plot(data.procdata.time, data.procdata.Lmt)
        subplot(212)
%         hold on
        plot(data.procdata.time, data.procdata.Fmt)
        sgtitle(num2str(jj))
        
        % open dialog box to pick the stretch type
        typelist = {'good', 'bad'};
        [index, ~] = listdlg('ListString', typelist);

        % save stretch type to parameters structure
        if index == 2
            badtrial = 1;
            save(summaryTable.address{jj}, 'badtrial', '-append')
        elseif isempty(index)
            break
        end
        clear index
        clear badtrial
        close
    end
end
%%
vars = {'badtrial'};
summaryTable = tableAppend(summaryTable, vars);
save('summaryTable.mat', 'summaryTable')
% get stiffness values
clc
clear
close all
addpath(genpath('Functions'))
load('summaryTable.mat')

animals = unique(summaryTable.animal)

count = 0;
figure('Position', [400 400 500 500])
for ii = 1:height(summaryTable)
    check1 = strcmp(summaryTable.type{ii}, 'ramp'); % check if is ramp
    check2 = summaryTable.passive{ii} == 1; % if is passive
    check3 = summaryTable.badtrial{ii} == 0; % if it's a good trial
    check4 = strcmp(summaryTable.animal{ii}, animals{2});
    if check1 && check2 && check3 && check4 && count < 1000
        data = load(summaryTable.address{ii});
        
        [p, f] = pspectrum(data.recdata.Lmt, data.recdata.time);
        
%         [b, a] = butter(
        figure('Position', [400 400 500 500])
        subplot(311)
        hold on
        plot(data.recdata.time, data.recdata.Lmt - data.recdata.Lmt(1))
%         ylim([-.5, 1.2*max(data.recdata.Lmt - data.recdata.Lmt(1))])
        subplot(312)
        hold on
        plot(data.recdata.time, data.recdata.Fmt)
        subplot(313)
        hold on
        plot(f, p)
        set(gca, 'XScale', 'log')
        set(gca, 'Yscale', 'log')
         % open dialog box to pick the stretch type
        typelist = {'good', 'bad'};
        [index, ~] = listdlg('ListString', typelist);
        if isempty(index)
            break
        end
%         % save stretch type to parameters structure
%         if index == 1
%             continue
%         else
%             badtrial = 1;
%         end
%     %     clear index
%         save(summaryTable.address{ii}, 'badtrial', '-append')
        count = count + 1;
    end
end
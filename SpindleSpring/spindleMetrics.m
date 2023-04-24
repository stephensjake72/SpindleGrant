% extract spindle metrics

clc
clear
close all

addpath(genpath('Functions'));
load('summaryTable.mat');

%%
dispramp = 1;
dispsine = 1;
for ii = 1:height(summaryTable)
    
    % only compute spindle response metrics for passive ramps
    check1 = summaryTable.passive{ii} == 1;
    check2 = summaryTable.trimdatacheck{ii} == 1;
    check3 = summaryTable.badtrial{ii} == 0;
    if (check1 || check2) && check3
        if check1 % if it's a passive ramp, triangle, or sine
            data = load(summaryTable.address{ii});
            expdata = data.procdata;
            parameters = data.parameters;
        elseif check2 % if it's a trimmed active sine
            data = load(summaryTable.address{ii});
            expdata = data.trimdata;
        end
        type = summaryTable.type{ii};
        
        switch type
            case 'ramp'
                ifrMetrics = exportRampMetrics(expdata);
                
                if ~isstruct(ifrMetrics)
                    continue
                end
%                 
                % plot to check (or don't)
                if ~strcmp(data.parameters.aff, 'IB') && ~strcmp(data.parameters.aff, 'II')
%                     figure('Position', [400 400 400 400])
%                     subplot(211)
%                     plot(expdata.time, expdata.Lmt)
%                     yyaxis right
%                     plot(expdata.time, expdata.vmt)
%                     ax = gca;
%                     subplot(212)
%                     plot(expdata.spiketimes, expdata.ifr, '.k')
%                     hold on
%                     yline([ifrMetrics.IBA, ifrMetrics.DRA, ifrMetrics.SRA])
%                     sgtitle([num2str(ii) ' ' data.parameters.aff])
%                     if dispramp
%                         ifrMetrics
%                         dispramp = 0;
%                     end
% 
%                     % manually ID bad trials and try not to bang your head into
%                     % your desk too hard
%                     typelist = {'good', 'bad'};
%                     [index, ~] = listdlg('ListString', typelist);
%                     if isempty(index)
%                         break
%                     end
% %                     save stretch type to parameters structure
%                     if index == 2
%                         badtrial = 1;
%                         save(summaryTable.address{ii}, 'badtrial', '-append')
%                     end
                    
                end
                save(summaryTable.address{ii}, 'ifrMetrics', '-append')
                
            case 'sine'
                ifrMetrics = exportSineMetrics(expdata, data.parameters.amp);
                
%                 if strcmp(data.parameters.aff, 'IA')
%                     figure('Position', [400 400 400 400])
%                     subplot(211)
%                     plot(expdata.time, expdata.Lmt)
%                     yyaxis right
%                     plot(expdata.time, expdata.vmt)
%                     ax = gca;
%                     subplot(212)
%                     plot(expdata.spiketimes, expdata.ifr, '.k', ...
%                         ifrMetrics.ifrpktimes, ifrMetrics.ifrpks, '.r')
%                     hold on
%                     yline([ifrMetrics.peakifr ifrMetrics.meanifr], '--', ...
%                         {'Peak', 'Mean'})
%                     hold off
%                     if dispsine
%                         ifrMetrics
%                         dispsine = 0;
%                     end
%                 end
                save(summaryTable.address{ii}, 'ifrMetrics', '-append')
            case 'triangle'
                ifrMetrics = exportTriangleMetrics(data.procdata);
                save(summaryTable.address{ii}, 'ifrMetrics', '-append')
        end
        clear ifrMetrics
    end
end
%%
vars = {'IBA', 'DRA', 'SRA', 'DI', 'restRate', 'peakifr', 'meanifr', 'spikect',  'triIB', 'trisc1', 'trisc2', 'trimifr1', 'trimifr2'};
summaryTable = tableAppend(summaryTable, vars);
save('summaryTable.mat', 'summaryTable')
writetable(summaryTable, 'C:\\Users\Jake\Documents\Data\SpindleSpringSummary.csv')
% fig 3
% force and stiffness at a fixed force
clc
clear
close all
addpath(genpath('Functions'))
load('summaryTable.mat')

animals = unique(summaryTable.animal);
%% plotting to verify 
close all
for ii = 7% :numel(animals)
    animal = animals{ii};
    
    check1 = [summaryTable.badtrial{:}]' == 0;
    check2 = [summaryTable.passive{:}]' == 1;
    check3 = strcmp(summaryTable.type, 'ramp');
    check4 = [summaryTable.trimdatacheck{:}]' == 1;
    check5 = strcmp(summaryTable.KT, 'T');
    check6 = strcmp(summaryTable.animal, animal);
    check7 = strcmp(summaryTable.KT, 'C');
    
    rampTrows = find(check1 & check2 & check3 & check5 & check6);
    rampCrows = find(check1 & check2 & check3 & check6 & check7);
    sineTrows = find(check1 & check4 & check5 & check6);
    sineCrows = find(check1 & check4 & check6 & check7);
    for jj = 1% 1:numel(rampTrows)
        rampTdata = load(summaryTable.address{rampTrows(jj)});
        for kk = 1% :numel(rampCrows)
            rampCdata = load(summaryTable.address{rampCrows(kk)});
            figure
            subplot(321)
            plot(rampTdata.procdata.time, rampTdata.procdata.Lmt, ...
                rampCdata.procdata.time, rampCdata.procdata.Lmt, 'Color', 'k')
            hold on
            plot(rampTdata.procdata.time, rampTdata.procdata.Lf, 'Color', [.5 .5 .5])
            plot(rampCdata.procdata.time, rampCdata.procdata.Lf, 'Color', 'c')
            hold off
            
            subplot(323)
            plot(rampTdata.procdata.time, rampTdata.procdata.Fmt, 'Color', 'k')
            hold on
            plot(rampCdata.procdata.time, rampCdata.procdata.Fmt, 'Color', 'c')
            hold off
            
            subplot(3, 6, 13)
            plot(rampTdata.procdata.Lmt, rampTdata.procdata.Lf, 'k')
            hold on
            plot(rampCdata.procdata.Lmt, rampCdata.procdata.Lf, 'c')
            hold off
            xlabel('Lmt')
            ylabel('Lf')
            subplot(3, 6, 14)
            plot(rampTdata.procdata.Lmt, rampTdata.procdata.Fmt, 'k')
            hold on
            plot(rampCdata.procdata.Lmt, rampCdata.procdata.Fmt, 'c')
            hold off
            xlabel('Lmt')
            ylabel('Fmt')
            subplot(3, 6, 15)
            plot(rampTdata.procdata.Lf, rampTdata.procdata.Fmt, 'k')
            hold on
            plot(rampCdata.procdata.Lf, rampCdata.procdata.Fmt, 'c')
            hold off
            xlabel('Lf')
            ylabel('Fmt')
        end
    end
    for nn = 1% 1:numel(rampTrows)
        sineTdata = load(summaryTable.address{sineTrows(nn)});
        for mm = 1% :numel(sineCrows)
            sineCdata = load(summaryTable.address{sineCrows(mm)});
            subplot(322)
            plot(sineTdata.trimdata.time, sineTdata.trimdata.Lmt, ...
                sineCdata.trimdata.time, sineCdata.trimdata.Lmt, 'Color', 'k')
            hold on
            plot(sineTdata.trimdata.time, sineTdata.trimdata.Lf, 'Color', [.5 .5 .5])
            plot(sineCdata.trimdata.time, sineCdata.trimdata.Lf, 'Color', 'c')
            hold off
            
            subplot(324)
            plot(sineTdata.trimdata.time, sineTdata.trimdata.Fmt, 'Color', 'k')
            hold on
            plot(sineCdata.trimdata.time, sineCdata.trimdata.Fmt, 'Color', 'c')
            hold off
            
            subplot(3, 6, 16)
            plot(sineTdata.trimdata.Lmt, sineTdata.trimdata.Lf, 'k')
            hold on
            plot(sineCdata.trimdata.Lmt, sineCdata.trimdata.Lf, 'c')
            hold off
            xlabel('Lmt')
            ylabel('Lf')
            subplot(3, 6, 17)
            plot(sineTdata.trimdata.Lmt, sineTdata.trimdata.Fmt, 'k')
            hold on
            plot(sineCdata.trimdata.Lmt, sineCdata.trimdata.Fmt, 'c')
            hold off
            xlabel('Lmt')
            ylabel('Fmt')
            subplot(3, 6, 18)
            plot(sineTdata.trimdata.Lf, sineTdata.trimdata.Fmt, 'k')
            hold on
            plot(sineCdata.trimdata.Lf, sineCdata.trimdata.Fmt, 'c')
            hold off
            xlabel('Lf')
        end
    end
end

print(['C:\\Users\Jake\Documents\Data\Spindle_spring_figures\fig3a.eps'], '-depsc','-painters')

%% compute and save stiffness
dx = .2;
thr = .75;
for nn = 1:height(summaryTable)
    check1 = summaryTable.badtrial{nn} == 0;
    check2 = summaryTable.passive{nn} == 1;
    check3 = strcmp(summaryTable.type{nn}, 'ramp');
    check4 = summaryTable.trimdatacheck{nn} == 1;
    
    if check1 && check2 && check3
        data = load(summaryTable.address{nn}); % load data
        
        stiffness = computeStiffness(data.procdata, thr); % compute stiffness at force threshold
%         figure('Position', [1100 400 500 500])
%         subplot(211)
%         plot(data.procdata.Lmt, data.procdata.Fmt) % force length curve
%         hold on
%         plot(stiffness.Lmtcenter, stiffness.Fmtcenter, 'xk')
%         plot(stiffness.Lmtcenter + [-dx dx], ...
%             stiffness.Fmtcenter + stiffness.kMTU*[-dx dx], 'r')
%         hold off
%         subplot(212)
%         plot(data.procdata.Lf, data.procdata.Fmt)
%         hold on
%         plot(stiffness.Lfcenter, stiffness.Fmtcenter, 'xk')
%         plot(stiffness.Lfcenter + [-dx dx], ...
%             stiffness.Fmtcenter + stiffness.kFas*[-dx dx], 'r')
%         hold off
%         sgtitle(num2str(nn))
%         [index, ~] = listdlg('ListString', {' '});
%         if isempty(index)
%             break
%         end
%         close
        save(summaryTable.address{nn}, 'stiffness', '-append')
        clear stiffness
        clear data
    elseif check1 && check4
        data = load(summaryTable.address{nn});
        stiffness = computeStiffness(data.trimdata, thr);
%         figure('Position', [1100 400 500 500])
%         subplot(211)
%         plot(data.trimdata.Lmt, data.trimdata.Fmt) % force length curve
%         hold on
%         plot(stiffness.Lmtcenter, stiffness.Fmtcenter, 'xk')
%         plot(stiffness.Lmtcenter + [-dx dx], ...
%             stiffness.Fmtcenter + stiffness.kMTU*[-dx dx], 'r')
%         hold off
%         subplot(212)
%         plot(data.trimdata.Lf, data.trimdata.Fmt)
%         hold on
%         plot(stiffness.Lfcenter, stiffness.Fmtcenter, 'xk')
%         plot(stiffness.Lfcenter + [-dx dx], ...
%             stiffness.Fmtcenter + stiffness.kFas*[-dx dx], 'r')
%         hold off
%         sgtitle(num2str(nn))
%         [index, ~] = listdlg('ListString', {' '});
%         if isempty(index)
%             break
%         end
%         close
        save(summaryTable.address{nn}, 'stiffness', '-append')
        clear stiffness
        clear data
    end
end
%%
vars = {'kMTU', 'kFas', 'FasExc'};
summaryTable = tableAppend(summaryTable, vars);
save('summaryTable.mat', 'summaryTable')
writetable(summaryTable, 'C:\\Users\Jake\Documents\Data\SpindleSpringSummary.csv')
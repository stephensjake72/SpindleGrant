clc
clear
close all
load('summaryTable.mat')
addpath(genpath('Functions'))

for ii = 1:height(summaryTable)
    check1 = summaryTable.passive{ii} == 1;
    check2 = summaryTable.trimdatacheck{ii} == 1;
    check3 = summaryTable.badtrial{ii} == 0;
    if (check1 || check2) && check3
    
        switch summaryTable.type{ii}
            case 'ramp'
                if summaryTable.amp{ii} == 3
                    data = load(summaryTable.address{ii});
                    thr = .5;
                    stiffness = computeStiffness(data.procdata, thr);
                    
%                     dx = [-.1 0 .1];
%                     dF = stiffness.kMTU*dx;
%                     hold on
%                     plot(data.procdata.Lmt, data.procdata.Fmt, 'k')
%                     plot(stiffness.Lmtcenter + dx, stiffness.Fmtcenter + dF, 'r')
                    save(summaryTable.address{ii}, 'stiffness', '-append')
                    clear stiffness
                end
            case 'triangle'
                if summaryTable.amp{ii} == 3
                    data = load(summaryTable.address{ii});
                    
                    thr = .5;
                    stiffness = computeStiffness(data.procdata, thr);
%                     
%                     dx = [-.1 0 .1];
%                     dF = stiffness.kMTU*dx;
%                     
%                     hold on
%                     plot(data.procdata.Lmt, data.procdata.Fmt, 'k')
%                     plot(stiffness.Lmtcenter + dx, stiffness.Fmtcenter + dF, 'r')
                    save(summaryTable.address{ii}, 'stiffness', '-append')
                    clear stiffness
                end
            case 'sine'
                if summaryTable.trimdatacheck{ii} == 1
                    data = load(summaryTable.address{ii});
                    
                    thr = .4;
                    stiffness = computeStiffness(data.trimdata, thr);
                    
%                     dx = [-.1 0 .1];
%                     dF = stiffness.kMTU*dx;
%                     
%                     hold on
%                     plot(data.trimdata.Lmt, data.trimdata.Fmt, 'k')
%                     plot(stiffness.Lmtcenter + dx, stiffness.Fmtcenter + dF, 'r')
                    save(summaryTable.address{ii}, 'stiffness', '-append')
                    clear stiffness
                end
        end
    end
end
%%
vars = {'kMTU', 'kFas', 'FasExc', 'dLfdLmt'};
summaryTable = tableAppend(summaryTable, vars);
save('summaryTable.mat', 'summaryTable')
writetable(summaryTable, 'C:\\Users\Jake\Documents\Data\SpindleSpringSummary.csv')
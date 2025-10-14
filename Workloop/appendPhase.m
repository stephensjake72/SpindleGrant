% run this script after dataProcessing
clc; clear; close all
addpath(genpath('Functions'))

% loc = '/Volumes/labs/ting/shared_ting/Jake/Workloop/';
loc = '/Users/jacobstephens/Documents/Data/Workloop/';
d = dir(loc);
%%
close all; clc;

% 
for n = 1:length(d)
    if ~contains(d(n).name, 'A100')
        continue
    else
        subdir = dir([d(n).folder filesep d(n).name filesep 'procdata']);
    end
    if isempty(subdir)
        continue
    end
    subdir = subdir(3:end);

    for m = 1:length(subdir)
        if ~contains(subdir(m).name, '.mat')
            continue
        end
        data = load([subdir(m).folder filesep subdir(m).name]);
        parameters = data.parameters;
        disp(m)
        if strcmp(data.parameters.type, 'workloop')
            % phase = getStimPhase(data.procdata);
            % parameters.stimphase = phase;
            L = data.procdata.Lmt;
            time = data.procdata.time;
            [~, l] = findpeaks(L, ...
                'MinPeakProminence', 0.45*(max(L) - min(L)));
            tpeak = time(l);
            cycleT = mean(diff(tpeak));
            tstart = tpeak - cycleT/4;

            a = data.procdata.act;
            ds = [diff(a); 0];
            stimstarts = a([1; find(ds > 0.25)+1]);
            dt = zeros(size(stimstarts));
            for p = 1:length(dt)
                tt = tstart(find(tstart <= stimstarts(p), 1, 'last'));
                dt(p) = stimstarts(p) - tt;
            end
            phi = round(4*mean(dt)/cycleT)*25;
            if phi == 100
                phi = 0;
            end

            parameters.stimphase = phi;
            % stimphase = stimstart - tstart;
            figure
            plot(time, L)
            hold on
            plot(data.procdata.act, zeros(size(data.procdata.act)), '|r')
            % yyaxis right; plot(a, ds, 'xr')
            % xlim([-.5 5])
            xline(stimstarts)
            sgtitle(num2str(phi))
            
        else
            parameters.stimphase = 1;
        end
        save([subdir(m).folder filesep subdir(m).name], 'parameters', '-append')
    end
end

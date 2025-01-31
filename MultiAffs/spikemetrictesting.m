clc
clear
close all
addpath(genpath('Functions'))

path = '/Volumes/labs/ting/shared_ting/Jake/MultiAffs_mat';
D = dir(path);
D = D(3:end);
opts = {D.name};
opts = opts';
sel = listdlg('ListString', opts);
folders = opts(sel);
%%
for n = 1:numel(folders)
    subdir = dir([D(1).folder filesep folders{n} filesep 'procdata']);
    subdir = subdir(3:end);

    IAcount = sum(contains({subdir.name}, 'IA') & contains({subdir.name}, 'ramp'));
    if IAcount < 1
        continue
    end

    nrow = ceil(sqrt(IAcount));
    if nrow > 5
        nrow = 5;
    end
    figure
    tiledlayout(nrow, nrow)

    count = 1;
    for m = 1:numel(subdir)
        check1 = contains(subdir(m).name, 'ramp');
        check2 = contains(subdir(m).name, 'IA');
        if check1 && check2
            data = load([subdir(m).folder filesep subdir(m).name]);

            ib = computeinitialburst(data.procdata);
            dr = computedynamicresponse(data.procdata);
            sr = computestaticresponse(data.procdata);

            plot(data.procdata.spiketimes, data.procdata.ifr, '.k')
            ylim([0 1.2*max(data.procdata.ifr)])
            yline([ib dr sr], '--', {'r', 'g', 'b'})
            nexttile
            if count > 25
                figure
                tiledlayout(nrow, nrow)
                count = 1;
            end
            count = count + 1;
        end
    end
end

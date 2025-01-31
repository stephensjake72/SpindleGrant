% plot firing
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
 
close
stretchtypes = {'ramp', 'triangle', 'sine'};
sel2 = listdlg('ListString', stretchtypes);
stretchsel = stretchtypes{sel2};

celltypes = {'IA', 'II', 'IB', 'IX'};
sel3 = listdlg('ListString', celltypes);
cellsel = celltypes{sel3};
%%
% make a table of file locations and necessary variables
T = table('Size', [1e4, 5], ...
    'VariableTypes', {'string', 'string', 'double', 'cell', 'cell'}, ...
    'VariableNames', {'address', 'cellID', 'stretchV', 'spiketimes', 'ifr'});

count = 1;
for ii = 1:length(folders)
    subdir = dir([path filesep folders{ii} filesep 'procdata']);
    subdir = subdir(3:end);

    for jj = 1:length(subdir)

        if contains(subdir(jj).name, cellsel) &&  contains(subdir(jj).name, stretchsel)
            data = load([subdir(jj).folder filesep subdir(jj).name]);

            [an, cellnum, ~, ~, ~] = filename2vars(subdir(jj).name);
            T.address{count} = [subdir(jj).folder filesep subdir(jj).name];
            T.cellID{count} = [an '-' cellnum];
            T.stretchV(count) = floor(mean(data.procdata.dLmt(data.procdata.dLmt > 0.9*max(data.procdata.dLmt))));
            T.spiketimes{count} = {data.procdata.spiketimes};
            T.ifr{count} = {data.procdata.ifr};

            count = count + 1;
        end
    end
    disp([folders{ii} ' done'])
end
T(count:end, :) = [];

%% plotting
vels = unique(T.stretchV);
stopCol = [8,104,172]/255; startCol = [153,216,201]/255;
colors = mapColors(startCol, stopCol, length(vels));

% uniquecells = unique(T.cellID);
uniquecells = {'A100142-24-67-2'};
for m = 1:length(uniquecells)

    rows = find(T.cellID == uniquecells{m});

    for n = 1:length(rows)

        % rownum = rows(n);
        % x = T.spiketimes{rownum}{:};
        % y = T.ifr{rownum}{:};
        % 
        % colorind = find(vels == T.stretchV(rownum));
        % color = colors(colorind, :);
        % 
        % subplot(length(uniquecells), 3, [3*m-2 3*m-1])
        % hold on
        % plot(x, y, 'Color', color, 'Marker', '.', 'LineStyle', 'none')
        % xlim([0 1.25])
        % title(uniquecells{m})
        % subplot(length(uniquecells), 3, 3*m)
        % hold on
        % plot(x, y, 'Color', color, 'Marker', '.', 'LineStyle', 'none')
        % xlim([0 .25])
        x = T.spiketimes{rownum}{:};
        y = T.ifr{rownum}{:};

        rownum = rows(n);
        colorind = find(vels == T.stretchV(rownum));
        color = colors(colorind, :);
        subplot(2, 2, 1)
        hold on
        plot(x, y, 'Color', color, 'Marker', '.', 'LineStyle', 'none')
        xlim([0 1.25])
        subplot(2, 2, 3)
        
    end

end
sgtitle(cellsel)
savepath = '/Users/jacobstephens/Documents/CNTP_Retreat_2024/';
print([savepath filesep cellsel 'data'], '-depsc2')
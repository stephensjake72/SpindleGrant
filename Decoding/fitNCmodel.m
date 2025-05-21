% fit models
clc; clear; close all


addpath(genpath('Functions'))

loc = '/Volumes/labs/ting/shared_ting/Jake/MultiAffs_mat/';
d = dir(loc);

% savedir = ['/Users/jacobstephens/Documents/Data/decodingmodelfitting' filesep 'LV-'char(datetime('today'))];
% if ~isfolder(savedir)
%     mkdir(savedir)
% end
%%

for n = 1:length(d)
    % disp(d(n).name)
    if contains(d(n).name, 'A100')
        subdir = dir([d(n).folder filesep d(n).name filesep 'procdata']);
        if sum(contains({subdir.name}, 'IB')) >= 1 % check if the folder has a IB
            names = {subdir.name};
            ibnames = names(contains(names, 'IB')); % ib files
            affnums = cell(length(ibnames), 1);
            for m = 1:length(ibnames)
                ibdata(m) = load([subdir(1).folder filesep ibnames{m}]);
                affnums{m} = ibdata(m).parameters.cell;
            end

            NC = getNCparameters(ibdata);

            figure
            sgtitle(d(n).name)
            for p = 1:length(ibdata)
                plotdata = ibdata(p).procdata;
                Fnc = NC.A*exp(NC.kexp*(plotdata.Lmt - NC.L0));
                Fc = plotdata.Fmt - Fnc;

                subplot(231)
                hold on
                plot(plotdata.time, plotdata.Fmt, 'Color', [.75 .75 .75])
                plot(plotdata.time, Fc, 'b')

                subplot(234)
                hold on
                plot(plotdata.time, Fc*NC.kF, 'b')
                plot(plotdata.spiketimes, plotdata.ifr, '.k')

                subplot(2, 3, [2 3 5 6])
                hold on
                plot(plotdata.Lmt, plotdata.Fmt, 'Color', [.75 .75 .75])
                plot(plotdata.Lmt, Fc, 'b')
                title({['A: ' num2str(NC.A)]; ...
                    ['k_{exp}: ' num2str(NC.kexp)]; ...
                    ['L_0: ' num2str(NC.L0)]; ...
                    ['k_F: ' num2str(NC.kF)]})
            end

            save([d(n).name '-NC.mat'], 'NC');
        end
    end
end
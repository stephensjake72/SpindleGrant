% plot ramp sims

clc; clear; close all;
%%
startdir = '/Users/jacobstephens/Documents/SimResults';
d = dir(startdir);

SimDat = table('Size', [length(d)-2, 5], ...
    'VariableTypes', {'string', 'double', 'double', 'double', 'double'}, ...
    'VariableNames', {'file', 'bagf', 'bagg', 'chainf', 'chaing'});

% first pull all the f and g values and file names to load data later
for n = 3:numel(d)
    sim = load([startdir filesep d(n).name]);
    SimDat.file{n-2} = d(n).name;
    SimDat.bagf(n-2) = sim.results.sarcB.f;
    SimDat.bagg(n-2) = sim.results.sarcB.g;
    SimDat.chainf(n-2) = sim.results.sarcC.f;
    SimDat.chaing(n-2) = sim.results.sarcC.g;
end
%%
% create vector of initial values that surabhi set
p0 = [600 7 400 300];

% create color map
colors = mapColors([199,233,180]/255, [8,29,88]/255, 5);

% first plot bag fiber sweeeps ///////////////////////////////////////////

% find rows corresponding to which coeffs are unchanged
c1 = SimDat.bagf == p0(1);
c2 = SimDat.bagg == p0(2);
c3 = SimDat.chainf == p0(3);
c4 = SimDat.chaing == p0(4);

% for the first plot we want to show bag f ///////////////////////////////
rownums = find(c2 & c3 & c4);
subTab = SimDat(rownums, :);
subTab = sortrows(subTab, 'bagf');
nplot = height(subTab);

for p = 1:nplot
    sim = load([startdir filesep subTab.file{p}]);
    
    for q = 1:5
        subplot(nplot, 2, 2*p-1)
        hold on
        plot(sim.results.r_t, sim.results.dataB(q).hs_force, ...
            'Color', colors(q, :))
        ylabel('hs force')
        xlim([-.15 1.5])
        ylim([3e4 7e4])
        title({['f_{bag}: ' num2str(sim.results.sarcB.f) ...
            ' g_{bag}: ' num2str(sim.results.sarcB.g)]})

        subplot(nplot, 2, 2*p)
        hold on
        plot(sim.results.r_t, sim.results.dataB(q).f_bound, ...
            'Color', colors(q, :))
        ylabel('f bound')
        xlim([-.15 1.5])
        ylim([0 .2])
    end
end
%%
% next show bag g ////////////////////////////////////////////////////////
clear rownums subTab nplot p q
rownums = find(c1 & c3 & c4);
subTab = SimDat(rownums, :);
subTab = sortrows(subTab, 'bagg');
nplot = height(subTab);

for p = 1:nplot
    sim = load([startdir filesep subTab.file{p}]);
    
    for q = 1:5
        subplot(nplot, 2, 2*p-1)
        hold on
        plot(sim.results.r_t, sim.results.dataB(q).hs_force, ...
            'Color', colors(q, :))
        ylabel('hs force')
        xlim([-.15 1.5])
        ylim([2e4 6e4])
        title({['f_{bag}: ' num2str(sim.results.sarcB.f) ...
            ' g_{bag}: ' num2str(sim.results.sarcB.g)]})

        subplot(nplot, 2, 2*p)
        hold on
        plot(sim.results.r_t, sim.results.dataB(q).f_bound, ...
            'Color', colors(q, :))
        ylabel('f bound')
        xlim([-.15 1.5])
        ylim([0 .2])
    end
end

%%
% next show chain f //////////////////////////////////////////////////////
clear rownums subTab nplot p q
rownums = find(c1 & c2 & c4);
subTab = SimDat(rownums, :);
subTab = sortrows(subTab, 'chainf');
nplot = height(subTab);

for p = 1:nplot
    sim = load([startdir filesep subTab.file{p}]);
    
    for q = 1:5
        subplot(nplot, 2, 2*p-1)
        hold on
        plot(sim.results.r_t, sim.results.dataC(q).hs_force, ...
            'Color', colors(q, :))
        ylabel('hs force')
        xlim([-.15 1.5])
        ylim([3e4 13e4])
        title({['f_{chain}: ' num2str(sim.results.sarcC.f) ...
            ' g_{chain}: ' num2str(sim.results.sarcC.g)]})

        subplot(nplot, 2, 2*p)
        hold on
        plot(sim.results.r_t, sim.results.dataC(q).f_bound, ...
            'Color', colors(q, :))
        ylabel('f bound')
        xlim([-.15 1.5])
        % ylim([0 .5])
    end
end
%%
% next show chain g //////////////////////////////////////////////////////
clear rownums subTab nplot p q
rownums = find(c1 & c2 & c3);
subTab = SimDat(rownums, :);
subTab = sortrows(subTab, 'chaing');
nplot = height(subTab);

for p = 1:nplot
    sim = load([startdir filesep subTab.file{p}]);
    
    for q = 1:5
        subplot(nplot, 2, 2*p-1)
        hold on
        plot(sim.results.r_t, sim.results.dataC(q).hs_force, ...
            'Color', colors(q, :))
        ylabel('hs force')
        xlim([-.15 1.5])
        ylim([4e4 15e4])
        title({['f_{chain}: ' num2str(sim.results.sarcC.f) ...
            ' g_{chain}: ' num2str(sim.results.sarcC.g)]})

        subplot(nplot, 2, 2*p)
        hold on
        plot(sim.results.r_t, sim.results.dataC(q).f_bound, ...
            'Color', colors(q, :))
        ylabel('f bound')
        xlim([-.15 1.5])
        % ylim([0 .5])
    end
end

% Script 
% Author: JDS
% Updated: 2/13/22
clc
clear
close all

% access functions
addpath(genpath('Functions'));

% load data
destination = uigetdir('\\cosmic.bme.emory.edu\labs\ting\shared_ting\Jake\Spindle_Grant');
D = dir(destination);
D = D(3:end);
%%
close all
Amp = zeros(numel(D), 1);
Lf_init = zeros(numel(D), 1);
Lf_s = zeros(numel(D), 1);
Fmt_init = zeros(numel(D), 1);
Fmt_s = zeros(numel(D), 1);
Aff1_ib = zeros(numel(D), 1);
Aff1_s = zeros(numel(D), 1);
Aff2_ib = zeros(numel(D), 1);
Aff2_s = zeros(numel(D), 1);
Freq = zeros(numel(D), 1);
Aff1type = cell(numel(D), 1);
Aff2type = cell(numel(D), 1);
Cell = cell(numel(D), 1);

for ii = 1:numel(D)
    disp(ii)
    data = load([D(ii).folder filesep D(ii).name]);
    peaks = getAmps(data);
    
    Amp(ii) = data.parameters.amp;
    Lf_init(ii) = peaks.Lf.vals(1) - data.procdata.Lf(1);
    Lf_s(ii) = mean(peaks.Lf.vals(2:end)) - data.procdata.Lf(1);
    Fmt_init(ii) = peaks.Fmt.vals(1) - data.procdata.Fmt(1);
    Fmt_s(ii) = mean(peaks.Fmt.vals(2:end)) - data.procdata.Fmt(1);
    if isfield(peaks, 'aff1')
        Aff1_ib(ii) = peaks.aff1.vals(1);
        Aff1_s(ii) = mean(peaks.aff1.vals(2:end));
        Aff1type{ii} = data.parameters.aff1type;
    end
    if isfield(peaks, 'aff2')
        Aff2_ib(ii) = peaks.aff2.vals(1);
        Aff2_s(ii) = mean(peaks.aff2.vals(2:end));
        Aff2type{ii} = data.parameters.aff2type;
    end
    Freq(ii) = data.parameters.freq;
    Cell{ii} = data.parameters.cell;
    
    vars = fieldnames(peaks);
    figure('Position', [0 0 800 800])
    tiledlayout(numel(vars), 1)
    for jj = 1:numel(vars)
        numdata = data.procdata.(vars{jj});
        if strfind(vars{jj}, 'aff') == 1
            nexttile
            plot(numdata.times(1:end-1), numdata.IFR, '.k', ...
                numdata.times(peaks.(vars{jj}).locs), peaks.(vars{jj}).vals, 'xr')
            title([vars{jj}, ' gr. ' data.parameters.([vars{jj} 'type'])])
        else
            nexttile
            plot(data.procdata.time, numdata, ...
                data.procdata.time(peaks.(vars{jj}).locs), peaks.(vars{jj}).vals, 'xr')
            title(vars{jj})
        end
    end
    sgtitle(['Cell', data.parameters.cell, ' ', ...
        'f', num2str(data.parameters.freq), ' ', ...
        'a', num2str(data.parameters.amp), ' '])
    clear peaks
end
%%
datatable = table(Amp, Lf_init, Lf_s, Fmt_init, Fmt_s, ...
    Aff1_ib, Aff1_s, Aff2_ib, Aff2_s, Aff1type, Aff2type, Freq, Cell);
savepath = 'C:\\Users\Jake\Documents\Data';
writetable(datatable, [savepath filesep 'AmpFreq.csv'])
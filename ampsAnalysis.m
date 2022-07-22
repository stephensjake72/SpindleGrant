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
type = cell(numel(D), 1);

count = 1;
for ii = 1:numel(D)
    disp(ii)
    data = load([D(ii).folder filesep D(ii).name]);
    if data.badtrial
        continue
    end
    peaks = getAmps(data);
    
    Amp(count) = peaks.Lmt.vals(1) - data.procdata.Lmt(1);
    Lf_init(count) = peaks.Lf.vals(1);
    Lf_s(count) = mean(peaks.Lf.vals(2:end));
    Fmt_init(count) = peaks.Fmt.vals(1);
    Fmt_s(count) = mean(peaks.Fmt.vals(2:end));
    if isfield(peaks, 'aff1')
        Aff1_ib(count) = peaks.aff1.vals(1);
        Aff1_s(count) = mean(peaks.aff1.vals(2:end));
    end
    if isfield(peaks, 'aff2')
        Aff2_ib(count) = peaks.aff2.vals(1);
        Aff2_s(count) = mean(peaks.aff2.vals(2:end));
    end
    Freq(count) = data.parameters.freq;
    Cell{count} = data.parameters.cell(1);
    
    count = count + 1;
%     if isempty(strfind(data.parameters.cell, 'a'))
%         type{ii} = 'shorten';
%     else
%         type{ii} = 'stretch';
%     end
    
    vars = fieldnames(peaks);
    figure('Position', [0 0 800 800])
    tiledlayout(numel(vars), 1)
    for jj = 1:numel(vars)
        numdata = data.procdata.(vars{jj});
        if strfind(vars{jj}, 'aff') == 1
            nexttile
            plot(numdata.times(1:end-1), numdata.IFR, '.k', ...
                numdata.times(peaks.(vars{jj}).locs), peaks.(vars{jj}).vals, 'xr')
%             title([vars{jj}, ' gr. ' data.parameters.([vars{jj} 'type'])])
        else
            nexttile
            plot(data.procdata.time, numdata - numdata(1), ...
                data.procdata.time(peaks.(vars{jj}).locs), peaks.(vars{jj}).vals, 'xr')
%             title(vars{jj})
        end
    end
    sgtitle(['Cell', num2str(data.parameters.cell), ' ', ...
        'f', num2str(data.parameters.freq), ' ', ...
        'a', num2str(data.parameters.amp), ' '])
    save([D(ii).folder filesep D(ii).name], 'peaks', '-append')
    clear peaks
end
%%
datatable = table(Amp, Lf_init, Lf_s, Fmt_init, Fmt_s, ...
    Aff1_ib, Aff1_s, Aff2_ib, Aff2_s, Freq, Cell);
savepath = 'C:\\Users\Jake\Documents\Data';
writetable(datatable, [savepath filesep 'AmpFreq.csv'])
% make summary table
clc
clear
close all

path = '\\cosmic.bme.emory.edu\labs\ting\shared_ting\Jake\SpindleSpring\recdata';

D = dir(path);
data = load([D(4).folder filesep D(4).name]);

fields = fieldnames(data);
nrows = 0;
for ii = 1:length(D)
    if contains(D(ii).name, '.mat')
        nrows = nrows + 1;
    end
end

ncols = 0;
fields = fieldnames(data);
for jj = 1:length(fields)
    subfields = fieldnames(data.(fields{jj}));
    for kk = 1:length(subfields)
        check1 = ischar(data.(fields{jj}).(subfields{kk}));
        check2 = isnumeric(data.(fields{jj}).(subfields{kk})) && ...
            length(data.(fields{jj}).(subfields{kk})) == 1;
        if check1 || check2
            ncols = ncols + 1;
        end
    end
end
ncols
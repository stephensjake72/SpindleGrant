clc
clear
close all

path = uigetdir();
%%
D = dir(path);
D = D(3:end);
%%
for ii = 1:numel(D)
    data = load([D(ii).folder filesep D(ii).name]);
    
    hold on
    plot(data.procdata.Fmt, data.procdata.ymt)
    
    clear data
end
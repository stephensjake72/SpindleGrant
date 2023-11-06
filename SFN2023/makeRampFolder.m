
clc
clear
close all

source = uigetdir();

savedir = '//cosmic.bme.emory.edu/labs/ting/shared_ting/Jake/SFN/procdataRamps';
if ~exist(savedir, 'dir')
    mkdir(savedir)
end

D = dir(source);
D = D(3:end);

for ii = 1:numel(D)
    data = load([source filesep D(ii).name]);
    
    if strcmp(data.parameters.type, 'ramp')
        procdata = data.procdata;
        parameters = data.parameters;
        
        if mean(data.procdata.Fmt(data.procdata.time < 0)) < .15
            savedir = '//cosmic.bme.emory.edu/labs/ting/shared_ting/Jake/SFN/procdataRamps100mN';
            if ~exist(savedir, 'dir')
                mkdir(savedir)
            end
            save([savedir filesep D(ii).name], 'procdata', 'parameters');
            
            clear savedir
        elseif mean(data.procdata.Fmt(data.procdata.time < 0)) >= .15 && ...
                mean(data.procdata.Fmt(data.procdata.time < 0)) < .25
            savedir = '//cosmic.bme.emory.edu/labs/ting/shared_ting/Jake/SFN/procdataRamps200mN';
            if ~exist(savedir, 'dir')
                mkdir(savedir)
            end
            save([savedir filesep D(ii).name], 'procdata', 'parameters');
            
            clear savedir
        else
            savedir = '//cosmic.bme.emory.edu/labs/ting/shared_ting/Jake/SFN/procdataRamps300mN';
            if ~exist(savedir, 'dir')
                mkdir(savedir)
            end
            save([savedir filesep D(ii).name], 'procdata', 'parameters');
            
            clear savedir
        end
    end
end
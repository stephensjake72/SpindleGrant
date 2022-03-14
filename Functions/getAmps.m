function peaks = getAmps(data)
% use MTU length to identify cycle start times
[~, peaklocs] = findpeaks(data.procdata.Lmt, ...
        'MinPeakHeight', .9*max(data.procdata.Lmt), ... 
        'MinPeakProminence', .45*(max(data.procdata.Lmt) - min(data.procdata.Lmt)));
peaklocs = peaklocs(1:end-1); % trim last one to avoid end effects

% use peak times to find trough times
peaktimes = data.procdata.time(peaklocs);
iT = peaklocs(2) - peaklocs(1); % cycle period in samples
troughlocs = [1; peaklocs + round(iT/4)]; % get trough locations by phase shifting peak locations
troughtimes = data.procdata.time(troughlocs);

fields = fieldnames(data.procdata); % pull substructs from data structure

% loop through data substructures
for jj = 1:numel(fields)
    if strcmp(fields{jj}, 'time') % skip time vector
        continue
    end

    numdata = data.procdata.(fields{jj}); % load numerical data structure
    amps = zeros(1, numel(peaktimes)); % make vector for amplitudes
    locs = zeros(1, numel(peaktimes)); % make vector for locations

    if isempty(strfind(fields{jj}, 'aff')) % check if substruct isn't an afferent
        for kk = 1:numel(peaktimes)
            [amps(kk), locs(kk)] = max(numdata(data.procdata.time > troughtimes(kk) & data.procdata.time < troughtimes(kk + 1)));
            amps(kk) = amps(kk) - numdata(1);
            locs(kk) = locs(kk) + troughlocs(kk);
        end
        peaks.(fields{jj}).vals = amps;
        peaks.(fields{jj}).locs = locs;
    else % if it is an afferent
        if isempty(numdata.times)
            continue
        end
        
        st = numdata.times(1:end-1); % get spiketimes
        for kk = 1:numel(peaktimes)
            % Use a try/catch since some afferent structs only have a
            % few spikes. If there are spikes in the window, take the peak
            % otherwise give it a zero
            try
                [amps(kk), locs(kk)] = max(numdata.IFR(st > troughtimes(kk) & st < troughtimes(kk + 1)));
                locs(kk) = locs(kk) + find(st > troughtimes(kk), 1);
            catch
                amps(kk) = 0;
                locs(kk) = 1;
            end
        end
        peaks.(fields{jj}).vals = amps;
        peaks.(fields{jj}).locs = locs;
    end
end
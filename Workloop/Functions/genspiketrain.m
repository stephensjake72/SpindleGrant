function y = genspiketrain(data)
t = data.procdata.time;
y = zeros(1, length(data.procdata.time)); % empty placeholder vector
st = data.procdata.spiketimes; % spiketimes

% loop through spike times
for m = 1:length(st)
    % get the index of the time vector closest to the spike time
    [~, ist] = min(abs(t - st(m))); 
    % set that time vector =1 in the signal vector
    y(ist) = 1;
end
end
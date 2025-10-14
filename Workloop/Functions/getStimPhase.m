function phi = getStimPhase(data)
f = getFreq(data); % get the stretch sinusoid frequency 
tcycle = 1/f; % frequency to cycle period

% find the start time of the muscle stim
tstart = data.act(find(data.actrate > 1, 1, 'first'));
% find the start time of the stim relative to the start of a cycle
reltstart = tstart/tcycle - floor(tstart/tcycle);
% round start time to nearest 25%
phi = round(reltstart*4)*25;
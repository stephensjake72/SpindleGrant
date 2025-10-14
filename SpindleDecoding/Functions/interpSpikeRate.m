function [time, s1, s2, s3] = interpSpikeRate(iadata, iidata, ibdata)

% initialize the vectors
% find the first spike after t0, usually from the Ia
tstart = min([iadata.spiketimes(find(iadata.spiketimes > 0, 1, 'first')), ...
    iidata.spiketimes(find(iidata.spiketimes > 0, 1, 'first')), ...
    ibdata.spiketimes(find(ibdata.spiketimes > 0, 1, 'first'))]); 
% find the last spike
tstop = max([iadata.spiketimes(end), ...
    iidata.spiketimes(end), ...
    ibdata.spiketimes(end)]);

% check for background firing
if ~isempty(find(iadata.spiketimes < 0, 1))
    % if there is bg firing, initialize at the last rate before stretch
    ia_initval = iadata.ifr(find(iadata.spiketimes < 0, 1, 'last'));
else
    ia_initval = 0;
end
% repeat for II + Ib
if ~isempty(find(iidata.spiketimes < 0, 1))
    ii_initval = iidata.ifr(find(iidata.spiketimes < 0, 1, 'last'));
else
    ii_initval = 0;
end
if ~isempty(find(ibdata.spiketimes < 0, 1))
    ib_initval = ibdata.ifr(find(ibdata.spiketimes < 0, 1, 'last'));
else
    ib_initval = 0;
end

% trim the spiketimes and ifr vectors to after t0
stia = iadata.spiketimes(iadata.spiketimes > 0);
stii = iidata.spiketimes(iidata.spiketimes > 0);
stib = ibdata.spiketimes(ibdata.spiketimes > 0);
ria = iadata.ifr(iadata.spiketimes > 0);
rii = iidata.ifr(iidata.spiketimes > 0);
rib = ibdata.ifr(ibdata.spiketimes > 0);

if stia(1) > tstart
    % if the first spike is after tstart, add tstart to the spiketime
    % vector
    stia = [tstart; stia];
    % if the first spike is after tstart, add initial value to the ifr
    % vector
    ria = [ia_initval; ria];
end
% repeat for II + Ib
if stii(1) > tstart
    stii = [tstart; stii];
    rii = [ii_initval; rii];
end
if stib(1) > tstart
    stib = [tstart; stib];
    rib = [ib_initval; rib];
end

% do the same for the end time
if stia(end) < tstop
    stia = [stia; tstop];
    ria = [ria; 0];
end
if stii(end) < tstop
    stii = [stii; tstop];
    rii = [rii; 0];
end
if stib(end) < tstop
    stib = [stib; tstop];
    rib = [rib; 0];
end

% create a single time vector
h = .001;
time = tstart:h:tstop;

s1 = interp1(stia, ria, time);
s2 = interp1(stii, rii, time);
s3 = interp1(stib, rib, time);
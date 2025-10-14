function cost = nc_cost(data, gains)
A = gains(1);
kexp = gains(2);
L0 = gains(3);
kF = gains(4);

% sum over all the trials
trialSSR = zeros(1, length(data));
for n = 1:length(data)
    Fnc = A*exp(kexp*(data(n).procdata.Lmt - L0));
    pred = kF*(data(n).procdata.Fmt - Fnc); % predictor = kF*Fcont.
    pred_s = interp1(data(n).procdata.time, pred, data(n).procdata.spiketimes); % resample/interpolate at spiketimes
    trialSSR(n) = sum((pred_s - data(n).procdata.ifr).^2); % sum squared residuals
end

cost = sum(trialSSR); % cost is the error across all trials
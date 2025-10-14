function stretchV = getStretchV(data)
win = data.time > 0 & data.time < 0.25;
velvals = data.dLmt(data.dLmt > 0.95*max(data.dLmt(win)));
stretchV = round(mean(velvals));
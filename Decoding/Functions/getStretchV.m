function stretchV = getStretchV(data)
velvals = data.dLmt(data.dLmt > 0.95*max(data.dLmt));
stretchV = round(mean(velvals));
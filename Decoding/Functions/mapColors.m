function colors = mapColors(startcolor, endcolor, n)
colors = interp1([1 n], [startcolor; endcolor], (1:n));
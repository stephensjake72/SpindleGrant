function [x, y] = computeTrendLine(x0, y0)
x = unique(x0);
y = zeros(size(x));
for n = 1:length(y)
    y(n) = mean(y0(x0 == x(n)));
end
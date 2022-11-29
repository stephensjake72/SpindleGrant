function [map1, map2] = timeColorMap(time1, time2, cStart, cStop)

r1 = linspace(cStart(1), cStop(1), numel(time1));
g1 = linspace(cStart(2), cStop(2), numel(time1));
b1 = linspace(cStart(3), cStop(3), numel(time1));

r2 = interp1(time1, r1, time2);
g2 = interp1(time1, g1, time2);
b2 = interp1(time1, b1, time2);
if height(time1) == numel(time1) % if column vector
    map1 = [r1 g1 b1];
else
    map1 = [r1' g1' b1'];
end

if height(time2) == numel(time2) % if column vector
    map2 = [r2 g2 b2];
else
    map1 = [r2' g2' b2'];
end
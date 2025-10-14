function y = genfilter(t, width, type)
t1 = t(t < -min(t));
    if strcmp(type, 'gaussian')
        % y = (1/sqrt(2*pi*width^2))*exp(-(t - max(t)/2).^2/(2*width^2));
        y = (1/sqrt(2*pi*width^2))*exp(-t1.^2/(2*width^2));
    elseif strcmp(type, 'exp')
        width = width*2;
        y = (4/width^2)*(t).*exp(-2*(t)/width);
        y(y < 0) = 0;
    elseif strcmp(type, 'reverse exp')
        y = (4/width^2)*(-t + max(t)/2).*exp(-2*(-t)/width);
        y(y < 0) = 0;
    elseif strcmp(type, 'isoc triangle')
        y = -4*abs(t - max(t)/2)/width^2 + 2/width;
        y(y < 0) = 0;
    elseif strcmp(type, 'right triangle')
        y = -2*abs(t - max(t)/2)/width^2 + 2/width;
        y(t > max(t)/2) = 0;
        y(y < 0) = 0;
    elseif strcmp(type, 'rev right triangle')
        y = -2*abs(t - max(t)/2)/width^2 + 2/width;
        y(t < max(t)/2) = 0;
        y(y < 0) = 0;
    end
end
function Sint = integrateSpikes(spiketimes, ifr, alpha, method)
% function to implement methods

ht = diff(spiketimes); % create h(t) vector based on spiketimes
yp = ifr; % save the firing rate as y'

switch method
    case 'FE'
        % forward euler
        dy = @(h, y) h*y;
        Sint = zeros(size(spiketimes));

        for ii = 2:numel(spiketimes)
            Sint(ii) = Sint(ii-1) + dy(ht(ii-1), yp(ii-1));
        end
    case 'AB2' 
        % 2nd order A-B
        dy = @(H, Y) 1.5*H(2)*Y(2) - 0.5*H(1)*Y(1);
        Sint = zeros(size(spiketimes));

        for ii = 2:numel(spiketimes)-1
            Sint(ii+1) = Sint(ii) + dy(ht(ii-1:ii), yp(ii-1:ii));
        end
    case 'AB3'
        % 3rd order A-B
        dy = @(H, Y) (23*H(3)*Y(3) - 16*H(2)*Y(2) + 5*H(1)*Y(1))/12;
        Sint = zeros(size(spiketimes));

        % this part works but isn't in the final version
        % initialize with two forward Euler steps
        % Sint(2) = Sint(1) + ht(2)*yp(2);
        % Sint(3) = Sint(2) + ht(3)*yp(3);

        for ii = 3:numel(spiketimes)-1
            Sint(ii+1) = Sint(ii) + dy(ht(ii-2:ii), yp(ii-2:ii));
        end
end
      
end
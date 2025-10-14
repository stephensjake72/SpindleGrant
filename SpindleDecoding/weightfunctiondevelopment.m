clc

width = 7;
S = ones(1, 9);

L = cell(size(S));
for row = 1:length(S)
    nw = (width + 1)/2; % number of weights
    ndiff = [row - nw, length(S)-(row+nw) + 1]; % difference in row num and weight num
    ndiff(ndiff > 0) = 0;
    ndiff = min(ndiff);

    A = zeros(nw); % empty matrix
    A(1, :) = 1;
    A(1, 2:end+ndiff) = 2;
    A(2:end, 1:nw-1) = eye(nw-1);
    A(2:end, nw) = -nw:1:-2;
    % A

    x = [1; zeros(nw-1, 1)];

    w = (A^-1)*x;
    W = zeros(size(S)); % use weights to create weight vector
    W(row) = w(1);
    if nw > 1
        for m = 1:nw-1
            if row - m >= 1
                W(row - m) = w(m + 1);
            end
            if row + m <= length(W)
                W(row + m) = w(m + 1);
            end
        end
    end
    L{row} = num2str(sum(W));
    hold on
    plot(W)
end
legend(L)
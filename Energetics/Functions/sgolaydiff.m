function [z0,z1,z2] = sgolaydiff(in,N,F)
% function [smooth smoothderiv1 smoothderiv2] = sgolaydiff(in,filterorder,windowsize)
%
% implements a savitsky-golay filter and provides two derivatives of the
% signal "in." default values of N and F are assumed to be 4 and 21,
% respectively.
if isempty(in)
    x=5*sin(.4*pi*0:.2:199);
    y=x+randn(1,996); % Noisy sinusoid
    in = y;
end
if isempty(N)
    N = 4;
end
if isempty(F)
    F = 21;
end
z0 = nan(size(in));
z1 = nan(size(in));
z2 = nan(size(in));
in = in(:)';
[b,g]=sgolay(N,F);
for n = (F+1)/2:length(in)-(F+1)/2
    % Zero-th order derivative (equivalent to sgolayfilt except
    % that it doesn't compute transients)
    z0(n)=g(:,1)'*in(n - (F+1)/2 + 1: n + (F+1)/2 - 1)';
    % 1st order derivative
    z1(n)=g(:,2)'*in(n - (F+1)/2 + 1: n + (F+1)/2 - 1)';
    % 2nd order derivative
    z2(n)=2*g(:,3)'*in(n - (F+1)/2 + 1: n + (F+1)/2 - 1)';
end
end
% plot([x(1:length(z0))',y(1:length(z0))',z0'])
% legend('Noiseless sinusoid','Noisy sinusoid',...
%     'Smoothed sinusoid')
% figure
% plot([diff(x(1:length(z0)+1))',z1'])
% legend('Noiseless first-order derivative',...
%     'Smoothed first-order derivative')
% figure
% plot([diff(diff(x(1:length(z0)+2)))',z2'])
% legend('Noiseless second-order derivative',...
%     'Smoothed second-order derivative')
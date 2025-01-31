animal = 'A100142-24-62';
d = dir(['/Volumes/labs/ting/shared_ting/Jake/MultiAffs_mat/' animal '/procdata']);
addpath(genpath('Functions'))

% load IA and II data
ianum = '-1-';
iinum = '-3-';
count = [1 1];

for ii = 1:numel(d)
    if contains(d(ii).name, 'ramp') && contains(d(ii).name, ianum)
        iadata(count(1)) = load([d(ii).folder filesep d(ii).name]);
        count(1) = count(1)+1;
    elseif contains(d(ii).name, 'ramp') && contains(d(ii).name, iinum)
        iidata(count(2)) = load([d(ii).folder filesep d(ii).name]);
        count(2) = count(2)+1;
    end
end

st1 = iadata(1).procdata.spiketimes;
st2 = iidata(1).procdata.spiketimes;
t = max([st1(1) st2(1)]):.001:min([st1(end) st2(end)]);
s1 = interp1(st1, iadata(1).procdata.ifr, t);
s2 = interp1(st2, iidata(1).procdata.ifr, t);
%%
S = [s1; s2];

Mdl = rica(S, 2);

plot(t, Mdl.TransformWeights)
%%
K = optimizeK(s1, s2)
X = K*[s1; s2];

x1 = X(1, :);
x2 = X(2, :);

subplot(311)
plot(t, s1, t, s2)
legend('R_{IA}', 'R_{II}')
title('original spikes')

subplot(312)
plot(t, x1)
yyaxis right
plot(t, x2)
legend('x_1', 'x_2')
ax = gca;
ax.YAxis(1).Limits = [-2e-2 4e-2];
ax.YAxis(2).Limits = [-5e-5 8e-5];

subplot(313)
plot(t, x1, t, cumtrapz(x2) + x1(1))
legend('x_1', '\int{x_2}dt')
%%
count = [1 1];
for ii = 1:numel(d)
    if contains(d(ii).name, 'triangle') && contains(d(ii).name, ianum)
        iadata(count(1)) = load([d(ii).folder filesep d(ii).name]);
        count(1) = count(1)+1;
    elseif contains(d(ii).name, 'triangle') && contains(d(ii).name, iinum)
        iidata(count(2)) = load([d(ii).folder filesep d(ii).name]);
        count(2) = count(2)+1;
    end
end


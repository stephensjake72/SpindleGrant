clc; clear; close all;

load('lookuptable.mat')

check1 = strcmp(T.stretchtype, 'workloop');
check2 = T.amp == 2;
check3 = strcmp(T.Animal, 'A100142-25-152');
T1 = T(check1 & check2 & check3, :);
T2 = T1;

cells = unique(T1.cellnum);
phases = [0 25 50 75];
count = 1;
for n = 1:length(cells)
    T3 = T2(strcmp(T2.cellnum, cells{n}), :);
    if height(T3) ~= 4
        for m = 1:4
            rows = find(T3.phase == phases(m));
            if length(rows) > 1
                figure('Position', [200 350 400 400])
                for r = 1:length(rows)
                    data = load(T3.FileAddress{rows(r)});
                    subplot(length(rows), 1, r)
                    plot(data.R.t, data.R.r); hold on
                    plot(data.procdata.spiketimes, data.procdata.ifr, '.k')
                    title(num2str(rows(r)))
                end
                [ind, ~] = listdlg('ListString', num2str(rows));
                rowdelete = rows(ind);
                T3(rowdelete, :) = [];
                close
            end
        end
    end
    T2(count:count+3, :) = T3;
    count = count+4;
end

T2(count:end, :) = [];
%%

T0 = T2(T2.phase == 0, :);
T25 = T2(T2.phase == 25, :);
T50 = T2(T2.phase == 50, :);
T75 = T2(T2.phase == 75, :);

T0 = sortrows(T0, {'celltype', 'cellnum'});
T25 = sortrows(T25, {'celltype', 'cellnum'});
T50 = sortrows(T50, {'celltype', 'cellnum'});
T75 = sortrows(T75, {'celltype', 'cellnum'});

A0 = zeros(height(T0), 142900);
A25 = zeros(height(T25), 142900);
A50 = zeros(height(T50), 142900);
A75 = zeros(height(T75), 142900);
for n = 1:height(A0)
    data0 = load(T0.FileAddress{n});
    A0(n, :) = data0.R.r(1:length(A0));

    data25 = load(T25.FileAddress{n});
    A25(n, :) = data25.R.r(1:length(A25));

    data50 = load(T50.FileAddress{n});
    A50(n, :) = data50.R.r(1:length(A50));

    data75 = load(T75.FileAddress{n});
    A75(n, :) = data75.R.r(1:length(A75));
end
A0 = A0';
A25 = A25';
A50 = A50';
A75 = A75';
%%
colors = zeros(height(T0), 3);
iarows = find(strcmp(T0.celltype, 'IA'));
iirows = find(strcmp(T0.celltype, 'II'));
ibrows = find(strcmp(T0.celltype, 'IB'));
for n1 = 1:length(iarows)
    colors(iarows(n1), :) = [31,120,180]/255;
end
for n2 = 1:length(iirows)
    colors(iirows(n2), :) = [51,160,44]/255;
end
for n3 = 1:length(ibrows)
    colors(ibrows(n3), :) = [255,127,0]/255;
end

colors2 = [31,120,180; 51,160,44]/255;
%% NMF for stim @ 0
close all

VAF = 0;
factors = 1;
while VAF < 0.8
    [W1, H1] = nnmf(A0, factors);
    p = W1*H1;
    C = cov(A0);
    D = cov(A0-p);
    VAF = 1 - sum(diag(D))/sum(diag(C));
    factors = factors + 1;
end

dsf = 50;
figure('Position', [0 0 1800 1000])
ax1 = subplot(411); plot(A0(1:dsf:end, :)); title({'sensory matrix S'; '\phi = 0'});
legend(T0.celltype, 'Location', 'eastoutside')

ax2 = subplot(412); plot(p(1:dsf:end, :)); title({'NMF estimate S*'; ['VAF: ' num2str(VAF)]});
ax2.Position(3) = .7165;

ax3 = subplot(413); plot(W1(1:dsf:end, :)); title(['n_f = ' num2str(factors-1)]);
legend({'W_1', 'W_2'}, 'Location', 'eastoutside');
ax3.Position(3) = .7165;

ax4 = subplot(414); plot(H1'); title('weights')
ax4.Position(3) = .7165;

colororder(ax1, colors); colororder(ax2, colors); 
colororder(ax3, colors2); colororder(ax4, colors2);
saveas(gcf, '/Users/jacobstephens/Documents/Data/Workloop/nnmf1.jpg', 'jpg')
%%
close all

VAF = 0;
factors = 1;
while VAF < 0.8
    [W2, H2] = nnmf(A25, factors);
    p = W2*H2;
    C = cov(A25);
    D = cov(A25-p);
    VAF = 1 - sum(diag(D))/sum(diag(C));
    factors = factors + 1;
end

dsf = 50;
figure('Position', [0 0 1800 1000])
ax1 = subplot(411); plot(A25(1:dsf:end, :)); title({'sensory matrix S'; '\phi = 25'});
legend(T25.celltype, 'Location', 'eastoutside')

ax2 = subplot(412); plot(p(1:dsf:end, :)); title({'NMF estimate S*'; ['VAF: ' num2str(VAF)]});
ax2.Position(3) = .7165;

ax3 = subplot(413); plot(W2(1:dsf:end, :)); title(['n_f = ' num2str(factors-1)]);
legend({'W_1', 'W_2'}, 'Location', 'eastoutside');
ax3.Position(3) = .7165;

ax4 = subplot(414); plot(H2'); title('weights')
ax4.Position(3) = .7165;

colororder(ax1, colors); colororder(ax2, colors); 
colororder(ax3, colors2); colororder(ax4, colors2);
saveas(gcf, '/Users/jacobstephens/Documents/Data/Workloop/nnmf2.jpg', 'jpg')
%%
close all

VAF = 0;
factors = 1;
while VAF < 0.8
    [W3, H3] = nnmf(A50, factors);
    p = W3*H3;
    C = cov(A50);
    D = cov(A50-p);
    VAF = 1 - sum(diag(D))/sum(diag(C));
    factors = factors + 1;
end

dsf = 50;
figure('Position', [0 0 1800 1000])
ax1 = subplot(411); plot(A50(1:dsf:end, :)); title({'sensory matrix S'; '\phi = 50'});
legend(T50.celltype, 'Location', 'eastoutside')

ax2 = subplot(412); plot(p(1:dsf:end, :)); title({'NMF estimate S*'; ['VAF: ' num2str(VAF)]});
ax2.Position(3) = .7165;

ax3 = subplot(413); plot(W3(1:dsf:end, :)); title(['n_f = ' num2str(factors-1)]);
legend({'W_1', 'W_2'}, 'Location', 'eastoutside');
ax3.Position(3) = .7165;

ax4 = subplot(414); plot(H3'); title('weights')
ax4.Position(3) = .7165;

colororder(ax1, colors); colororder(ax2, colors); 
colororder(ax3, colors2); colororder(ax4, colors2);
saveas(gcf, '/Users/jacobstephens/Documents/Data/Workloop/nnmf3.jpg', 'jpg')
%%
close all

VAF = 0;
factors = 1;
while VAF < 0.8
    [W4, H4] = nnmf(A75, factors);
    p = W4*H4;
    C = cov(A75);
    D = cov(A75-p);
    VAF = 1 - sum(diag(D))/sum(diag(C));
    factors = factors + 1;
end

dsf = 50;
figure('Position', [0 0 1800 1000])
ax1 = subplot(411); plot(A75(1:dsf:end, :)); title({'sensory matrix S'; '\phi = 75'});
legend(T75.celltype, 'Location', 'eastoutside')

ax2 = subplot(412); plot(p(1:dsf:end, :)); title({'NMF estimate S*'; ['VAF: ' num2str(VAF)]});
ax2.Position(3) = .7165;

ax3 = subplot(413); plot(W4(1:dsf:end, :)); title(['n_f = ' num2str(factors-1)]);
legend({'W_1', 'W_2'}, 'Location', 'eastoutside');
ax3.Position(3) = .7165;

ax4 = subplot(414); plot(H4'); title('weights')
ax4.Position(3) = .7165;

colororder(ax1, colors); colororder(ax2, colors); 
colororder(ax3, colors2); colororder(ax4, colors2);
saveas(gcf, '/Users/jacobstephens/Documents/Data/Workloop/nnmf4.jpg', 'jpg')

%%
figure(5)
subplot(611); plot(H1'); title('\phi = 0'); ylabel('W')
subplot(612); plot(H2'); title('\phi = 25'); ylabel('W')
subplot(613); plot(H3'); title('\phi = 50'); ylabel('W')
subplot(614); plot(H4'); title('\phi = 75'); ylabel('W')
subplot(6, 1, [5 6]);
plot(H1(1, :), 'Color', [244,109,67]/255);
hold on
plot(H1(2, :), 'Color', [50,136,189]/255);
plot(H2(1, :), 'Color', [244,109,67]/255);
plot(H2(2, :), 'Color', [50,136,189]/255);
plot(H3(1, :), 'Color', [244,109,67]/255);
plot(H3(2, :), 'Color', [50,136,189]/255);
plot(H4(1, :), 'Color', [244,109,67]/255);
plot(H4(2, :), 'Color', [50,136,189]/255);
ylabel('W')
xlabel('cell number')
saveas(gcf, '/Users/jacobstephens/Documents/Data/Workloop/nnmf5.jpg', 'jpg')

%%
P11 = W1*H1;
P12 = W1*H2;
P13 = W1*H3;
P14 = W1*H4;

V11 = 1 - sum(diag(cov(A0 - P11)))/sum(diag(cov(A0)));
V12 = 1 - sum(diag(cov(A0 - P12)))/sum(diag(cov(A0)));
V13 = 1 - sum(diag(cov(A0 - P13)))/sum(diag(cov(A0)));
V14 = 1 - sum(diag(cov(A0 - P14)))/sum(diag(cov(A0)));

figure(6)
colororder(colors)
subplot(511); plot(A0(1:dsf:end, :))
subplot(512); plot(P11(1:dsf:end, :)); title(['W_1H_1 VAF:' num2str(V11)])
subplot(513); plot(P12(1:dsf:end, :)); title(['W_1H_2 VAF:' num2str(V12)])
subplot(514); plot(P13(1:dsf:end, :)); title(['W_1H_3 VAF:' num2str(V13)])
subplot(515); plot(P14(1:dsf:end, :)); title(['W_1H_4 VAF:' num2str(V14)])
saveas(gcf, '/Users/jacobstephens/Documents/Data/Workloop/nnmf6.jpg', 'jpg')

% //////////////////////////////////////
P21 = W2*H1;
P22 = W2*H2;
P23 = W2*H3;
P24 = W2*H4;

V21 = 1 - sum(diag(cov(A25 - P21)))/sum(diag(cov(A25)));
V22 = 1 - sum(diag(cov(A25 - P22)))/sum(diag(cov(A25)));
V23 = 1 - sum(diag(cov(A25 - P23)))/sum(diag(cov(A25)));
V24 = 1 - sum(diag(cov(A25 - P24)))/sum(diag(cov(A25)));

figure(7)
colororder(colors)
subplot(511); plot(A25(1:dsf:end, :)); title('sensory signals')
subplot(512); plot(P21(1:dsf:end, :)); title(['W_2H_1 VAF:' num2str(V21)])
subplot(513); plot(P22(1:dsf:end, :)); title(['W_2H_2 VAF:' num2str(V22)])
subplot(514); plot(P23(1:dsf:end, :)); title(['W_2H_3 VAF:' num2str(V23)])
subplot(515); plot(P24(1:dsf:end, :)); title(['W_2H_4 VAF:' num2str(V24)])

saveas(gcf, '/Users/jacobstephens/Documents/Data/Workloop/nnmf7.jpg', 'jpg')


% ////////////////////////////////////////////////////////////
P31 = W3*H1;
P32 = W3*H2;
P33 = W3*H3;
P34 = W3*H4;

V31 = 1 - sum(diag(cov(A50 - P31)))/sum(diag(cov(A50)));
V32 = 1 - sum(diag(cov(A50 - P32)))/sum(diag(cov(A50)));
V33 = 1 - sum(diag(cov(A50 - P33)))/sum(diag(cov(A50)));
V34 = 1 - sum(diag(cov(A50 - P34)))/sum(diag(cov(A50)));

figure(8)
colororder(colors)
subplot(511); plot(A50(1:dsf:end, :))
subplot(512); plot(P31(1:dsf:end, :)); title(['W_3H_1 VAF:' num2str(V31)])
subplot(513); plot(P32(1:dsf:end, :)); title(['W_3H_2 VAF:' num2str(V32)])
subplot(514); plot(P33(1:dsf:end, :)); title(['W_3H_3 VAF:' num2str(V33)])
subplot(515); plot(P34(1:dsf:end, :)); title(['W_3H_4 VAF:' num2str(V34)])
saveas(gcf, '/Users/jacobstephens/Documents/Data/Workloop/nnmf8.jpg', 'jpg')

% /////////////////////////////////////////////

P41 = W4*H1;
P42 = W4*H2;
P43 = W4*H3;
P44 = W4*H4;

V41 = 1 - sum(diag(cov(A75 - P41)))/sum(diag(cov(A75)));
V42 = 1 - sum(diag(cov(A75 - P42)))/sum(diag(cov(A75)));
V43 = 1 - sum(diag(cov(A75 - P43)))/sum(diag(cov(A75)));
V44 = 1 - sum(diag(cov(A75 - P44)))/sum(diag(cov(A75)));

figure(9)
colororder(colors)
subplot(511); plot(A75(1:dsf:end, :))
subplot(512); plot(P41(1:dsf:end, :)); title(['W_4H_1 VAF:' num2str(V41)])
subplot(513); plot(P42(1:dsf:end, :)); title(['W_4H_2 VAF:' num2str(V42)])
subplot(514); plot(P43(1:dsf:end, :)); title(['W_4H_3 VAF:' num2str(V43)])
subplot(515); plot(P44(1:dsf:end, :)); title(['W_4H_4 VAF:' num2str(V44)])
saveas(gcf, '/Users/jacobstephens/Documents/Data/Workloop/nnmf9.jpg', 'jpg')


%%
figure(10)
CM = [V11 V12 V13 V14; 
    V21 V22 V23 V24; 
    V31 V32 V33 V34; 
    V41 V42 V43 V44];
% H1 = [V11 V21 V31 V41]';
% H2 = [V12 V22 V32 V42]';
% H3 = [V13 V23 V33 V43]';
% H4 = [V14 V24 V34 V44]';
% TM = table(H1, H2, H3, H4, 'RowNames', {'W1', 'W2', 'W3', 'W4'})

heatmap(CM); xlabel('H'); ylabel('W'); title('VAF')
saveas(gcf, '/Users/jacobstephens/Documents/Data/Workloop/nnmf10.jpg', 'jpg')

%%
W2F = flip(W2, 2);
W3F = flip(W3, 2);
H2F = flip(H2);
H3F = flip(H3);

V11 = 1 - sum(diag(cov(A0 - W1*H1)))/sum(diag(cov(A0)));
V12 = 1 - sum(diag(cov(A0 - W1*H2F)))/sum(diag(cov(A0)));
V13 = 1 - sum(diag(cov(A0 - W1*H3F)))/sum(diag(cov(A0)));
V14 = 1 - sum(diag(cov(A0 - W1*H4)))/sum(diag(cov(A0)));

V21 = 1 - sum(diag(cov(A25 - W2F*H1)))/sum(diag(cov(A25)));
V22 = 1 - sum(diag(cov(A25 - W2F*H2F)))/sum(diag(cov(A25)));
V23 = 1 - sum(diag(cov(A25 - W2F*H3F)))/sum(diag(cov(A25)));
V24 = 1 - sum(diag(cov(A25 - W2F*H4)))/sum(diag(cov(A25)));

V31 = 1 - sum(diag(cov(A50 - W3F*H1)))/sum(diag(cov(A50)));
V32 = 1 - sum(diag(cov(A50 - W3F*H2F)))/sum(diag(cov(A50)));
V33 = 1 - sum(diag(cov(A50 - W3F*H3F)))/sum(diag(cov(A50)));
V34 = 1 - sum(diag(cov(A50 - W3F*H4)))/sum(diag(cov(A50)));

V41 = 1 - sum(diag(cov(A75 - W4*H1)))/sum(diag(cov(A75)));
V42 = 1 - sum(diag(cov(A75 - W4*H2F)))/sum(diag(cov(A75)));
V43 = 1 - sum(diag(cov(A75 - W4*H3F)))/sum(diag(cov(A75)));
V44 = 1 - sum(diag(cov(A75 - W4*H4)))/sum(diag(cov(A75)));

CM = [V11 V12 V13 V14; 
    V21 V22 V23 V24; 
    V31 V32 V33 V34; 
    V41 V42 V43 V44];
figure(11)
heatmap(CM); xlabel('H'); ylabel('W'); title('VAF')
saveas(gcf, '/Users/jacobstephens/Documents/Data/Workloop/nnmf11.jpg', 'jpg')

%%
figure(12)
subplot(411); plot(W1); subplot(412); plot(W2); subplot(413); plot(W3); subplot(414); plot(W4)
saveas(gcf, '/Users/jacobstephens/Documents/Data/Workloop/nnmf12.jpg', 'jpg')


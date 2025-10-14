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
                liststr = num2str(rows);
                [ind, ~] = listdlg('ListString', liststr);
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
c = cell(1, 4);
A = struct('S', c, ...
    'phase', c, ...
    'W', c, ...
    'H', c, ...
    'VAF', c, ...
    't', c, ...
    'L', c, ...
    'celltypes', c);
%%

np = 142900;
phases = [0 25 50 75];
for p = 1:length(phases)
    A(p).phase = phases(p);
    A(p).S = zeros(np, 14);
    A(p).L = zeros(np, 14);
    subtab = T2(T2.phase == phases(p), :);
    subtab = sortrows(subtab, {'celltype', 'cellnum'});
    for q = 1:height(subtab)
        data = load(subtab.FileAddress{q});
        A(p).L(:, q) = data.procdata.Lmt(1:np);
        A(p).S(:, q) = data.R.r(1:np);
        A(p).t = data.R.t(1:np);
    end
    A(p).celltypes = subtab.celltype;
    figure(p)
    subplot(211); plot(A(p).t, A(p).L, 'color', [.8 .8 .8])
    subplot(212); plot(A(p).t, A(p).S)
end

%%
for r = 1:4
    factors = 1;
    [W, H] = nnmf(A(r).S, factors);
    VAF = 1 - sum(diag(cov(A(r).S - W*H)))/sum(diag(cov(A(r).S)));
    while VAF < 0.8
        factors = factors + 1;
        [W, H] = nnmf(A(r).S, factors);
        VAF = 1 - sum(diag(cov(A(r).S - W*H)))/sum(diag(cov(A(r).S)));
    end
    disp([factors VAF])
    A(r).W = W;
    A(r).H = H;
    A(r).VAF = VAF;
end


%%
clear T1 T2 T3
check1 = strcmp(T.stretchtype, 'workloop');
check2 = T.amp == 4;
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
                liststr = num2str(rows);
                [ind, ~] = listdlg('ListString', liststr);
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

B = struct('S', c, ...
    'phase', c, ...
    'W', c, ...
    'H', c, ...
    'VAF', c, ...
    't', c, ...
    'L', c, ...
    'celltypes', c);

np = 142900;
phases = [0 25 50 75];
for p = 1:length(phases)
    B(p).phase = phases(p);
    B(p).S = zeros(np, 14);
    B(p).L = zeros(np, 14);
    subtab = T2(T2.phase == phases(p), :);
    subtab = sortrows(subtab, {'celltype', 'cellnum'});
    for q = 1:height(subtab)
        data = load(subtab.FileAddress{q});
        B(p).L(:, q) = data.procdata.Lmt(1:np);
        B(p).S(:, q) = data.R.r(1:np);
        B(p).t = data.R.t(1:np);
    end
    B(p).celltypes = subtab.celltype;
    figure(p)
    subplot(211); plot(B(p).t, B(p).L, 'color', [.8 .8 .8])
    subplot(212); plot(B(p).t, B(p).S)
end
%%
for r = 1:4
    factors = 1;
    [W, H] = nnmf(B(r).S, factors);
    VAF = 1 - sum(diag(cov(B(r).S - W*H)))/sum(diag(cov(B(r).S)));
    while VAF < 0.8
        factors = factors + 1;
        [W, H] = nnmf(B(r).S, factors);
        VAF = 1 - sum(diag(cov(B(r).S - W*H)))/sum(diag(cov(B(r).S)));
    end
    disp([factors VAF])
    B(r).W = W;
    B(r).H = H;
    B(r).VAF = VAF;
end

%%
iacolor = [43,131,186]/255; iicolor = [171,221,164]/255; ibcolor = [253,174,97]/255;
colors = strcmp(B(1).celltypes, 'IA')*iacolor + ...
    strcmp(B(1).celltypes, 'II')*iicolor + ...
    strcmp(B(1).celltypes, 'IB')*ibcolor;


figure(5)
ax1 = subplot(411); plot(B(1).S);
legend(B(1).celltypes, 'Location', 'eastoutside')
ax1.Position(3) = .6873;
ax2 = subplot(412); plot(B(2).S);
ax2.Position(3) = .6873;
ax3 = subplot(413); plot(B(3).S);
ax3.Position(3) = .6873;
ax4 = subplot(414); plot(B(4).S);
ax4.Position(3) = .6873;
colororder(colors)

colors2 = [43,131,186; 171,221,164; 253,174,97]/255;

figure(6)
ax1 = subplot(211); plot(B(1).S); colororder(ax1, colors); 
legend(B(1).celltypes, 'Location', 'eastoutside')
ax2 = subplot(212); plot(B(1).W); colororder(ax2, colors2)
ax2.Position(3) = ax1.Position(3);

figure(7)
ax1 = subplot(211); plot(B(2).S); colororder(ax1, colors); 
legend(B(2).celltypes, 'Location', 'eastoutside')
ax2 = subplot(212); plot(B(2).W); colororder(ax2, colors2)
ax2.Position(3) = ax1.Position(3);

figure(8)
ax1 = subplot(211); plot(B(3).S); colororder(ax1, colors); 
legend(B(3).celltypes, 'Location', 'eastoutside')
ax2 = subplot(212); plot(B(3).W); colororder(ax2, colors2)
ax2.Position(3) = ax1.Position(3);

figure(9)
ax1 = subplot(211); plot(B(4).S); colororder(ax1, colors); 
legend(B(4).celltypes, 'Location', 'eastoutside')
ax2 = subplot(212); plot(B(4).W); colororder(ax2, colors2)
ax2.Position(3) = ax1.Position(3);
%%
VA = zeros(5, 4); VB = zeros(5, 4);

for n = 1:5
    for m = 1:4
        [W, H] = nnmf(A(m).S, n);
        VA(n, m) = 1 - sum(diag(cov(A(m).S - W*H)))/sum(diag(cov(A(m).S)));
        [W, H] = nnmf(B(m).S, n);
        VB(n, m) = 1 - sum(diag(cov(B(m).S - W*H)))/sum(diag(cov(B(m).S)));
    end
end
%%
colors = [215,25,28;
    253,174,97;
    171,221,164;
    43,131,186]/255;
plot(1:5, VA, 'Marker', 'x');
hold on; plot(1:5, VB, 'Marker', 'o');
xlabel('n_{factors}'); ylabel('VAF')
colororder(colors)
ylim([0.5 1])
legend({'2mm 0%', '2mm 25%', '2mm 50%', '2mm 75%', ...
    '4mm 0%', '4mm 25%', '4mm 50%', '4mm 75%'}, ...
    'Location', 'southeast')
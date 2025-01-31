function sc = computeTriSimSC(time, r)
breaks = [0 1.5 3 4.5];
sc = zeros(1, 3);

t1 = time(time > breaks(1) & time < breaks(2));
r1 = r(time > breaks(1) & time < breaks(2));

t2 = time(time > breaks(2) & time < breaks(3));
r2 = r(time > breaks(2) & time < breaks(3));

t3 = time(time > breaks(3) & time < breaks(4));
r3 = r(time > breaks(3) & time < breaks(4));

sc(1) = trapz(t1, r1);
sc(2) = trapz(t2, r2);
sc(3) = trapz(t3, r3);
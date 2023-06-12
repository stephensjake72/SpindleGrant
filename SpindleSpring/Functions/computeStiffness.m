function stiffness = computeStiffness(data, thr)
Lmt = data.Lmt;
Lf = data.Lf;
Fmt = data.Fmt;

% find where force is approx. threshold
id = find(Fmt >= thr, 1, 'first');
if isempty(id)
    stiffness = 0;
    return
end
% take window around the threshold point
ids = (id-50):(id+50);

% fit 2nd order polynomial to the points
pmt = polyfit(Lmt(ids), Fmt(ids), 2);
pf = polyfit(Lf(ids), Fmt(ids), 2);
pl = polyfit(Lmt(ids), Lf(ids), 2);

% compute centers
Lmt_c = Lmt(id);
Fmt_c = Fmt(id);
Lf_c = Lf(id);

% compute and evaluate slopes
kMTU = 2*pmt(1)*Lmt_c + pmt(2);
kFas = 2*pf(1)*Lf_c + pf(2);
dLfdLmt = 2*pl(1)*Lmt_c + pl(2); 

stiffness.kMTU = kMTU;
stiffness.kFas = kFas;
stiffness.dLfdLmt = dLfdLmt;
stiffness.Fmtcenter = Fmt_c;
stiffness.Lmtcenter = Lmt_c;
stiffness.Lfcenter = Lf_c;
stiffness.FasExc = max(data.Lf) - min(data.Lf);
%     stiffness.Fthr = Fmt(ids(1));
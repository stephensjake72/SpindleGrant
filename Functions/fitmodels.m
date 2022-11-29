function models = fitmodels(data)
st = data.spiketimes;
ifr = data.ifr;
Lf = data.Lf;
Lmt = data.Lmt;
vf = data.vf;
vmt = data.vmt;
Fmt = data.Fmt;
time = data.time;

Lfst = interp1(time, Lf, st);
vfst = interp1(time, vf, st);
Lmtst = interp1(time, Lmt, st);
vmtst = interp1(time, vmt, st);
Fmtst = interp1(time, Fmt, st);

Lfmod = fitlm(Lfst, ifr, 'Intercept', false);
vfmod = fitlm(vfst, ifr, 'Intercept', false);
Lmtmod = fitlm(Lmtst, ifr, 'Intercept', false);
vmtmod = fitlm(vmtst, ifr, 'Intercept', false);
Fmtmod = fitlm(Fmtst, ifr, 'Intercept', false);

pLf = corrcoef(Lfmod.Coefficients.Estimate(1)*Lfst, ifr);
pvf = corrcoef(vfmod.Coefficients.Estimate(1)*vfst, ifr);
pLmt = corrcoef(Lmtmod.Coefficients.Estimate(1)*Lmtst, ifr);
pvmt = corrcoef(vmtmod.Coefficients.Estimate(1)*vmtst, ifr);
pFmt = corrcoef(Fmtmod.Coefficients.Estimate(1)*Fmtst, ifr);

models.mLf = Lfmod.Coefficients.Estimate(1);
models.rLf = pLf(2, 1);
models.mvf = vfmod.Coefficients.Estimate(1);
models.rvf = pvf(2, 1);
models.mLmt = Lmtmod.Coefficients.Estimate(1);
models.rLmt = pLmt(2, 1);
models.mvmt = vmtmod.Coefficients.Estimate(1);
models.rvmt = pvmt(2, 1);
models.mFmt = Fmtmod.Coefficients.Estimate(1);
models.rFmt = pFmt(2, 1);
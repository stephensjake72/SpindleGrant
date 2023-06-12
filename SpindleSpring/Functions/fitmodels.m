function models = fitmodels(data, type)
st = data.spiketimes;
ifr = data.ifr;
time = data.time;
% interpolate
Lfst = interp1(time, data.Lf, st);
Lmtst = interp1(time, data.Lmt, st);
vfst = interp1(time, data.vf, st);
vmtst = interp1(time, data.vmt, st);
Fmtst = interp1(time, data.Fmt, st);

switch type
    case 'ramp'
        startT = 0.15;
    case 'triangle'
        startT = 1.7;
    case 'sine'
        startT = 0.5;
end

keep = st > startT;

ifr = ifr(keep);
Lmtst = Lmtst(keep);
vmtst = vmtst(keep);
Lfst = Lfst(keep);
vfst = vfst(keep);
Fmtst = Fmtst(keep);

Lfmod = fitlm(Lfst, ifr);
vfmod = fitlm(vfst, ifr);
Lmtmod = fitlm(Lmtst, ifr);
vmtmod = fitlm(vmtst, ifr);
Fmtmod = fitlm(Fmtst, ifr);

models.mLf = Lfmod.Coefficients.Estimate(2);
models.bLf = Lfmod.Coefficients.Estimate(1);
models.rLf = Lfmod.Rsquared.Ordinary;
models.mvf = vfmod.Coefficients.Estimate(2);
models.bvf = vfmod.Coefficients.Estimate(1);
models.rvf = vfmod.Rsquared.Ordinary;
models.mLmt = Lmtmod.Coefficients.Estimate(2);
models.bLmt = Lmtmod.Coefficients.Estimate(1);
models.rLmt = Lmtmod.Rsquared.Ordinary;
models.mvmt = vmtmod.Coefficients.Estimate(2);
models.bvmt = vmtmod.Coefficients.Estimate(1);
models.rvmt = vmtmod.Rsquared.Ordinary;
models.mFmt = Fmtmod.Coefficients.Estimate(2);
models.bFmt = Fmtmod.Coefficients.Estimate(1);
models.rFmt = Fmtmod.Rsquared.Ordinary;
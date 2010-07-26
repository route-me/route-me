#ifndef lint
static const char SCCSID[]="@(#)mk_cheby.c	4.5	94/03/22	GIE	REL";
#endif
#include "projects.h"
	static void /* sum coefficients less than res */
eval(projUV **w, int nu, int nv, double res, projUV *resid) {
	int i, j;
	double ab;
	projUV *s;

	resid->u = resid->v = 0.;
	for (i = 0; i < nu; ++i)
		for (s = w[i], j = 0; j < nv; ++j, ++s) {
			if ((ab = fabs(s->u)) < res)
				resid->u += ab;
			if ((ab = fabs(s->v)) < res)
				resid->v += ab;
		}
}
	static Tseries * /* create power series structure */
makeT(int nru, int nrv) {
	Tseries *Ts;
	int i;

	if ((Ts = (Tseries *)pj_malloc(sizeof(Tseries))) &&
		(Ts->cu = (struct PW_COEF *)pj_malloc(
			sizeof(struct PW_COEF) * nru)) &&
		(Ts->cv = (struct PW_COEF *)pj_malloc(
			sizeof(struct PW_COEF) * nrv))) {
		for (i = 0; i < nru; ++i)
			Ts->cu[i].c = 0;
		for (i = 0; i < nrv; ++i)
			Ts->cv[i].c = 0;
		return Ts;
	} else
		return 0;
}
	Tseries *
mk_cheby(projUV a, projUV b, double res, projUV *resid, projUV (*func)(projUV), 
	int nu, int nv, int power) {
	int j, i, nru, nrv, *ncu, *ncv;
	Tseries *Ts = 0;
	projUV **w;
	double cutres;

	if (!(w = (projUV **)vector2(nu, nv, sizeof(projUV))) ||
		!(ncu = (int *)vector1(nu + nv, sizeof(int))))
		return 0;
	ncv = ncu + nu;
	if (!bchgen(a, b, nu, nv, w, func)) {
		projUV *s;
		double *p;

		/* analyse coefficients and adjust until residual OK */
		cutres = res;
		for (i = 4; i ; --i) {
			eval(w, nu, nv, cutres, resid);
			if (resid->u < res && resid->v < res)
				break;
			cutres *= 0.5;
		}
		if (i <= 0) /* warn of too many tries */
			resid->u = - resid->u;
		/* apply cut resolution and set pointers */
		nru = nrv = 0;
		for (j = 0; j < nu; ++j) {
			ncu[j] = ncv[j] = 0; /* clear column maxes */
			for (s = w[j], i = 0; i < nv; ++i, ++s) {
				if (fabs(s->u) < cutres) /* < resolution ? */
					s->u = 0.;		/* clear coefficient */
				else
					ncu[j] = i + 1;	/* update column max */
				if (fabs(s->v) < cutres) /* same for v coef's */
					s->v = 0.;
				else
					ncv[j] = i + 1;
			}
			if (ncu[j]) nru = j + 1;	/* update row max */
			if (ncv[j]) nrv = j + 1;
		}
		if (power) { /* convert to bivariate power series */
			if (!bch2bps(a, b, w, nu, nv))
				goto error;
			/* possible change in some row counts, so readjust */
			nru = nrv = 0;
			for (j = 0; j < nu; ++j) {
				ncu[j] = ncv[j] = 0; /* clear column maxes */
				for (s = w[j], i = 0; i < nv; ++i, ++s) {
					if (s->u)
						ncu[j] = i + 1;	/* update column max */
					if (s->v)
						ncv[j] = i + 1;
				}
				if (ncu[j]) nru = j + 1;	/* update row max */
				if (ncv[j]) nrv = j + 1;
			}
			Ts = makeT(nru, nrv);
			if (Ts) {
				Ts->a = a;
				Ts->b = b;
				Ts->mu = nru - 1;
				Ts->mv = nrv - 1;
				Ts->power = 1;
				for (i = 0; i < nru; ++i) /* store coefficient rows for u */
					Ts->cu[i].m = ncu[i];
					if (Ts->cu[i].m)
						if ((p = Ts->cu[i].c =
								(double *)pj_malloc(sizeof(double) * ncu[i])))
							for (j = 0; j < ncu[i]; ++j)
								*p++ = (w[i] + j)->u;
						else
							goto error;
				for (i = 0; i < nrv; ++i) /* same for v */
					Ts->cv[i].m = ncv[i];
					if (Ts->cv[i].m)
						if ((p = Ts->cv[i].c =
								(double *)pj_malloc(sizeof(double) * ncv[i])))
							for (j = 0; j < ncv[i]; ++j)
								*p++ = (w[i] + j)->v;
						else
							goto error;
			}
		} else if ((Ts = makeT(nru, nrv))) {
			/* else make returned Chebyshev coefficient structure */
			Ts->mu = nru - 1; /* save row degree */
			Ts->mv = nrv - 1;
			Ts->a.u = a.u + b.u; /* set argument scaling */
			Ts->a.v = a.v + b.v;
			Ts->b.u = 1. / (b.u - a.u);
			Ts->b.v = 1. / (b.v - a.v);
			Ts->power = 0;
			for (i = 0; i < nru; ++i) /* store coefficient rows for u */
				Ts->cu[i].m = ncu[i];
				if (Ts->cu[i].m)
					if ((p = Ts->cu[i].c =
							(double *)pj_malloc(sizeof(double) * ncu[i])))
						for (j = 0; j < ncu[i]; ++j)
							*p++ = (w[i] + j)->u;
					else
						goto error;
			for (i = 0; i < nrv; ++i) /* same for v */
				Ts->cv[i].m = ncv[i];
				if (Ts->cv[i].m)
					if ((p = Ts->cv[i].c =
							(double *)pj_malloc(sizeof(double) * ncv[i])))
						for (j = 0; j < ncv[i]; ++j)
							*p++ = (w[i] + j)->v;
					else
						goto error;
		} else
			goto error;
	}
	goto gohome;
error:
	if (Ts) { /* pj_dalloc up possible allocations */
		for (i = 0; i <= Ts->mu; ++i)
			if (Ts->cu[i].c)
				pj_dalloc(Ts->cu[i].c);
		for (i = 0; i <= Ts->mv; ++i)
			if (Ts->cv[i].c)
				pj_dalloc(Ts->cv[i].c);
		pj_dalloc(Ts);
	}
	Ts = 0;
gohome:
	freev2((void **) w, nu);
	pj_dalloc(ncu);
	return Ts;
}

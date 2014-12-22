elliptic_curve_tables
=====================

Tables of elliptic curves computed using p-adic overconvergent methods.

* input_file_tr.txt: Tables of elliptic curves over totally real fields.
* input_file_atr.txt: Tables of elliptic curves over ATR fields.

A typical line of these files corresponding to a found curve is as follows:
[Fractional ideal (r^2 + 1), -243, x^3 - 3, r - 2, r - 1, 1, (r, 0, r + 1, -575*r^2 - 829*r - 1195, -13327*r^2 - 19221*r - 27721), 72, 7.97286134927707],\

This is a list of the type
[N, disc, pol, P, D, n, ainvs, Nnorm, covol]
where
- N: the level/conductor, of the form N = P*D*n
- disc: the discriminant of the field K = Q(r),
- pol: the minimal polynomial of the generator r of K,
- P, D, n: generator for respective ideals,
- ainvs: The a-invariants a1,a2,a3,a4,a6 of the elliptic curve E,
- Nnorm: the (absolute) norm of N,
- covol: the covolume of the relevant arithmetic group, which in part measures the difficulty of the calculation.

If the curve has not been found, a (hopefully informative) message string appears in the place of ainvs. For instance , the following line corresponds to a level whose cohomology does not have Hecke-rational lines:
[Fractional ideal (r^2 - r + 4), -411, x^3 - x^2 + 5*x - 2, r, 2*r^2 - r + 9, 1, 'Err coh (Group does not seem to be attached to an elliptic curve)', 167, 5.84403354912894],\

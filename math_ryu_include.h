
#define D_BUF    32
#define LD_BUF   40
#define F128_BUF 48

#if MAX_DEC_DIG == 17
#  define MAN_BUF  D_BUF
#  define EXP_BUF  8

#elif MAX_DEC_DIG == 21
#  define MAN_BUF  LD_BUF
#  define EXP_BUF  12

#else
#  define MAN_BUF  F128_BUF
#  define EXP_BUF  12
#endif

#define SIS_PERL_VERSION PERL_REVISION*1000000+PERL_VERSION*1000+PERL_SUBVERSION

#if SIS_PERL_VERSION >= 5012000   /* perl-5.12.0 and later */
#  define MORTALIZED_PV(x) newSVpvn_flags(x,strlen(x),SVs_TEMP)
#else
#  define MORTALIZED_PV(x) sv_2mortal(newSVpv(x,0))
#endif

#ifndef Newxz
#  define Newxz(v,n,t) Newz(0,v,n,t)
#endif

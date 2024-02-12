#ifdef  __MINGW32__
#ifndef __USE_MINGW_ANSI_STDIO
#define __USE_MINGW_ANSI_STDIO 1
#endif
#endif

#define PERL_NO_GET_CONTEXT 1

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <ryu.h>
#include <ryu_parse.h>

#ifndef _MSC_VER
#  define __STDC_WANT_DEC_FP__ 1
#  include <ryu.h>
#  include <generic_128.h>    /* modified to include stdbool.h */
#  include <ryu_generic_128.h>
#  include <stdbool.h>
#  include <quadmath.h>
#endif

#include "math_ryu_include.h"

typedef struct floating_decimal_128 t_fd128;

double M_RYU_s2d(char * buffer) {
#if NVSIZE == 8
  double nv;
  s2d(buffer, &nv);
  return nv;
#else
  PERL_UNUSED_ARG(buffer);
  croak("s2d() is available only to perls whose NV is of type 'double'");
#endif
}

SV * M_RYU_d2s(pTHX_ SV * nv) {
#if NVSIZE == 8
  return newSVpv(d2s(SvNV(nv)), 0);
#else
  PERL_UNUSED_ARG(nv);
  croak("d2s() is available only to perls whose NV is of type 'double'");
#endif
}

SV * ld2s(pTHX_ SV * nv) {
#ifdef USE_LONG_DOUBLE
  char * buff;
  SV * outsv;

  Newxz(buff, LD_BUF, char); /* LD_BUF defined in math_ryu_l)include.h, along with D_BUF and F128_BUF */

  if(buff == NULL) croak("Failed to allocate memory for string buffer in ld2s sub");
  generic_to_chars(long_double_to_fd128(SvNV(nv)), buff);
  outsv = newSVpv(buff, 0);
  Safefree(buff);
  return outsv;
#else
  PERL_UNUSED_ARG(nv);
  croak("ld2s() is available only to perls whose NV is of type 'long double'");
#endif
}

SV * q2s(pTHX_ SV * nv) {
#ifdef USE_QUADMATH
  char * buff;
  SV * outsv;

  Newxz(buff, F128_BUF, char);

  if(buff == NULL) croak("Failed to allocate memory for string buffer in ld2s sub");
  generic_to_chars(float128_to_fd128(SvNV(nv)), buff);
  outsv = newSVpv(buff, 0);
  Safefree(buff);
  return outsv;
#else
  PERL_UNUSED_ARG(nv);
  croak("q2s() is available only to perls whose NV is of type '__float128'");
#endif
}

int _SvIOK(SV * sv) {
    if(SvIOK(sv)) return 1;
    return 0;
}

int _SvNOK(SV * sv) {
    if(SvNOK(sv)) return 1;
    return 0;
}

int _SvPOK(SV * sv) {
    if(SvPOK(sv)) return 1;
    return 0;
}

int _SvIOKp(SV * sv) {
    if(SvIOKp(sv)) return 1;
    return 0;
}

int ryu_lln(pTHX_ SV * sv) {
  return looks_like_number(sv);
}


MODULE = Math::Ryu  PACKAGE = Math::Ryu PREFIX = M_RYU_

PROTOTYPES: DISABLE

double
M_RYU_s2d (buffer)
	char *	buffer

SV *
M_RYU_d2s (nv)
	SV *	nv
CODE:
  RETVAL = M_RYU_d2s (aTHX_ nv);
OUTPUT:  RETVAL

SV *
ld2s (nv)
	SV *	nv
CODE:
  RETVAL = ld2s (aTHX_ nv);
OUTPUT:  RETVAL

SV *
q2s (nv)
	SV *	nv
CODE:
  RETVAL = q2s (aTHX_ nv);
OUTPUT:  RETVAL

int
_SvIOK (sv)
	SV *	sv

int
_SvNOK (sv)
	SV *	sv

int
_SvPOK (sv)
	SV *	sv

int
_SvIOKp (sv)
	SV *	sv

int ryu_lln (sv)
	SV *	sv
CODE:
  RETVAL = ryu_lln (aTHX_ sv);
OUTPUT:  RETVAL

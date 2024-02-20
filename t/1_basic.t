use strict;
use warnings;
use Config;
use Math::Ryu qw(:all);

use Test::More;

if(Math::Ryu::_compiler_has_uint128()) { warn "\nCompiler HAS_UINT128_T: 1\n" }
else { warn "\nCompiler HAS_UINT128: 0\n" }

warn "MAX_DEC_DIG: ", Math::Ryu::MAX_DEC_DIG, "\n";

cmp_ok($Math::Ryu::VERSION, 'eq', '1.02', "\$Math::Ryu::VERSION is as expected");

cmp_ok(Math::Ryu::MAX_DEC_DIG, '!=', 0, "MAX_DEC_DIG is non-zero");

cmp_ok(Math::Ryu::MAX_DEC_DIG, '==', Math::Ryu::_get_max_dec_dig(), "MAX_DEC_DIG is ok");

if(Math::Ryu::MAX_DEC_DIG == 17) {
  my $s = fmtpy(d2s(sqrt 2));
  cmp_ok($s, 'eq', '1.4142135623730951', "fmtpy(d2s(sqrt(2))) is as expected");
}
elsif(Math::Ryu::MAX_DEC_DIG == 21) {
  my $s = fmtpy(ld2s(sqrt 2));
  cmp_ok($s, 'eq', '1.4142135623730950488', "fmtpy(ld2s(sqrt(2))) is as expected");
}
else {
  # Math::Ryu::MAX_DEC_DIG == 36
  my $s = fmtpy(q2s(1.4 / 10));
  cmp_ok($s, 'eq', '0.13999999999999999999999999999999999', "fmtpy(q2s(1.4 / 10)) is as expected");
}

cmp_ok(nv2s(6.0), 'eq', '6.0', "6.0 appears in expected format");

cmp_ok(nv2s(6e-7),  'eq',  '6e-07',  "Me-0P ok");
cmp_ok(nv2s(-6e-7), 'eq', '-6e-07', "-Me-0P ok");
cmp_ok(nv2s(6e-117),  'eq',  '6e-117',  "Me-PPP ok");
cmp_ok(nv2s(-6e-117), 'eq', '-6e-117', "-Me-PPP ok");
cmp_ok(nv2s(6e40),  'eq',  '6e+40',  "Me+PP ok");
cmp_ok(nv2s(-6e40), 'eq', '-6e+40', "-Me+PP ok");
cmp_ok(nv2s(6e9),   'eq',  '6000000000.0',  "Me+P ok");
cmp_ok(nv2s(-6e9),  'eq', '-6000000000.0', "-Me+P ok");

my $nvprec = Math::Ryu::NVPREC;
my $nv = ('6' . ('0' x $nvprec) . '.0') + 0;
cmp_ok(nv2s($nv),  'eq', '6' . ('0' x $nvprec) . '.0', "Me+NVPREC ok");
cmp_ok(nv2s(-$nv),  'eq', '-6' . ('0' x $nvprec) . '.0', "-Me+NVPREC ok");

$nvprec++;
$nv = ('6' . ('0' x $nvprec) . '.0') + 0;
cmp_ok(nv2s($nv),  'eq', '6e+' . "$nvprec", "Me+(NVPREC + 1)  ok");
cmp_ok(nv2s(-$nv),  'eq', '-6e+' . "$nvprec", "-Me+(NVPREC + 1)  ok");



done_testing();

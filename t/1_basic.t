use strict;
use warnings;
use Config;
use Math::Ryu qw(:all);

use Test::More;

if(Math::Ryu::_compiler_has_uint128()) { warn "Compiler HAS_UINT128_T: 1\n" }
else { warn "Compiler HAS_UINT128: 0\n" }

cmp_ok($Math::Ryu::VERSION, 'eq', '1.0', "\$Math::Ryu::VERSION is as expected");

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

done_testing();

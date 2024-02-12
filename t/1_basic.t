use strict;
use warnings;
use Config;
use Math::Ryu qw(:all);

use Test::More;

cmp_ok($Math::Ryu::VERSION, 'eq', '1.0', "\$Math::Ryu::VERSION is as expected");

if($Config{nvsize} == 8) {
  my $s = fmtpy(d2s(sqrt 2));
  cmp_ok($s, 'eq', '1.4142135623730951', "fmtpy(d2s(sqrt(2))) is as expected");
}
else {
  my $s = fmtpy(ld2s(sqrt 2));
  cmp_ok($s, 'eq', '1.4142135623730950488', "fmtpy(ld2s(sqrt(2))) is as expected");
}

done_testing();

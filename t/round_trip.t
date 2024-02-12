# Check that nv2s() is survives the round trip.
use strict;
use warnings;
use Math::Ryu qw(:all);

use Test::More;

END{ done_testing(); };

my $count = 0;

my @range = (0 .. 50, 200 .. 250, 290 .. 324);
@range = (0 .. 50, 200 .. 250, 290 .. 324, 3950 .. 4050) if Math::Ryu::MAX_DEC_DIG > 17;

for my $exp(@range) {
  $exp = "-$exp" if $exp & 1;
  for my $it(1..20) {
    my $str = (5 + int(rand(5))) . "." . random_digits() . "e$exp";

    $count ++;
    $str = '-' . $str unless $count % 5;

    my $nv = $str + 0;
    $nv /= 10 unless $count % 3;

    cmp_ok(nv2s($nv), '==', $nv, sprintf("%.17g", $nv) . ": round trip succeeds");
  }
}

sub random_digits {
    my $ret = '';
    $ret .= int(rand(10)) for 1 .. 10;
    return $ret;
}

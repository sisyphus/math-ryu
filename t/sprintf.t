# We check that spanyf(@args) returns the
# same string that pany(@args) outputs.
use strict;
use warnings;
use Math::BigInt;
use Math::Ryu qw(:all);
use Test::More;

my $nv = 1.4 / 10;
my $mbi = Math::BigInt->new(21) ** 10;
my $ref = \$nv;

my @args = (
'hello world', ' ',
$nv, ' ', "NV: $nv", ' ',
$mbi, ' ', 123456789, ' ', '987654321', ' ',
2 ** 30, ' ', -(2 ** 29), ' ', '14_', ' ', '7.3a'
);

my $dig = Math::Ryu::MAX_DEC_DIG;
my $nv_str = $dig == 17 ? '0.13999999999999999'
                        : $dig == 21 ? '0.14'
                                     : '0.13999999999999999999999999999999999';

cmp_ok(spanyf(@args), 'eq',
      "hello world $nv_str NV: 0.14 16679880978201 123456789 987654321 1073741824 -536870912 14_ 7.3a",
      'returned string is as expected');

my $str = spanyf($ref);
like($str, qr/^SCALAR\(0/, "$str starts correctly");
like($str, qr/[a-fA-F0-9]\)$/, "$str ends correctly");

done_testing();

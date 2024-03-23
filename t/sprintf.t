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

$str = nv2s($ref);
like($str, qr/\d\.0$/, "nv2s() returns a number when handed a scalar reference");

$str = '6.5rubbish';
cmp_ok(n2s($str), 'eq', '6.5', "n2s('6.5 rubbish') handled as expected");
cmp_ok(n2s('hello world'), 'eq', '0.0', "n2s('hello world') returns 0.0");

my $newstr = spanyf($str);
cmp_ok($newstr, 'eq', '6.5rubbish', "string is still assessed by spanyf() as '6.5rubbish'");

eval{my $s = n2s($mbi);};
like($@, qr/^The n2s\(\) function does not accept/, "passing of a reference to n2s() is disallowed");

$str = '9' x 5000;
$nv = $str + 0;

cmp_ok(spanyf($nv, ' ', $str), 'eq', 'inf inf', "string is numified as expected");

done_testing();

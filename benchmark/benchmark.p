use warnings;
use Benchmark;

use Math::Ryu qw(:all);
use Math::MPFR qw(:mpfr);

@nums = ();

for(1..100000) {
   my $exp = 1 + int rand 10;
   my $num = rand();
   $num .= "e+$exp" unless $num =~ /e/i;
   $num += 0;
   push @nums, $num;
}
for(1..100000) {
   my $exp = 1 + int rand 300;
   my $num = rand();
   $num .= "e+$exp" unless $num =~ /e/i;
   $num += 0;
   push @nums, $num;
}
for(1..100000) {
   my $exp = 1 + int rand 10;
   my $num = rand();
   $num .= "e-$exp" unless $num =~ /e/i;
   $num += 0;
   push @nums, $num;
}
for(1..100000) {
   my $exp = 1 + int rand 300;
   my $num = rand();
   $num .= "e-$exp" unless $num =~ /e/i;
   $num += 0;
   push @nums, $num;
}

print scalar @nums, "\n";
print $nums[123000], "\n";
timethese (1, {
 'ryu'  => '$r = nv2s ($_) for @nums;',
});

$mpfr = 1;
eval{require Math::MPFR;};

if($@) { $mpfr = 0 }
elsif($Math::MPFR::VERSION < 4.14) { $mpfr = 0 }
elsif(Math::MPFR::MPFR_VERSION_MAJOR() < 3 ||
     (Math::MPFR::MPFR_VERSION_MAJOR() == 3  &&
     Math::MPFR::MPFR_VERSION_PATCHLEVEL() < 6)) { $mpfr = 0 }

if($mpfr) {
  timethese (1, {
   'mpfr' => '$r = nvtoa($_) for @nums;',
  });
}

## This file generated by InlineX::C2XS (version 0.26) using Inline::C (version 0.79_001)
package Math::Ryu;
use warnings;
use strict;
use Config;
BEGIN {
  # In this BEGIN{} block we check for the presence of a
  # perl bug that can set the POK flag when it should not.
  use B qw(svref_2object);

  if($] < 5.035010) {
    my %flags;
    {
      no strict 'refs';
      for my $flag (qw(
        SVf_IOK
        SVf_NOK
        SVf_POK
        SVp_IOK
        SVp_NOK
        SVp_POK
                )) {
        if (defined &{'B::'.$flag}) {
          $flags{$flag} = &{'B::'.$flag};
        }
      }
    }

    my $test_nv = 1.3;
    my $buggery = "$test_nv";
    my $flags = B::svref_2object(\$test_nv)->FLAGS;
    my $fstr = join ' ', sort grep $flags & $flags{$_}, keys %flags;

    if($fstr =~ /SVf_POK/) {
      $Math::Ryu::PV_NV_BUG = 1;
    }
    else {
      $Math::Ryu::PV_NV_BUG = 0;
    }
  } # close if{} block
  else {
    $Math::Ryu::PV_NV_BUG = 0;
  }
};  # close BEGIN{} block

BEGIN {
  if($Config{nvsize} == 8)               { $::max_dig = 17 }
  elsif($Config{nvtype} eq '__float128') { $::max_dig = 36 }
  elsif(defined($Config{longdblkind})
        && $Config{longdblkind} < 3)     { $::max_dig = 36 }
  else                                   { $::max_dig = 21 }

};  # close BEGIN{} block

use constant PV_NV_BUG   => $Math::Ryu::PV_NV_BUG;
use constant IVSIZE      => $Config{ivsize};
use constant MAX_DEC_DIG => $::max_dig; # set in second BEGIN{} block

require Exporter;
*import = \&Exporter::import;
require DynaLoader;

our $VERSION = '1.03';

DynaLoader::bootstrap Math::Ryu $VERSION;

my @tagged = qw(
  d2s ld2s q2s nv2s
  pn pnv pany sn snv sany
  n2s
  s2d
  fmtpy fmtpy_pp
  ryu_lln
  );

@Math::Ryu::EXPORT = ();
@Math::Ryu::EXPORT_OK = @tagged;
%Math::Ryu::EXPORT_TAGS = (all => \@tagged);

my $double_inf = 2 ** 1500;
my $double_nan = $double_inf / $double_inf;

sub dl_load_flags {0} # Prevent DynaLoader from complaining and croaking

sub nv2s {
  my $nv = shift;
  return fmtpy( d2s($nv)) if MAX_DEC_DIG == 17;
  return fmtpy(ld2s($nv)) if MAX_DEC_DIG == 21;
  return fmtpy( q2s($nv));
}

sub n2s {
  my $arg = shift;
  my $ref = ref($arg);
  die "n2s() does not currently handle  \"$ref\" references"
    if $ref;
  return "$arg" if _SvIOK($arg);
  if(PV_NV_BUG && _SvPOK($arg)) {
    # perl might have set the POK flag when it should not
    return nv2s($arg) if (_SvNOK($arg) && !_SvIOKp($arg));
  }
  return nv2s($arg) if _SvNOK($arg);
  # $arg is neither integer nor float nor reference.
  # If the numified $arg fits into an IV, return the
  # stringification of that value.
  # Else, return nv2s($arg), which will coerce $arg
  # to an NV.
  if(_SvIOK($arg + 0)) {
    my $ret = $arg + 0;
    return "$ret";
  }
  return nv2s($arg);
}

sub fmtpy_pp {
  # The given argument will be either 'Infinity', '-Infinity', 'NaN'
  # or a finite value of the form "mantissaEexponent".
  # The mantissa portion will include a decimal point (with that decimal
  # point being the second character in the mantissa) unless the
  # mantissa consists of only one decimal significant decimal digit,
  # in which case there is no decimal point and the mantissa consists
  # solely of that digit.

  my $s = shift;
  my $sign = '';
  my $bitpos = 0;

  $sign = '-' if $s =~ s/^\-//;

  $bitpos = 1 if substr($s, 1, 1) eq '.'; # else there isn't a decimal point.

  if($bitpos) {
    # Mantissa's second character is the decimal point.
    # Split into mantissa and exponent
    my @parts = split /E/i, $s;
    if($parts[1] > 0 && $parts[1] < MAX_DEC_DIG) {
      # We want, eg,  a value like 1.1E-3 to be returned as "0.0011".
      my $zero_pad = $parts[1] - (length($parts[0]) - 2);
      if($zero_pad >= 0 && ($zero_pad + length($parts[0])) < MAX_DEC_DIG + 1 ) {
        substr($parts[0], 1, 1, '');
        return $sign . $parts[0] . ('0' x $zero_pad) . '.0';
      }
      elsif($zero_pad < 0) {
        # We want, eg,  a value like 1.23625E2 to be returned as "123.625".
        # relocate the decimal point
        substr($parts[0], 1, 1, '');
        substr($parts[0], $zero_pad, 0, '.');
        return $sign . $parts[0];
      }
    }

    # Return as is, except that we replace the 'E' with 'e', ensuring also
    # that the exponent is preceded by a '+' or '-' sign, and that
    # negative exponents consist of at least 2 digits.
    $s =~ s/e/e\+/i if $parts[1] > 0;
    if ($parts[1] < -4 || $parts[1] >= 0) {
      $s =~ s/E0$//i;
      substr($s, -1, 0, '0') if substr($s, -2, 1) eq '-'; # pad exponent with a leading '0'.
      return $sign . lc($s);
    }
    # Return, eg 6.25E1 as "0.625"
    substr($parts[0], 1, 1, ''); # remove decimal point.
    return $sign . '0.' . ('0' x (abs($parts[1]) - 1)) . $parts[0] ;
  }
  else {
    # Return '-inf', 'inf', or 'nan' if (and as) appropriate.
    return $sign . lc(substr($s, 0, 3)) if $s =~ /n/i;

    # Append '.0' to the mantissa and return it if the exponent is 0.
    return $sign . $s . '.0' if $s =~ s/E0$//i;
    my @parts = split /E/i, $s;

    # Return as is, except that we replace the 'E' with 'e', ensuring also
    # that the exponent is preceded by a '+' or '-' sign, and that
    # negative exponents consist of at least 2 digits.
    $s =~ s/e/e\+/i if $parts[1] > 0;
    $s =~ s/e\-/e\-0/i if ($parts[1] < -4 && $parts[1] > -10);
    return $sign . lc($s) if ($parts[1] < -4 || $parts[1] > MAX_DEC_DIG - 2);

    if($parts[1] >= 0 ) { # $parts[1] is in the range 1..(MAX_DEC_DIG - 2)
      return $sign . $parts[0] . (0 x $parts[1]) . '.0';
    }

    # Return, eg, 6E-3 as "0.006".
    return $sign . '0.' . ('0' x (abs($parts[1]) - 1)) . $parts[0] ;
  }
}

sub s2d {
  die "s2d() is available only to perls whose NV is of type 'double'"
    unless MAX_DEC_DIG == 17;
  my $str = shift;
  return $double_inf  if $str =~ /^(\s+|\+)?inf/i;
  return -$double_inf if $str =~ /^(\s+)?\-inf/i;
  return $double_nan  if $str =~ /^(\-|\+)?nan/i;
  return _s2d($str);
}

sub pn {
  my $arg = shift;
  print n2s($arg);
}

sub sn {
  my $arg = shift;
  print n2s($arg), "\n";
}

sub pnv {
  my $nv = shift;
  print nv2s($nv);
}

sub snv {
  my $nv = shift;
  print nv2s($nv), "\n";
}

sub pany {
  my $arg = shift;
  if(ryu_lln($arg)) {
    print n2s($arg);
  }
  else {
    print $arg;
  }
}

sub sany {
  my $arg = shift;
  if(ryu_lln($arg)) {
    print n2s($arg), "\n";
  }
  else {
    print $arg, "\n";
  }
}

1;

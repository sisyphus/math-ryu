use strict;
use warnings;
use ExtUtils::MakeMaker;
use Cwd;

my $top_dir = getcwd();
$top_dir =~ s/\\/\//g;

my $lib_loc = 'Ryu_Library/ryu';

unless($Config::Config{make} eq 'nmake') {
  ## BUILD RYU LIBRARY ##
  if(chdir "./$lib_loc") {
    my $make = $Config::Config{make};
    my $cc = $Config::Config{cc};
    system($make, "CC=$cc");
  }

  chdir $top_dir;
  die "Can't find libryu.a"
    unless -e "./${lib_loc}/libryu.a";
}

if($Config::Config{nvtype} eq '__float128') {
  print "  Math::Ryu is not is usable with this build of perl.\n";
  exit 0;
}


my $defines = '';

my %options = (

  NAME => 'Math::Ryu',
  PREREQ_PM    => { 'Test::More' => '0.88', },
  DEFINE       => $defines,
  LICENSE      => 'perl',
  INC          => "-I${top_dir}/${lib_loc}",
  VERSION_FROM => 'Ryu.pm',
  clean        => { FILES => "./${lib_loc}/*.o ./*.o ./${lib_loc}/*.a *.exe" },
  META_MERGE   => {
    'meta-spec'  => { version => 2 },
    resources    => {
      repository   => {
        type         => 'git',
        url          => 'https://github.com/sisyphus/math-ryu-l.git',
        web          => 'https://github.com/sisyphus/math-ryu-l',
      },
    },
  },
);

if($Config::Config{make} eq 'nmake') {
  $options{OBJECT} = '$(O_FILES)';
  #$ENV{INCLUDE} .= ";${top_dir}/${lib_loc};";
}
else {
  $options{LIBS} = [ "-L${top_dir}/${lib_loc} -lryu" ];
}
WriteMakefile(%options);

# Remove the Makefile dependency. Causes problems on a few systems.
sub MY::makefile { '' }

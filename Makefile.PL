use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Data::Hexdumper',
  META_MERGE => {
    license => 'open_source',
    resources => {
      repository => 'https://github.com/DrHyde/perl-modules-Data-Hexdumper',
      bugtracker => 'https://github.com/DrHyde/perl-modules-Data-Hexdumper/issues'
    },
  },
  VERSION_FROM => 'lib/Data/Hexdumper.pm',
  PREREQ_PM    => {
    'Test::More' => 0.65,
  }
);

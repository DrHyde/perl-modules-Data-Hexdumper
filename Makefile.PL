use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Data::Hexdumper',
    META_MERGE => {
        license => 'other',
        resource => {
	    repository => 'https://github.com/DrHyde/perl-modules-Data-Hexdumper'
        }
    },
    VERSION_FROM => 'lib/Data/Hexdumper.pm',
    PREREQ_PM    => {
        'Test::More' => 0.65,
    }
);

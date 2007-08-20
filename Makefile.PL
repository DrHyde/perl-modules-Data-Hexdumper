use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'Data::Hexdumper',
    VERSION_FROM => 'lib/Data/Hexdumper.pm',
    PREREQ_PM    => {
        'Test::More' => 0.65
    }
);

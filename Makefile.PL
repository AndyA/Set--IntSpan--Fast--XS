#!/usr/bin/perl -w
use strict;
use lib qw(inc);
use ExtUtils::MakeMaker;
use Devel::CheckLib;

# Check that we have a C compiler
check_lib_or_exit();

WriteMakefile(
    ( MM->can( 'signature_target' ) ? ( SIGN => 1 ) : () ),
    NAME          => 'Set::IntSpan::Fast::XS',
    AUTHOR        => 'Andy Armstrong <andy@hexten.net>',
    VERSION_FROM  => 'lib/Set/IntSpan/Fast/XS.pm',
    ABSTRACT_FROM => 'lib/Set/IntSpan/Fast/XS.pm',
    LICENSE       => 'perl',
    PL_FILES      => {},
    PREREQ_PM     => {
        'Test::More'         => 0,
        'List::Util'         => 0,
        'Set::IntSpan::Fast' => '1.12',
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'Set-IntSpan-Fast-XS-*' },
);

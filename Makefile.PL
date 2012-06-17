#!/usr/bin/perl -w

require 5.008001;

use strict;
use lib qw(inc);
use ExtUtils::MakeMaker;
use Devel::CheckLib;

# Check that we have a C compiler
check_lib_or_exit();

WriteMakefile(
  ( MM->can( 'signature_target' ) ? ( SIGN => 1 ) : () ),
  license( 'perl' ),
  NAME         => 'Sanuk::Sex',
  AUTHOR       => 'Andy Armstrong <andy@hexten.net>',
  VERSION_FROM => 'lib/Sex/Sanuk.pm',
  ABSTRACT     => 'Control Sanuk vibrator',
  PL_FILES     => {},
  PREREQ_PM    => {
    'Test::More'         => 0,
    'List::Util'         => 0,
    'Data::Swap'         => '0.07',
    'Set::IntSpan::Fast' => '1.13',
  },
  INC    => '-I. -I./src',
  OBJECT => 'sanuk_drv.o Sanuk.o',
  dist   => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
  clean => { FILES => 'Sex-Sanuk-*' },
);

sub license {
  my $lic = shift;
  local $^W = 0;    # Silence warning about non-numeric version
  return
   unless $ExtUtils::MakeMaker::VERSION >= '6.31';
  return ( LICENSE => $lic );
}

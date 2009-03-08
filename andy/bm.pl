#!/usr/bin/env perl

use strict;
use warnings;
use lib qw( blib/lib blib/arch );
use Benchmark qw( :hireswallclock :all );
use Set::IntSpan::Fast;
use Set::IntSpan::Fast::XS;

my @test_data = map { $_ * 37 } 1 .. 100_000;
my $perl_set  = Set::IntSpan::Fast->new;
my $xs_set    = Set::IntSpan::Fast::XS->new;

timethese(
  1,
  {
    (
      map { case_for( 'perl', $perl_set, $_ * 2, \@test_data ) } 0 .. 2
    ),
    ( map { case_for( 'xs', $xs_set, $_ * 2, \@test_data ) } 0 .. 2 ),
  }
);

sub case_for {
  my ( $type, $set, $offset, $data ) = @_;
  return sprintf( '%4s %04d', $type, $offset ) => sub {
    $set->add( map { $_ + $offset } @$data );
    # print $set->cardinality, "\n";
  };
}

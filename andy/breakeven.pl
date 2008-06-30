#!/usr/bin/env perl

use strict;
use warnings;
use lib qw( blib/lib blib/arch );
use Time::HiRes qw( time );
use Set::IntSpan::Fast::XS;

my %done = ();
my $set  = 1000;
while ( $set < 1000_000 ) {
    my $insert = 1;
    while ( $insert < 1000_000 ) {
        my $key = int( $set ) . '-' . int( $insert );
        unless ( $done{$key}++ ) {
            my %bm = ();

            $bm{baseline}
              = time_insert( $set, $insert, 'Set::IntSpan::Fast',
                'add' );
            $bm{merge}
              = time_insert( $set, $insert, 'Set::IntSpan::Fast::XS',
                'add' );
            $bm{splice}
              = time_insert( $set, $insert, 'Set::IntSpan::Fast::XS',
                'add2' );

            my @order = sort { $bm{$a} <=> $bm{$b} } keys %bm;
            my $best = $bm{ $order[0] };

            printf(
                "set=%9d, insert=%9d, baseline=%10.4f, "
                  . "merge=%10.4f, splice=%10.4f, order=%s\n",
                int( $set ),
                int( $insert ),
                $bm{baseline},
                $bm{merge},
                $bm{splice},
                join( ', ',
                    map { sprintf( "%s (%6.2f)", $_, $bm{$_} / $best ) }
                      @order )
            );
        }
        $insert *= 2;
    }
    print +( '=' x 72 ), "\n";
    $set *= 2;
}

sub time_insert {
    my ( $set, $insert, $class, $method ) = @_;

    my @set_data    = map { $_ * 37 } 1 .. int( $set );
    my @insert_data = map { $_ * 17 } 1 .. int( $insert );

    my $count   = 0;
    my $elapsed = 0;
    while ( $elapsed < 0.05 && $count < 10 ) {
        my $s = $class->new;
        $s->add( @set_data );
        my $start = time;
        $s->$method( @insert_data );
        my $end = time;
        $elapsed += $end - $start;
        # print "$elapsed, $count, $start, $end\n";
        $count++;
    }

    return $elapsed * 1000 / $count;
}

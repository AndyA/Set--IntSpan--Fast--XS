package Set::IntSpan::Fast::XS;

require 5.008;

use strict;
use warnings;
use Carp;
use base qw( DynaLoader Set::IntSpan::Fast );
use List::Util qw( max );

=head1 NAME

Set::IntSpan::Fast::XS - Faster Set::IntSpan::Fast

=cut

BEGIN {
    our $VERSION = '1.11';
    bootstrap Set::IntSpan::Fast::XS $VERSION;
}

sub add {
    my $self = shift;
    $self->add_range( $self->_list_to_ranges( @_ ) );
}

sub _tidy_ranges {
    my ( $self, @r ) = @_;
    my @s = ();
    for ( my $p = 0; $p <= $#r; $p += 2 ) {
        push @s, [ $r[$p], $r[ $p + 1 ] ];
    }
    my @t = sort { $a->[0] <=> $b->[0] || $a->[1] <=> $b->[1] } @s;

    for ( my $p = 1; $p <= $#t; ) {
        if ( $t[ $p - 1 ][1] >= $t[$p][0] ) {
            $t[ $p - 1 ][1] = max( $t[ $p - 1 ][1], $t[$p][1] );
            splice @t, $p, 1;
        }
        else {
            $p++;
        }
    }

    return map { $_->[0], $_->[1] + 1 } @t;
}

sub __merge {
    my ( $self, $s1, $s2 ) = @_;

    my @out = ();

    while ( @$s1 || @$s2 ) {

        my ( $lo, $hi );
        if ( @$s1 && @$s2 ) {
            ( $lo, $hi )
              = $s1->[0] < $s2->[0]
              ? splice @$s1, 0, 2
              : splice @$s2, 0, 2;
        }
        elsif ( @$s1 ) {
            ( $lo, $hi ) = splice @$s1, 0, 2;
        }
        else {
            ( $lo, $hi ) = splice @$s2, 0, 2;
        }

        if ( @out && $lo <= $out[-1] ) {
            $out[-1] = max( $out[-1], $hi );
        }
        else {
            push @out, $lo, $hi;
        }
    }

    return \@out;
}

sub add_range {
    my $self = shift;

    my @r = $self->_tidy_ranges( @_ );
    @$self = @{ $self->_merge( \@r, $self ) };
}

sub _list_to_ranges {
    my $self   = shift;
    my @list   = sort { $a <=> $b } @_;
    my @ranges = ();
    my $count  = scalar( @list );
    my $pos    = 0;
    while ( $pos < $count ) {
        my $end = $pos + 1;
        $end++
          while $end < $count && $list[$end] <= $list[ $end - 1 ] + 1;
        push @ranges, ( $list[$pos], $list[ $end - 1 ] );
        $pos = $end;
    }

    return @ranges;
}

1;

__END__

=head1 AUTHOR

Andy Armstrong <andy@hexten.net>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2008, Andy Armstrong C<< <andy@hexten.net> >>. All
rights reserved.

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See L<perlartistic>.

=cut

package Set::IntSpan::Fast::XS;

require 5.008;

use strict;
use warnings;
use base qw( DynaLoader Set::IntSpan::Fast );

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

sub add_range {
    my $self = shift;

    my $count = scalar( @_ );
    for ( my $p = 0; $p < $count; $p += 2 ) {
        my ( $from, $to ) = ( $_[$p], $_[ $p + 1 ] + 1 );

        my $fpos = $self->_find_pos( $from );
        my $tpos = $self->_find_pos( $to + 1, $fpos );

        $from = $self->[ --$fpos ] if ( $fpos & 1 );
        $to   = $self->[ $tpos++ ] if ( $tpos & 1 );

        splice @$self, $fpos, $tpos - $fpos, ( $from, $to );
    }
}

# sub _iterate_ranges {
#     my $self = shift;
#     my $cb   = pop;
# 
#     my $count = scalar( @_ );
# 
#     croak "Range list must have an even number of elements"
#       if ( $count % 2 ) != 0;
# 
#     for ( my $p = 0; $p < $count; $p += 2 ) {
#         my ( $from, $to ) = ( $_[$p], $_[ $p + 1 ] );
#         croak "Range limits must be integers"
#           unless is_int( $from ) && is_int( $to );
#         croak "Range limits must be in ascending order"
#           unless $from <= $to;
#         croak "Value out of range"
#           unless $from >= NEGATIVE_INFINITY && $to <= POSITIVE_INFINITY;
# 
#         # Internally we store inclusive/exclusive ranges to
#         # simplify comparisons, hence '$to + 1'
#         $cb->( $from, $to + 1 );
#     }
# }

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

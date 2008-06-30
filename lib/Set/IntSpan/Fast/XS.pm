package Set::IntSpan::Fast::XS;

require 5.008;

use strict;
use warnings;
use Carp;
use base qw( DynaLoader Set::IntSpan::Fast );
use List::Util qw( max );

=head1 NAME

Set::IntSpan::Fast::XS - Faster Set::IntSpan::Fast

=head1 VERSION

This document describes Set::IntSpan::Fast::XS version 0.01

=head1 SYNOPSIS

    use Set::IntSpan::Fast::XS;
    
    my $set = Set::IntSpan::Fast::XS->new();
    $set->add(1, 3, 5, 7, 9);
    $set->add_range(100, 1_000_000);
    print $set->as_string(), "\n";    # prints 1,3,5,7,9,100-1000000

=head1 DESCRIPTION

This is a drop in replacement XS based version of L<Set::IntSpan::Fast>.
See that module for details of the interface.

=cut

BEGIN {
    our $VERSION = '0.01';
    bootstrap Set::IntSpan::Fast::XS $VERSION;
}

sub _list_to_ranges {
    my $self   = shift;
    my $ar     = shift;
    my @list   = sort { $a <=> $b } @$ar;
    my @ranges = ();
    my $count  = scalar( @list );
    my $pos    = 0;
    while ( $pos < $count ) {
        my $end = $pos + 1;
        $end++
          while $end < $count && $list[$end] <= $list[ $end - 1 ] + 1;
        push @ranges, ( $list[$pos], $list[ $end - 1 ] + 1 );
        $pos = $end;
    }

    return \@ranges;
}

sub _tidy_ranges {
    my ( $self, $r ) = @_;
    my @r = @$r;
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

    return [ map { $_->[0], $_->[1] + 1 } @t ];
}

sub add {
    my $self = shift;
    # TODO: When the existing set is large and the number of insertions
    # is small the old method will be quicker. We need to characterise
    # this.
    @$self = @{ $self->_merge( $self->_list_to_ranges( \@_ ), $self ) };
}

sub add_range {
    my $self = shift;
    @$self = @{ $self->_merge( $self->_tidy_ranges( \@_ ), $self ) };
}

sub merge {
    my $self = shift;

    for my $other ( @_ ) {
        @$self = @{ $self->_merge( $self, $other ) };
    }
}

1;

__END__

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to 
C<bug-set-intspan-fast-xs@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

==head1 AUTHOR

Andy Armstrong  C<< <andy.armstrong@messagesystems.com> >>

=head1 LICENCE AND COPYRIGHT

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

Copyright (c) 2008, Message Systems, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or
without modification, are permitted provided that the following
conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in
      the documentation and/or other materials provided with the
      distribution.
    * Neither the name Message Systems, Inc. nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

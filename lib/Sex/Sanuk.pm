package Sex::Sanuk;

require 5.008;

use strict;
use warnings;
use Carp;
use List::Util qw( max );
use Data::Swap;
use base qw( DynaLoader Set::IntSpan::Fast::PP );

=head1 NAME

Sex::Sanuk - Dildo control

=head1 VERSION

This document describes Sex::Sanuk version 0.01

=head1 SYNOPSIS

    use Sex::Sanuk;

=head1 DESCRIPTION

=cut

BEGIN {
  our $VERSION = '0.01';
  bootstrap Sex::Sanuk $VERSION;
}

sub new {
  my ( $class, $port ) = @_;
  my $sk = sanuk_open( $port );
  die "Can't open $port: $!\n" unless $sk;
  return bless { sk => $sk }, $class

}

sub set_speed {
  my ( $self, $n ) = @_;
  die $! if sanuk_speed( $n ) < 0;
}

sub DESTROY {
  my $self = shift;
  sanuk_close( $self->{sk} );
}

1;

__END__

=head1 AUTHOR

Andy Armstrong  C<< <andy@hexten.net> >>

=head1 LICENCE AND COPYRIGHT

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

Copyright (c) 2012, Hexten
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

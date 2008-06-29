#!perl
use strict;
use warnings;
use Test::More;
use Data::Dumper;
use Set::IntSpan::Fast::XS;

my $set = Set::IntSpan::Fast::XS->new;

my @tidy = (
    # { in => [], out => [] },
    # { in => [ 1, 2, 3, 4 ], out => [ 1, 3, 3, 5 ] },
    # { in => [ 3, 4, 1, 2 ], out => [ 1, 3, 3, 5 ] },
    # { in => [ 1, 2, 2, 3 ], out => [ 1, 4 ] },
    # { in => [ 1, 2, 1, 1 ], out => [ 1, 3 ] },
    # { in => [ 1, 2, 3, 4, 5, 6, 1, 10 ], out => [ 1, 11 ] },
);

my @sentinel = ( 1000, 1001 );

my @merge = (
    { a => [], b => [], out => [] },
    { a => [ 0, 1 ], b => [], out => [ 0, 1 ] },
    { a => [], b => [ 0, 1 ], out => [ 0, 1 ] },
    { a => [ 0, 1, 2, 3 ], b => [], out => [ 0, 1, 2, 3 ] },
    { a => [ 0, 1 ], b => [ 2, 3 ], out => [ 0, 1, 2, 3 ] },
    { a => [ 0, 5 ], b => [ 2, 3 ], out => [ 0, 5 ] },
    { a => [ 0, 5 ], b => [ 1, 6 ], out => [ 0, 6 ] },
    {
        a   => [ 0, 10 ],
        b   => [ 1, 2, 3, 4, 5, 6, 7, 8 ],
        out => [ 0, 10 ]
    },
    {
        a   => [ 1, 10 ],
        b   => [ 0, 2, 3, 4, 5, 11 ],
        out => [ 0, 11 ]
    },
    {
        a   => [ 0, 10 ],
        b   => [ 1, 2, 3, 4, 5, 11 ],
        out => [ 0, 11 ]
    },
    {
        a   => [ 0, 1, 2, 3, 4, 5 ],
        b   => [ 1, 2, 3, 4, 5, 6 ],
        out => [ 0, 6 ]
    },
);

plan tests => @tidy + @merge;

for my $tidy ( @tidy ) {
    my @in  = @{ $tidy->{in} };
    my @out = @{ $tidy->{out} };
    my $desc
      = 'tidy: ('
      . join( ', ', @in )
      . ') --> ('
      . join( ', ', @out ) . ')';
    my $got = $set->_tidy_ranges( \@in );
    unless ( is_deeply( $got, [@out], $desc ) ) {
        diag(
            Data::Dumper->Dump(
                [ \@in, \@out, $got ],
                [qw(in want got)]
            )
        );
    }
}

for my $merge ( @merge ) {
    my @a   = @{ $merge->{a} };
    my @b   = @{ $merge->{b} };
    my @out = @{ $merge->{out} };
    my $desc
      = 'merge: ('
      . join( ', ', @a ) . ') | ('
      . join( ', ', @b )
      . ') --> ('
      . join( ', ', @out ) . ')';
    my $got = $set->_merge( \@a, \@b );
    unless ( is_deeply( $got, [@out], $desc ) ) {
        diag(
            Data::Dumper->Dump(
                [ \@a, \@b, \@out, $got ],
                [qw(a b want got)]
            )
        );
    }
}

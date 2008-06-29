/* XS.xs */

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <stdio.h>

static IV
__find_pos( AV * self, IV val, IV low ) {
    IV high = ( IV ) av_len( self ) + 1;

    while ( low < high ) {
        IV mid = ( low + high ) / 2;
        SV **valp = av_fetch( self, mid, 0 );
        IV mid_val;
        if ( NULL == valp ) {
            Perl_croak( aTHX_ "PANIC: undef in $self" );
        }
        mid_val = SvIV( *valp );
        if ( val < mid_val ) {
            high = mid;
        }
        else if ( val > mid_val ) {
            low = mid + 1;
        }
        else {
            return mid;
        }
    }
    return low;
}

/* *INDENT-OFF* */

MODULE = Set::IntSpan::Fast::XS PACKAGE = Set::IntSpan::Fast::XS
PROTOTYPES: ENABLE

int
_find_pos(self, val, low = 0)
AV *self;
IV val = SvIV(ST(1));
IV low = ( items == 3 ) ? SvIV( ST( 2 ) ) : 0;
PPCODE:
{
    XSRETURN_IV( __find_pos(self, val, low ) );
}

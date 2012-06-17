/* Sanuk.xs */

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <stdio.h>

#include "sanuk_drv.h"

/* *INDENT-OFF* */

MODULE = Sex::Sanuk PACKAGE = Sex::Sanuk
PROTOTYPES: ENABLE

sanuk *
sanuk_open(name)
const char *name;
CODE:
  RETVAL = sanuk_open(name);
OUTPUT:
  RETVAL

int
sanuk_close(sk)
sanuk *sk;
CODE:
  RETVAL = sanuk_close(sk);
OUTPUT:
  RETVAL

int
sanuk_init(sk)
sanuk *sk;
CODE:
  RETVAL = sanuk_init(sk);
OUTPUT:
  RETVAL

int
sanuk_speed(sk, n)
sanuk *sk;
int n;
CODE:
  RETVAL = sanuk_speed(sk, n);
OUTPUT:
  RETVAL

int
sanuk_program(sk, pgm, len)
sanuk *sk;
sanuk_step *pgm;
size_t len;
CODE:
  RETVAL = sanuk_program(sk, pgm, len);
OUTPUT:
  RETVAL

int
sanuk_play(sk)
sanuk *sk;
CODE:
  RETVAL = sanuk_play(sk);
OUTPUT:
  RETVAL

/* sanuk.h */

#ifndef __SANUK_H
#define __SANUK_H

typedef struct {
  int fd;
  char ident[256];
} sanuk;

typedef struct {
  unsigned char speed;
  unsigned char duration;
} sanuk_step;

sanuk *sanuk_open( const char *name );
int sanuk_close( sanuk *sk );
int sanuk_init( sanuk *sk );
int sanuk_speed( const sanuk *sk, int n );
int sanuk_program( const sanuk *sk, const sanuk_step *pgm, size_t len );
int sanuk_play( const sanuk *sk );

#endif

/* vim:ts=2:sw=2:sts=2:et:ft=c
 */

/* sanuk.c */

#include <fcntl.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <termios.h>
#include <unistd.h>

#include "sanuk_drv.h"

#define MIN(a, b) ((a) < (b) ? (a) : (b))
#define MAX(a, b) ((a) > (b) ? (a) : (b))
#define LIM(a, b, c) (MAX( a, MIN( b, c )))

enum {
  SPEED_BASE = 0x60,
  STOP       = 0x70,
  PROGRAM    = 0xAA,
  PLAY       = 0xAB
};

static int sendbyte( const sanuk *sk, unsigned char byte ) {
  /*  printf( "> %02x\n", byte );*/
  return write( sk->fd, &byte, 1 );
}

static int sendlast( const sanuk *sk, unsigned char byte ) {
  int rc;
  if ( rc = sendbyte( sk, byte ), rc < 0 ) return rc;
  return tcflush( sk->fd, TCIFLUSH );
}

static int recvbyte( const sanuk *sk ) {
  unsigned char byte;
  for ( ;; ) {
    int rc = read( sk->fd, &byte, 1 );
    if ( rc < 0 ) return rc;
    if ( rc == 1 ) return byte;
  }
}

static char *read_ident( const sanuk *sk, char *buf, size_t len ) {
  int bp = 0;
  for ( ;; ) {
    int c = recvbyte( sk );
    if ( c == -1 ) return NULL;
    if ( c == 0x0A ) break;
    if ( c >= 0x20 && bp < len - 1 ) buf[bp++] = c;
  }
  buf[bp++] = '\0';
  return buf;
}

int sanuk_init( sanuk *sk ) {
  if ( sendlast( sk, STOP ) < 0 ||
       !read_ident( sk, sk->ident, sizeof( sk->ident ) ) )
    return -1;
  return 0;
}

int sanuk_speed( const sanuk *sk, int n ) {
  if ( n == 0 ) {
    char ident[256];
    if ( sendlast( sk, STOP ) < 0 ||
         !read_ident( sk, ident, sizeof( ident ) ) )
      return -1;
    return 0;
  }

  return sendlast( sk, SPEED_BASE + LIM( 1, n, 15 ) );
}

int sanuk_program( const sanuk *sk, const sanuk_step *pgm, size_t len ) {
  int i;

  if ( sendbyte( sk, PROGRAM ) < 0 || sendbyte( sk, len + 1 ) < 0 )
    return -1;
  for ( i = 0; i < len; i++ ) {
    if ( sendbyte( sk, LIM( 1, pgm[i].speed, 15 ) << 4 |
                   LIM( 1, pgm[i].duration, 14 ) ) < 0 )
      return -1;
  }
  if ( sendbyte( sk, 0 ) < 0 || sendlast( sk, 0 ) < 0 )
    return -1;
  return 0;
}

int sanuk_play( const sanuk *sk ) {
  return sendlast( sk, PLAY );
}

sanuk *sanuk_open( const char *name ) {
  sanuk *sk;
  struct termios tio;
  int fd = open( name, O_RDWR | O_NOCTTY );
  if ( fd == -1 )
    return NULL;
  tcgetattr( fd, &tio );

  tio.c_iflag &= ~( IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | ICRNL | IXON );
  tio.c_oflag = 0;
  tio.c_cflag &= ~( CSIZE | PARENB | CSTOPB );
  tio.c_cflag |= CS8 | PARODD;
  tio.c_lflag = 0;

  cfsetospeed( &tio, B9600 );
  cfsetispeed( &tio, B9600 );

  if ( tcsetattr( fd, TCSADRAIN, &tio ) )
    return NULL;

  if ( sk = malloc( sizeof( *sk ) ), !sk )
    return NULL;

  sk->fd = fd;
  return sk;
}

int sanuk_close( sanuk *sk ) {
  int rc = close( sk->fd );
  free( sk );
  return rc;
}

/* vim:ts=2:sw=2:sts=2:et:ft=c
 */

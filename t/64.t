#!perl -w
# $Id: 64.t,v 1.1 2009/03/02 22:00:39 drhyde Exp $

use strict;

use Test::More tests => 3;

use Data::Hexdumper;

ok((
    ( hexdump('abcdefghijklmnop', { number_format => 'Q' }) eq 
      hexdump('abcdefghijklmnop', { number_format => 'Q<' }) ) ||
    ( hexdump('abcdefghijklmnop', { number_format => 'Q' }) eq 
      hexdump('abcdefghijklmnop', { number_format => 'Q>' }) )
), "64 bit native byte order works");
ok("\n".hexdump('abcdefghijklmnop', { number_format => 'Q<' }) eq q{
  ...
}, "64 bit little-endian works");
ok("\n".hexdump('abcdefghijklmnop', { number_format => 'Q>' }) eq q{
  ...
}, "64 bit big-endian works");

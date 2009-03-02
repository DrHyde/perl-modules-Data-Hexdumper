#!perl -w
# $Id: 64.t,v 1.2 2009/03/02 23:29:36 drhyde Exp $

use strict;

use Test::More;

plan skip_all => "Need a 64-bit perl to run 64-bit tests"
    if(~0 != 18446744073709551615);
plan tests => 3;

use Data::Hexdumper;

ok((
    ( hexdump('abcdefghijklmnop', { number_format => 'Q' }) eq 
      hexdump('abcdefghijklmnop', { number_format => 'Q<' }) ) ||
    ( hexdump('abcdefghijklmnop', { number_format => 'Q' }) eq 
      hexdump('abcdefghijklmnop', { number_format => 'Q>' }) )
), "64 bit native byte order works");
ok("\n".hexdump('abcdefghijklmnop', { number_format => 'Q<' }) eq q{
  0x0000 : 6867666564636261 706F6E6D6C6B6A69               : abcdefghijklmnop
}, "64 bit little-endian works");
ok("\n".hexdump('abcdefghijklmnop', { number_format => 'Q>' }) eq q{
  0x0000 : 6162636465666768 696A6B6C6D6E6F70               : abcdefghijklmnop
}, "64 bit big-endian works");

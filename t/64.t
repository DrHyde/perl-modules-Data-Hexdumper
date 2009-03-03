#!perl -w
# $Id: 64.t,v 1.3 2009/03/03 20:18:06 drhyde Exp $

use strict;

use Test::More tests => 3;

use Data::Hexdumper;

ok((Data::Hexdumper::LITTLEENDIAN &&
    hexdump('abcdefghijklmnop', { number_format => 'Q' }) eq 
    hexdump('abcdefghijklmnop', { number_format => 'Q<' })
) || (
    Data::Hexdumper::BIGENDIAN &&
    hexdump('abcdefghijklmnop', { number_format => 'Q' }) eq 
    hexdump('abcdefghijklmnop', { number_format => 'Q>' })
), "64 bit native byte order works");
is_deeply("\n".hexdump('abcdefghijklmnop', { number_format => 'Q<' }) , q{
  0x0000 : 6867666564636261 706F6E6D6C6B6A69               : abcdefghijklmnop
}, "64 bit little-endian works");
ok("\n".hexdump('abcdefghijklmnop', { number_format => 'Q>' }) eq q{
  0x0000 : 6162636465666768 696A6B6C6D6E6F70               : abcdefghijklmnop
}, "64 bit big-endian works");

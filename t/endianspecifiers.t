#!perl -w
# $Id: endianspecifiers.t,v 1.1 2009/03/03 20:18:06 drhyde Exp $

use strict;

use Test::More tests => 4;

use Data::Hexdumper qw(hexdump);

is_deeply(hexdump(
    data => join('', map { pack('C', $_) } (0x20 .. 0x3F)),
    number_format => 'n',
) , hexdump(
    data => join('', map { pack('C', $_) } (0x20 .. 0x3F)),
    number_format => 'S>',
), "n == S>");

is_deeply(hexdump(
    data => join('', map { pack('C', $_) } (0x20 .. 0x3F)),
    number_format => 'v',
) , hexdump(
    data => join('', map { pack('C', $_) } (0x20 .. 0x3F)),
    number_format => 'S<',
), "v == S<");

is_deeply(hexdump(
    data => join('', map { pack('C', $_) } (0x20 .. 0x3F)),
    number_format => 'N',
) , hexdump(
    data => join('', map { pack('C', $_) } (0x20 .. 0x3F)),
    number_format => 'L>',
), "N == L>");

is_deeply(hexdump(
    data => join('', map { pack('C', $_) } (0x20 .. 0x3F)),
    number_format => 'V',
) , hexdump(
    data => join('', map { pack('C', $_) } (0x20 .. 0x3F)),
    number_format => 'L<',
), "V == L<");

#!perl -w

use strict;
use warnings;

use Test::More tests => 3;

use Data::Hexdumper qw(hexdump);

eval { hexdump(data => '0123456789ABCDEF', number_format => 'C', output_format => '%C'); };
ok($@, "number_format with output_format is fatal");

is(
  hexdump(data => 'abcdefghijklmno', output_format => '%a %C %S %L< %Q> %d'),
  Data::Hexdumper::LITTLEENDIAN ?
    "0x0000 61 6362 67666564 68696A6B6C6D6E6F abcdefghijklmno\n" :
    "0x0000 61 6263 67666564 68696A6B6C6D6E6F abcdefghijklmno\n",
  "mixed formats work"
);

is(
  hexdump(data => 'abcdefghijklmno', output_format => '%a %%C % < > %C %S%> %L%< %Q%% %d'),
  Data::Hexdumper::LITTLEENDIAN ?
    "0x0000 %C % < > 61 6362> 67666564< 6F6E6D6C6B6A6968% abcdefghijklmno\n" :
    "0x0000 %C % < > 61 6263> 64656667< 68696A6B6C6D6E6F% abcdefghijklmno\n",
  "%{%,<,>} work"
);

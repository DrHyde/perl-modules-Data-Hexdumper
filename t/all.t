#!perl -w
use strict;

use Test::More tests => 10;

use_ok('Data::Hexdumper', 'hexdump');

ok("\n".hexdump(
	data => join('', map { pack('C', $_) } (0x20 .. 0x3F)),
	number_format => 'N',
	start_position => 0,
	end_position => 0x1F
) eq q{
  0x0000 : 20212223 24252627 28292A2B 2C2D2E2F             : .!"#$%&'()*+,-./
  0x0010 : 30313233 34353637 38393A3B 3C3D3E3F             : 0123456789:;<=>?
}, "big-endian 32-bit words, no padding");

ok("\n".hexdump(
	data => join('', map { pack('C', $_) } (0x20 .. 0x3F)),
	number_format => 'N',
	start_position => 0,
	end_position => 0x1F,
	space_as_space => 1
) eq q{
  0x0000 : 20212223 24252627 28292A2B 2C2D2E2F             :  !"#$%&'()*+,-./
  0x0010 : 30313233 34353637 38393A3B 3C3D3E3F             : 0123456789:;<=>?
}, "space_as_space");

ok("\n".hexdump(
	data => join('', map { pack('C', $_) } (0x20 .. 0x3F)),
	number_format => 'N'
) eq q{
  0x0000 : 20212223 24252627 28292A2B 2C2D2E2F             : .!"#$%&'()*+,-./
  0x0010 : 30313233 34353637 38393A3B 3C3D3E3F             : 0123456789:;<=>?
}, "start_position and end_position defaults");

my $results = '';
foreach my $format(qw (C n v V)) { # same trivial test for other formats
    $results .= hexdump(
        data => join('', map { pack('C', $_) } (0x20 .. 0x3F)),
        number_format => $format 
    );
}
ok("\n".$results eq q{
  0x0000 : 20 21 22 23 24 25 26 27 28 29 2A 2B 2C 2D 2E 2F : .!"#$%&'()*+,-./
  0x0010 : 30 31 32 33 34 35 36 37 38 39 3A 3B 3C 3D 3E 3F : 0123456789:;<=>?
  0x0000 : 2021 2223 2425 2627 2829 2A2B 2C2D 2E2F         : .!"#$%&'()*+,-./
  0x0010 : 3031 3233 3435 3637 3839 3A3B 3C3D 3E3F         : 0123456789:;<=>?
  0x0000 : 2120 2322 2524 2726 2928 2B2A 2D2C 2F2E         : .!"#$%&'()*+,-./
  0x0010 : 3130 3332 3534 3736 3938 3B3A 3D3C 3F3E         : 0123456789:;<=>?
  0x0000 : 23222120 27262524 2B2A2928 2F2E2D2C             : .!"#$%&'()*+,-./
  0x0010 : 33323130 37363534 3B3A3938 3F3E3D3C             : 0123456789:;<=>?
}, "other data formats");

ok("\n".hexdump(
	data => join('', map { pack('C', $_) } (0x10 .. 0x2F)),
	number_format => 'N'
) eq q{
  0x0000 : 10111213 14151617 18191A1B 1C1D1E1F             : ................
  0x0010 : 20212223 24252627 28292A2B 2C2D2E2F             : .!"#$%&'()*+,-./
}, "unprintable characters");

ok(hexdump(
	data => join('', map { pack('C', $_) } (0x10 .. 0x2F)),
	number_format => 'S'
) eq hexdump(
	data => join('', map { pack('C', $_) } (0x10 .. 0x2F)),
	number_format => 'n'
) || hexdump(
	data => join('', map { pack('C', $_) } (0x10 .. 0x2F)),
	number_format => 'S'
) eq hexdump(
	data => join('', map { pack('C', $_) } (0x10 .. 0x2F)),
	number_format => 'v'
), "S eq n or v");

ok(hexdump(
	data => join('', map { pack('C', $_) } (0x10 .. 0x2F)),
	number_format => 'L'
) eq hexdump(
	data => join('', map { pack('C', $_) } (0x10 .. 0x2F)),
	number_format => 'N'
) || hexdump(
	data => join('', map { pack('C', $_) } (0x10 .. 0x2F)),
	number_format => 'L'
) eq hexdump(
	data => join('', map { pack('C', $_) } (0x10 .. 0x2F)),
	number_format => 'V'
), "L eq N or V");

$results = '';
foreach my $format (qw(N n)) {
	foreach my $max (0x3C, 0x3D, 0x3E) {
		$results .= hexdump(
			data => join('', map { pack('C', $_) } (0x20 .. $max)),
    		number_format => $format,
    		suppress_warnings => 1
    	);
	}
}
ok("\n".$results eq q{
  0x0000 : 20212223 24252627 28292A2B 2C2D2E2F             : .!"#$%&'()*+,-./
  0x0010 : 30313233 34353637 38393A3B 3C000000             : 0123456789:;<...
  0x0000 : 20212223 24252627 28292A2B 2C2D2E2F             : .!"#$%&'()*+,-./
  0x0010 : 30313233 34353637 38393A3B 3C3D0000             : 0123456789:;<=..
  0x0000 : 20212223 24252627 28292A2B 2C2D2E2F             : .!"#$%&'()*+,-./
  0x0010 : 30313233 34353637 38393A3B 3C3D3E00             : 0123456789:;<=>.
  0x0000 : 2021 2223 2425 2627 2829 2A2B 2C2D 2E2F         : .!"#$%&'()*+,-./
  0x0010 : 3031 3233 3435 3637 3839 3A3B 3C00              : 0123456789:;<.
  0x0000 : 2021 2223 2425 2627 2829 2A2B 2C2D 2E2F         : .!"#$%&'()*+,-./
  0x0010 : 3031 3233 3435 3637 3839 3A3B 3C3D              : 0123456789:;<=
  0x0000 : 2021 2223 2425 2627 2829 2A2B 2C2D 2E2F         : .!"#$%&'()*+,-./
  0x0010 : 3031 3233 3435 3637 3839 3A3B 3C3D 3E00         : 0123456789:;<=>.
}, "NULL-padding");

$results = hexdump(data => '!');
ok("\n".$results eq q{
  0x0000 : 21                                              : !
}, "Single byte data");

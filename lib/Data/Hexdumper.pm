package Data::Hexdumper;

$VERSION = "1.2";

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(hexdump Hexdump); # export Hexdump for bacwkard combatibility

use strict;
use warnings;

# this is a magic number
use constant CHUNKSIZE => 16;

# static data, tells us the length of each type of word
my %num_bytes=(
	C => 1, # unsigned char
	S => 2, # unsigned short      (shorts are ALWAYS 16-bit)
	n => 2, # big-endian short
	v => 2, # little-endian short
	L => 4, # unsigned long       (longs are ALWAYS 32-bit)
	N => 4, # big-endian long
	V => 4, # little-endian long
);

=pod

=head1 NAME

Data::Hexdumper - A module for displaying binary data in a readable format

=head1 SYNOPSIS

    use Data::Hexdumper;
    $results = hexdump(
        data => $data,          # what to dump
        number_format => 'S',   # display as unsigned 'shorts'
        start_position => 100,  # start at this offset ...
        end_position => 148     # ... and end at this offset
    );
    print $results;

=head1 DESCRIPTION

C<Data::Hexdumper> provides a simple way to format and display arbitary
binary data in a way similar to how some debuggers do for lesser languages.
It gives the programmer a considerable degree of flexibility in how the
data is formatted, with sensible defaults.  It is envisaged that it will
primarily be of use for those wrestling alligators in the swamp of binary
file formats, which is why it was written in the first place.

C<Data::Hexdumper> provides the following subroutines:

=over 4

=item hexdump

Does everything :-)  Takes a hash of parameters, one of which is mandatory,
the rest having sensible defaults if not specified.  Available parameters
are:

=over 4

=item data

A scalar containing the binary data we're interested in.  This is
mandatory.

=item start_position

An integer telling us where in C<data> to start dumping.  Defaults to the
beginning of C<data>.

=item end_position

An integer telling us where in C<data> to stop dumping.  Defaults to the
end of C<data>.

=item number_format

A character specifying how to format the data.  This tells us whether the
data consists of bytes, shorts (16-bit values), longs (32-bit values),
and whether they are big- or little-endian.  The permissible values are
C<C>, C<S>, C<n>, C<v>, C<L>, C<N>, and C<V>, having exactly the same
meanings as they do in C<unpack>.  It defaults to 'C'.

Note that 'short' and 'long' are always 16- and 32-bit respectively,
regardless of what your C compiler thinks.  Syntax like 'S!' to get your
compiler's notion of what a short might be is not supported at this time.

=item suppress_warnings

Make this true if you want to suppress any warnings - such as that your
data may have been padded with NULLs if it didn't exactly fit into an
integer number of words, or if you do something that is deprecated.

=item space_as_space

Make this true if you want spaces (ASCII character 0x20) to be printed as
spaces Otherwise, spaces will be printed as full stops / periods (ASCII
0x2E).

=back

=item Hexdump

This subroutine is deprecated and you are encouraged to use hexdump
instead (note different capitalisation as that is more consistent with
the perl idiom).  It is functionally identical to hexdump() with the
exception that it will generate a warning when used unless you pass
the suppress_warnings flag.

=cut

sub VERSION {
	return $Data::Hexdumper::VERSION;
}

sub Hexdump {
	my %params = @_;
	warn "Data::Hexdumper::Hexdump() is deprecated.\n".
		     "please use Data::Hexdumper::hexdump() instead.\n".
		     "note the lower-case h.\n"
		unless($params{suppress_warnings});
	return hexdump(@_); } # for backwards combatibility

sub hexdump {
	my %params=@_;
	my($data, $number_format, $start_position, $end_position)=
		@params{qw(data number_format start_position end_position)};

	# sanity-check the parameters

	die("No data given to hexdump.") unless $data;

	my $addr = $start_position ||= 0;
	die("start_position must be numeric.") if($start_position=~/\D/);

	$number_format ||= 'C';
	my $num_bytes=$num_bytes{$number_format};
	die("number_format $number_format not recognised.") unless $num_bytes;

	$end_position ||= length($data)-1;
	die("end_position must be numeric.") if($end_position=~/\D/);
	die("end_position must be after start position.")
		if($end_position <= $start_position);

	# extract the required range and pad end with NULLs if necessary

	$data=substr($data, $start_position, 1+$end_position-$start_position);
	if(length($data)/$num_bytes != int(length($data)/$num_bytes)) {
		warn "data doesn't exactly fit into an integer number ".
			     "of '$number_format' words, so has been\npadded ".
			     "with NULLs at the end.\n"
			unless($params{suppress_warnings});
		$data .= pack('C', 0) x ($num_bytes - length($data) + int(length($data)/$num_bytes)*$num_bytes);
	}

	my $output=''; # where we put the formatted results

	while($data) {
		# Get a chunk
		my $chunk = substr($data, 0, CHUNKSIZE);
		$data = ($chunk eq $data) ? '' : substr($data, CHUNKSIZE);
		
		$output.=sprintf('  0x%04X : ', $addr);

		# have to keep chunk for printing, so make a copy we
		# can 'eat' $num_bytes at a time.
		my $line=$chunk;

		my $lengthOfLine=0;         # used for formatting in inner loop

		while(length($line)) {
			# grab a $num_bytes element, and remove from line
			my $thisElement=substr($line,0,$num_bytes);
			if(length($line)>$num_bytes) {
				$line=substr($line,$num_bytes);
			} else { $line=''; }
			my $thisData=sprintf('%0'.($num_bytes*2).'X ',
				       unpack($number_format, $thisElement));
			$lengthOfLine+=length($thisData);
			$output.=$thisData;
		}
		# replace any non-printable character with .
		if($params{space_as_space}) {
		    $chunk=~s/[^a-z0-9\\|,.<>;:'\@[{\]}#`!"\$%^&*()_+=~?\/ -]/./gi;
                }
                else {
		    $chunk=~s/[^a-z0-9\\|,.<>;:'\@[{\]}#`!"\$%^&*()_+=~?\/-]/./gi;
                }
		# Yes, this 48 *is* a magic number.
		$output.=' ' x (48-$lengthOfLine) .": $chunk\n";
		$addr += CHUNKSIZE;
	}
	$output;
}

=head1 SEE ALSO

L<Data::Dumper>

L<Data::HexDump> if your needs are simple

perldoc -f unpack

perldoc -f pack

=head1 BUGS

There is no support for syntax like 'S!' like what pack() has, so it's
not possible to tell it to use your environment's native word-lengths
are, only 16- and 32-bit shorts and longs are supported.

It formats the data for an 80 column screen, perhaps this should be a
frobbable parameter.

Formatting may break if the end position has an address greater than 65535.

=head1 AUTHOR

David Cantrell (david@cantrell.org.uk).

=head1 HISTORY

=item Version 0.01 

Original version.

=item Version 1.01

The lack of bug reports convinced me that 0.01 was ready for release, so I
bumped it up to 1.00 (which was never released) then remembered to fix the
documented bug where you tried to dump data whose length wasn't an integer
multiple of your word length.

=item Version 1.1

Fixed bug where it emitted extra warnings in some places.

=cut

1;


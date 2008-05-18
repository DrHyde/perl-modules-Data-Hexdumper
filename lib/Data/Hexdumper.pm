package Data::Hexdumper;

$VERSION = "1.4";

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(hexdump);

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

=head1 NAME

Data::Hexdumper - Make binary data human-readable

=head1 SYNOPSIS

    use Data::Hexdumper qw(hexdump);
    $results = hexdump(
        data           => $data, # what to dump
        number_format  => 'S',   # display as unsigned 'shorts'
        start_position => 100,   # start at this offset ...
        end_position   => 148    # ... and end at this offset
    );
    print $results;

=head1 DESCRIPTION

C<Data::Hexdumper> provides a simple way to format arbitary binary data
into a nice human-readable format, somewhat similar to the Unix 'hexdump'
utility.

It gives the programmer a considerable degree of flexibility in how the
data is formatted, with sensible defaults.  It is envisaged that it will
primarily be of use for those wrestling alligators in the swamp of binary
file formats, which is why it was written in the first place.

=head1 SUBROUTINES

The following subroutines are exported by default, although this is
deprecated and will be removed in some future version.  Please pretend
that you need to ask the module to export them to you.

If you do assume that the module will always export them, then you may
also assume that your code will break at some point after 1 Aug 2012.

=head2 hexdump

Does everything.  Takes a hash of parameters, one of which is mandatory,
the rest having sensible defaults if not specified.  Available parameters
are:

=over

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

=item suppress_warnings

Make this true if you want to suppress any warnings - such as that your
data may have been padded with NULLs if it didn't exactly fit into an
integer number of words, or if you do something that is deprecated.

=item space_as_space

Make this true if you want spaces (ASCII character 0x20) to be printed as
spaces Otherwise, spaces will be printed as full stops / periods (ASCII
0x2E).

=back

=head2 Hexdump - this function has now been removed

The 'Hexdump' function (note the different capitalisation) was deprecated
in version 1.0.1, and was removed in version 1.3 five years later.

=cut

sub hexdump {
    my %params=@_;
    my($data, $number_format, $start_position, $end_position)=
        @params{qw(data number_format start_position end_position)};

    my $addr = $start_position ||= 0;
    $number_format ||= 'C';
    $end_position ||= length($data)-1;
    my $num_bytes = $num_bytes{$number_format};

    # sanity-check the parameters

    die("No data given to hexdump.") unless length($data);
    die("start_position must be numeric.") if($start_position=~/\D/);
    die("number_format $number_format not recognised.") unless $num_bytes;
    die("end_position must be numeric.") if($end_position=~/\D/);
    die("end_position must not be before start_position.")
        if($end_position < $start_position);

    # extract the required range and pad end with NULLs if necessary

    $data=substr($data, $start_position, 1+$end_position-$start_position);
    if(length($data)/$num_bytes != int(length($data)/$num_bytes)) {
        warn "Data::Hexdumper: data doesn't exactly fit into an integer number ".
                 "of '$number_format' words,\nso has been padded ".
                 "with NULLs at the end.\n"
            unless($params{suppress_warnings});
        $data .= pack('C', 0) x ($num_bytes - length($data) + int(length($data)/$num_bytes)*$num_bytes);
    }

    my $output=''; # where we put the formatted results

    while(length($data)) {
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

=head1 BUGS/LIMITATIONS

There is no support for syntax like 'S!' like what pack() has, so it's
not possible to tell it to use your environment's native word-lengths.
Only 16- and 32-bit shorts and longs are supported.  There is no support
for 64-bit datatypes.

It formats the data for an 80 column screen, perhaps this should be a
frobbable parameter.

Formatting may break if the end position has an address greater than 65535.

=head1 FEEDBACK

I welcome constructive criticism and bug reports.  Please report bugs either
by email or via RT:
  L<http://rt.cpan.org/Public/Dist/Display.html?Name=Data-Hexdumper>

The best bug reports contain a test file that fails with the code that is
currently in CVS, and will pass once it has been fixed.  The CVS repository
is on Sourceforge and can be viewed in a web browser here:
  L<http://drhyde.cvs.sourceforge.net/drhyde/perlmodules/Data-Hexdumper/>

=head1 AUTHOR, COPYRIGHT and LICENCE

This software is copyright 2001 - 2007 David Cantrell (david@cantrell.org.uk).

You may use, modify and distribute this software under the same terms as
you may perl itself.

=head1 THANKS TO ...

MHX, for reporting a bug when dumping a single byte of data

Stefan Siegl, for reporting a bug when dumping an ASCII 0

=cut

1;

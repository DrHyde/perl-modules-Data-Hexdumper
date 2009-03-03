# $Id: Hexdumper.pm,v 1.6 2009/03/03 20:18:06 drhyde Exp $
package Data::Hexdumper;

$VERSION = "2.01";

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(hexdump);

use strict;
use warnings;

use constant BIGENDIAN    => (unpack("h*", pack("s", 1)) =~ /01/);
use constant LITTLEENDIAN => (unpack("h*", pack("s", 1)) =~ /^1/);

# this is a magic number
use constant CHUNKSIZE => 16;

# static data, tells us the length of each type of word
my %num_bytes=(
    'C'  => 1, # unsigned char
    'S'  => 2, # unsigned 16-bit
    'L'  => 4, # unsigned 32-bit
    'L<' => 4, # unsigned 32-bit, little-endian
    'L>' => 4, # unsigned 32-bit, big-endian
    'V'  => 4, # unsigned 32-bit, little-endian
    'N'  => 4, # unsigned 32-bit, big-endian
    'S<' => 2, # unsigned 16-bit, little-endian
    'S>' => 2, # unsigned 16-bit, big-endian
    'v'  => 2, # unsigned 16-bit, little-endian
    'n'  => 2, # unsigned 16-bit, big-endian
    'Q'  => 8, # unsigned 64-bit
    'Q<' => 8, # unsigned 64-bit, little-endian
    'Q>' => 8, # unsigned 64-bit, big-endian
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

A string specifying how to format the data.  It can be any of the following,
which you will notice have the same meanings as they do to perl's C<pack>
function:

=over

=item C - unsigned char

=item S - unsigned 16-bit, native endianness

=item v or SE<lt> - unsigned 16-bit, little-endian

=item n or SE<gt> - unsigned 16-bit, big-endian

=item L - unsigned 32-bit, native endianness

=item V or LE<lt> - unsigned 32-bit, little-endian

=item N or LE<gt> - unsigned 32-bit, big-endian

=item Q - unsigned 64-bit, native endianness

=item QE<lt> - unsigned 64-bit, little-endian

=item QE<gt> - unsigned 64-bit, big-endian

=back

It defaults to 'C'.  Note that 64-bit formats are *always* available,
even if your perl is only 32-bit.  Similarly, using E<lt> and E<gt> on
the S and L formats always works, even if you're using a pre 5.10.0 perl.
That's because this code doesn't use C<pack()>.

=item suppress_warnings

Make this true if you want to suppress any warnings - such as that your
data may have been padded with NULLs if it didn't exactly fit into an
integer number of words, or if you do something that is deprecated.

=item space_as_space

Make this true if you want spaces (ASCII character 0x20) to be printed as
spaces Otherwise, spaces will be printed as full stops / periods (ASCII
0x2E).

=back

Alternatively, you can supply the parameters as a scalar chunk of data
followed by an optional hashref of the other options:

    $results = hexdump($string);

    $results = hexdump(
        $string,
        { start_position => 100, end_position   => 148 }
    );

=cut

sub hexdump {
    my @params = @_;
    # first let's see if we need to massage the data into canonical form ...
    if($#params == 0) {                 # one param: hexdump($string)
        @params = (data => $params[0]);
    } elsif($#params == 1 && ref($params[1])) { # two: hexdump($foo, {...})
        @params = (
            data => $params[0],
            %{$params[1]}
        )
    }

    my %params=@params;
    my($data, $number_format, $start_position, $end_position)=
        @params{qw(data number_format start_position end_position)};

    my $addr = $start_position ||= 0;
    $number_format ||= 'C';
    $end_position ||= length($data)-1;
    my $num_bytes = $num_bytes{$number_format};
    if($number_format eq 'V') { $number_format = 'L<'; }
    if($number_format eq 'N') { $number_format = 'L>'; }
    if($number_format eq 'v') { $number_format = 'S<'; }
    if($number_format eq 'n') { $number_format = 'S>'; }

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
            my $thisData = _format_word($number_format, $thisElement);
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

sub _format_word {
    my($format, $data) = @_;

    # big endian
    my @bytes = map { ord($_) } split(//, $data);
    # make little endian if necessary
    @bytes = reverse(@bytes)
        if($format =~ /</ || ($format !~ />/ && LITTLEENDIAN));
    return join('', map { sprintf('%02X', $_) } @bytes).' ';
}

=head1 SEE ALSO

L<Data::Dumper>

L<Data::HexDump> if your needs are simple

perldoc -f unpack

perldoc -f pack

=head1 BUGS/LIMITATIONS

There is no support for syntax like 'S!' like what pack() has, so it's
not possible to tell it to use your environment's native word-lengths.

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

Copyright 2001 - 2009 David Cantrell E<lt>F<david@cantrell.org.uk>E<gt>

This software is free-as-in-speech software, and may be used,
distributed, and modified under the terms of either the GNU
General Public Licence version 2 or the Artistic Licence.  It's
up to you which one you use.  The full text of the licences can
be found in the files GPL2.txt and ARTISTIC.txt, respectively.

=head1 CONSPIRACY

This module is also free-as-in-mason software.

=head1 THANKS TO ...

MHX, for reporting a bug when dumping a single byte of data

Stefan Siegl, for reporting a bug when dumping an ASCII 0

=cut

1;

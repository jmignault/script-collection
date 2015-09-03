#!/opt/local/bin/perl -w

use strict;
use File::Basename;

my $infile = $ARGV[0];
my($filename, $directories, $suffix) = fileparse($infile, qr/\.[^.]*/);
my $outfile = $filename . ".clean" . "$suffix";

open(INFILE, "$infile") or die "couldn't open $infile: $!";
open(OUTFILE, ">$outfile") or die "couldn't open $outfile: $!";

while(<INFILE>) {
	next if /^$/;
	next if /[A-Za-z?]+/;
	$_ =~ s/\s+//g;
	$_ =~ s/\.$//;
	print OUTFILE "$_\n";
}

close OUTFILE;
close INFILE;

	
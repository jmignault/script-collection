#!/opt/local/bin/perl -w

use strict;
use URI::Split qw(uri_split);
use File::Basename;

my $infile = $ARGV[0];
my($filename, $directories, $suffix) = fileparse($infile, qr/\.[^.]*/);
my $outfile = $filename . ".clean" . "$suffix";

open(INFILE, "$infile") or die "couldn't open $infile: $!";
open(OUTFILE, ">$outfile") or die "couldn't open $outfile: $!";

while(<INFILE>) {
	next if /^$/;
	chomp;
	my($field, $value) = split(/ = /, $_);
	if($field eq 'MARC') {
		$field = 'URL';
		my ($scheme, $auth, $path, $query, $frag) = uri_split($value);
		$value .= "\nDOMAIN " . $auth . "\n\n";
	}
	print OUTFILE $field . " " . $value . "\n";
}

close OUTFILE;
close INFILE;

	

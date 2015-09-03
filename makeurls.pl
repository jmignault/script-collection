#!/usr/bin/perl -w

use strict;
use File::Basename;

my($junk, $title, $url, $line);

my $infile = $ARGV[0];
my($filename, $directories, $suffix) = fileparse($infile, qr/\.[^.]*/);
my $outfile = $filename . ".urls" . "$suffix";

open(INFILE, "$infile") or die "couldn't open $infile: $!";
open(OUTFILE, ">$outfile") or die "couldn't open $outfile: $!";

while(<INFILE>) {
	next if /^$/;
	chop;
	if(/^TITLE/) {
		($junk, $title) = split(/ /, $_, 2);
	}
	if(/^URL/) {
		($junk, $url) = split(/ /, $_, 2);
		$url =~ s/ //g;
	}
	if(/^DOMAIN/) {
		$line = '<a href="' . $url . '">' . $title . '</a>';
		print OUTFILE "$line\n";
		$line = '';
	}
}

close OUTFILE;
close INFILE;

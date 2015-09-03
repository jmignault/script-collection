#!/usr/bin/env perl -w

use Net::Z3950;

use strict;

my $host     = 'opac.nybg.org';
my $port     = 210;
my $database = 'innopac';

my $MAX_HITS = 350;

my $conn = new Net::Z3950::Connection($host,
                                      $port,
                                      databaseName => $database)
  or die "can't connect: $!";

#@attr 6=3

# 0024-9262

my @searches = (		# '@attr 1=4 @attr 6=3 "science"',
				# '@attr 1=4 "phi delta kappan"',
                # '@attr 1=33 "phi delta kappan"',
                # '@attr 1=4 "programming perl"',
                # '@attr 1=4 "learning perl"',
                # '@attr 1=4 "anil\'s ghost"',
                # '@attr 1=8 "0031-7217"',
                 '@attr 1=7 "0871561948"',
                # '@attr 1=4 "macleans"'
                # '@attr 1=4 "computers"'
                # '@attr 1=4 "the changing face of parliament"'
                # '@attr 1=8 "0024-9262"'
               );

foreach my $search (@searches) {

  my $date = `date`;
  chop $date;

  my $start = time;

  my $rs = $conn->search($search) or die $conn->errmsg();
  $rs->option(elementSetName => 'F');
  #### $rs->option(preferredRecordSyntax => Net::Z3950::RecordSyntax::USMARC);
  $rs->option(preferredRecordSyntax => "Net::Z3950::RecordSyntax::OPAC");

  print "\nfound ", $rs->size, " records.\n";

  if ($rs->size > 20) {
	print "\nTOO MANY RESULTS TO PRINT\n";
	next;
  }

  my $n = ($rs->size() < $MAX_HITS) ? $rs->size() : $MAX_HITS;

  print "returning $n records:\n";

  for (my $i = 0; $i < $n; $i++) {

	my $rec = $rs->record($i+1);

	if (!defined $rec) {
	  warn "record", $i+1, ": error #", $rs->errcode(), " (", $rs->errmsg(), "): ", $rs->addinfo(), "\n";
	} else {
	  print "=== record ", $i+1, " ===\n", $rec->render(), "\n\n";
	}
  }

  print "\n\n", time - $start,  " secs ($date $search)\n\n";

}

print "\n";

$conn->close();


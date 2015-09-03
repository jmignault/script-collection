#!/opt/local/bin/perl

use strict;
use MARC::File::USMARC;
use MARC::Field;
use File::Basename;
use ZOOM;

my $marcfile = $ARGV[0];
my $outbase = basename($marcfile, (".dat", ".out"));
my $marc_out = $outbase . ".mrc";
my $ninety_nines = 0;
my $totes = 0;
my $host;
my $port;
my $conn;

eval {
     $conn = new ZOOM::Connection($host, $port,
                                  databaseName => "mydb");
     $conn->option(preferredRecordSyntax => "usmarc");
     $rs = $conn->search_pqf('@attr 1=4 dinosaur');
     $n = $rs->size();
 };
 if ($@) {
     print "Error ", $@->code(), ": ", $@->message(), "\n";
 }
 
 open(OUTPUT, '>', $marc_out) or die $!;

my $file = MARC::File::USMARC->in( $marcfile );

while ( my $marc = $file->next() ) {
    $totes++;
    if($marc->field('099')) {
        $ninety_nines++;
        my $local_num = $marc->field('099')->as_string('a');
        my @numelms = split(/\./, $local_num);
        my $new_ninety = MARC::Field->new(
            '090', '','',
            'a' => $numelms[0],
            'b' => "." . $numelms[1]
                            );
        $marc->insert_fields_ordered($new_ninety);
    }
    print OUTPUT $marc->as_usmarc();
}
 print "total: $totes\n";
 print "099: $ninety_nines\n";
 
$file->close();
undef $file;

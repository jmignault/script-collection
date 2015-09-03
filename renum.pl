#!/usr/bin/perl -w
#
# mv_renum [-n] [-#] filenames...
# mv_reseq [-nr] [-#|-#.#] filenames...
#
# Quick renumbering of the the LAST number in the filenames appropriately
# ordering the sequence of renaming to ensure no file is overwritten during the
# process.  Files are only renamed if needed.
#
# mv_renum
#
# Set the last number in each filename to a fixed width (2 by default, or the
# width given in the -# option).  This is done by adding and removing leading
# "0"s to fit the width.  A width of 1 (option -1) will just strip all leading
# "0"s.
#
# For any other width the program will abort before doing anything if a number
# is found that will NOT fit the width.
#
# mv_reseq
#
# Re-sequence the last number in each file into accending order. The numerical
# order of the files (not the alphabetical order) is preserved! By default the
# numbered sequence starts at 1, and increments by 1.
#    -#    Change the start number, and increment by 1
#    -.#   Set both start and increment to the same number given
#    -#.#  Set start and increment numbers individually
# The width of the number in the filenames are always resized to the maximum
# width found in all filenames, or the width which can contain the largest
# number.
#
# The -r option will reverse the ordering of the files (inverse reseq)
#
# Even if processing begins however, the program will NEVER overwrite an
# existing file.
#
# See Also
#   mv_perl    Renames filenames based on a perl RE (or code)
#   rename     Renames by replacing one string with another (Gnu-Linux)
#   mved       Renames both sides of the variable part.
#
#
# Anthony Thyssen    5 June 2002     <anthony@cit.gu.edu.au>
#
###
use strict;
use FindBin;
my $PROGNAME = $FindBin::Script;

sub Usage {
  print STDERR @_, "\n";
  @ARGV = ( "$FindBin::Bin/$PROGNAME" );
  while( <> ) {
    next if 1 .. 1;
    last if /^###/;
    s/^#$//; s/^# //;
    print STDERR "Usage: " if 2 .. 2;
    print STDERR;
  }
  exit 10;
}

my $renum = $PROGNAME =~ /renum/o;

my %file;    # the filename, split into parts, then rejoined into destination
my %num;     # the orginal number to filename map (file sequence order)
my $verbose = 1; # what is the program doing (debugging)
my $dry_run = 0;
my $reverse = 0;

# width or starting number and increment defaults
my $w = 0;   # no default given for width
my $n;       # undefined to start with
my $i = 1;   # resequence defaults to increments of one

ARGUMENT:  # Multi-switch option handling
while( @ARGV && $ARGV[0] =~ s/^-(?=.)// ) {
  $_ = shift; {
    m/^$/  && do { next };       # Next argument
    m/^-$/ && do { last };       # End of options
    m/^\?/ && do { Usage };      # Usage Help
    m/^-help$/   && Usage( -verbose => 1);    # quick help (synopsis)
    m/^-manual$/ && Usage( -verbose => 2);    # inline manual

    # simple flags
    s/^q// && do { $verbose=0;  redo };
    s/^v// && do { $verbose=1;  redo };
    s/^r// && do { $reverse=1;  redo };
    s/^n// && do { $dry_run=1;  redo };

    # width OR start and increment
    s/^(\d+)// && do { ( $renum ? $w : $n ) = $1; redo };
    s/^[,.](\d+)// && do { $i = $1; redo };

    Usage( "$PROGNAME: Unknown Option \"-$_\"" );
  } continue { next ARGUMENT }; last ARGUMENT;
}
$n = $i unless defined $n;
print "n=$n i=$i\n";

Usage("$PROGNAME: Invalid increment\n") if $renum && $i == 0;
Usage( "$PROGNAME: No filenames given" ) unless @ARGV;

unless ( @ARGV ) {
  #opendir(DIR,'.') || die "Can't open current directory";
  #@filenames = grep { -f } readdir(DIR);
  #closedir(DIR);
  Usage("$PROGNAME: No filenames given!\n");
}

# --------- initial file handling ----------
# Get all the filenames and file numbers and determine destination.
my $lrg = 0;    # largest length of the original file numbers
my $big = 0;    # biggest interger found in original file numbers
foreach( @ARGV ) {
  die("Given filename \"$_\" does not exist! -- ABORTING\n") unless -e $_;
  my @p = /^(.*)(?<!\d)(\d+)(.*)$/ or
               die("Filename \"$_\" contains no numbers! -- ABORTING\n");

  my $num = int $p[1];     # convert number string into a pure number
  die("Filenames \"$num{$num}\" and \"$_\"",
               " have the same number -- ABORTING\n") if exists $num{$num};

  $lrg = length($p[1]) if length($p[1]) > $lrg;  # largest original width
  $big = $num if $num > $big;                    # largest number found
  $num{$num} = $_;                     # sequencing order of filenames
  $file{$_} = [ @p ];                  # save the 3 strings from filename
}

# ------------ work out destination names -----------
if ( $renum ) {  # figure out best width for renumbering
  $lrg = length($big);   # the best width for the numbers in given filenames
  $lrg = 2 if $lrg < 2;  # minimum width (unless supplied)
  $w = $lrg if $w == 0;  # width not given, so use the best width.
}
else {           # figure out the width for resequencing
  $w = length( $n + $i * ( scalar(keys %num) -1) );
  $w = $lrg if $lrg > $w;  # never shrink any existing number in input files
}

# create the destination filename for each file
for my $num ( sort { $reverse ? $b<=>$a : $a<=>$b } keys %num ) {
  $_ = $num{$num};            # filename for this number
  $n = $num if $renum;        # the output number for this file

  # calculate the destination filename
  # NOTE: for renum preserve the existing width, if no width is defined
  # Replace the array of parts with the final destination filename
  $file{$_} = sprintf( "%s%0*d%s",
           $file{$_}[0],  ($w||length($file{$_}[1])), $n,    $file{$_}[2] );
  $n += $i unless $renum;     # increment the sequence if mv_reseq

  if ( $_ eq $file{$_} ) {    # remove files with will not need renaming
    delete($num{$num});       # no need to rename this filename!
    delete($file{$_});
    next;
  }
}

unless( %num ) {
  print STDERR "No filenames need to be renamed - DONE\n";
  exit 0;
}

# Sanity check..
# Will we rename a file to an existing file that will not itself be renamed!
for my $num ( sort { $a<=>$b } keys %num ) {
  $_ = $num{$num};    # original filename
  my $f = $file{$_};  # destination filename
  die("Unable to rename \"$_\" to existing file \"$f\" -- ABORTING\n")
              if !exists $file{$f} && -f $f;  # destination exists?
}

# ------------ rename the files -----------
# Try to rename each file in the right order.  This is needed as one filename
# may need to be renamed to a file that will later be be renamed.
#
# Eg: file_1 needs to be renamed to file_2 which currently exists, however
# file_2 will be later renamed to file_3, so that needs to be done first.
# A Worst case:  rename files  1,2,3,4,5,...  to files  2,3,4,5,6,...
# Only one file (the last) can be renamed for each run of the inner loop,
# and all the commands will need to be done in the reverse order.
#

print "$PROGNAME: Dry run in progress, order of commands may not be ideal\n"
  if $dry_run;
while ( %num ) {
  my $a_file_was_moved = 0;   # did we move a file -- stop infinite loops

  # for each file that is left to move - rename them in numerical sequence
  for my $num ( sort { $a<=>$b } keys %num ) {
    $_ = $num{$num};    # original filename
    my $f = $file{$_};  # destination filename

    next if -f $f && ! $dry_run; # can't move this file - YET! try again later

    print "mv \"$_\" \"$f\"\n" if $verbose;
    rename( $_, $f ) or die("rename \"$_\" \"$f\" failed: $!\n")
            unless $dry_run;
    delete($num{$num});  # This file has now been moved!
    delete($file{$_});
    $a_file_was_moved = 1;
  }

  # FUTURE -- look for filename swaps if no file moved
  # note a swap should NOT actually be posible as files are in sequence!

  # Make sure we are doing at least one move per loop -- or we have problems!
  die("Unable to rename files...\n", join(' ', values %num), "\n --ABORTING\n")
    unless $a_file_was_moved;
}

print "DONE\n" if $verbose;
exit(0);

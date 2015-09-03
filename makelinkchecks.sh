#!/bin/bash
# $Id: makelinkchecks.sh 28 2009-06-16 16:47:29Z  $
# this is makelinkchecks.sh, a simple wrapper script to automate making
# the linkchecker output for the cataloging dept.
set PATH=/opt/local/bin:$HOME/bin:$PATH
perl -i.bak -lanpe 's/";"/;/g' links.csv
~/bin/makecheckinglinks.rb -f links.csv -o links.html
/opt/local/bin/linkchecker -q -F html --no-status --no-warnings ./links.html
mv linkchecker-out.html linkchecker-nowarn.html
/opt/local/bin/linkchecker -q -F html --no-status ./links.html
rm links.csv links.html

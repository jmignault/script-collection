#!/bin/bash
#
# Script to backup Innovative Library System
#
# May 23, 2005  ;rdj;   created
#
# This script uses the III API called iiictl.  The command is located in the
# /usr/sbin directory. The plan is to create a daily backup directory and then 
# run iiictl to copy the Innovative files into it.
# Then Backup Exec will copy those files and all system files on it's normal run.
# Backup Exec will not backup the III directories.
#

echo "Starting III backup on `date`"
 
# make sure the rm command does not have an alias
unalias rm

# setup date and time variables for directory creation
BUD=`date +%b%d%Y`
echo "BackupDate="$BUD
DOW=`date +%a`
echo "Day of the Week="$DOW
echo "Backup Date="$BUD
echo ""

#
# remove old backup sets first - older than 3 days for now
# This happens only Tuesday-Saturday
# This will leave three days worth of backups online before the oldest ones get deleted
# Note: the find command syntax here is specific for RedHat AS2.1.  This script concept
# was first used on AIX where the find command used the -prune argument

        find /iiibackup/millennium/ -mtime +1 -type d -maxdepth 1 -exec rm -rf {} \;

## Set actual backup directory location

       DBLOC="/iiibackup/millennium/$BUD"
       echo "DBLOC="$DBLOC
#
## Check for todays date.  If it exists, remove it and create a new one
        if [ -d $DBLOC ] ; then
                echo "Backup directory already exists, removing"
                cd /iiibackup/millennium
                rm -rf $BUD
        else
                echo "No duplicate found... continuing"
        fi
#
## Create new directory and copy datafiles
        echo "Creating backup directory for III Millennium"
        mkdir $DBLOC

#
## Run the III commands to prepare for the backup
# 
#
# The set notify only needs to happen once and is stored
#       /usr/sbin/iiictl set notify jmignault@nybg.org
        /usr/sbin/iiictl get notify
        /usr/sbin/iiictl backup prepare
        prepare_val=$?
        echo "Prepare Value="$prepare_val
        if [ $prepare_val -eq 0 ]
                then
                        cd /
                        tar cf - iiidb --exclude lost+found --exclude /iiidb/sockets | (cd $DBLOC; tar xBf -)
                        tar cf - iii --exclude lost+found | (cd $DBLOC; tar xBf -)
                        tar cf - iiiroot | (cd $DBLOC; tar xBf -)
                        /usr/sbin/iiictl backup success
                        success_val=$?
                        echo "Success Value="$success_val
                                if [ $success_val -neq 0 ]
                                  then
                                     mail -s "III Backup Success command Failed" jmignault@nybg.org
                                fi
#                       /usr/sbin/iiictl log dump
                else
                        /usr/sbin/iiictl backup fail
                        fail_val=$?
                        echo "Fail Value="$fail_val
                                if [ $fail_val -eq 0 ]
                                  then
                                    mail -s "III Backup Failed" jmignault@nybg.org
             fi
        fi
#
echo "Backup completed at `date`"
  
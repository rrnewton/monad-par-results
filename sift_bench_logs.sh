#!/bin/bash

set -e

echo 
echo " ** First, make sure all .log files are compressed."
for log in `find -name "*.log"`; do 
  bzip2 "$log"
done

#------------------------------------------------------------
echo 
echo " ** Second, move all .log.bz2 files from the results_data/ dir to an analogous full_logs/ dir..."


# bzlogs=`find results_data/ -name "*.log.bz2"`

# for log in $bzlogs; do 
for log in `find results_data/ -name "*.log.bz2"`; 
do 
  file=`basename $log`  
  dir=`dirname $log | sed 's/results_data/full_logs/'`
  echo "Filing away $file ..."
  mkdir -p $dir
  mv $log "$dir"/
done

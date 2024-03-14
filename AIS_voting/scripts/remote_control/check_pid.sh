#!/usr/bin/bash

program="/usr/sbin/nginxd"
freq=0.5
count=$(bc<<<"scale=0;59/${freq}")

for (( i=1; i<=${count}; i++ )); 
do 

  #check PID
  TEST=`pidof ${program}`

  if [ -z  "$TEST" ]; then
    #not running... restart!
    ${program} &
  fi

  sleep ${freq}; 
done;

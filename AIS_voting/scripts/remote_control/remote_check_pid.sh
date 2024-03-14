#!/usr/bin/bash

wks_user='u'

if [ -n "$1" ]
then
  wks=$1
else
  wks=$(<wks.txt)
fi

for r in ${wks[@]}; do

  scp check_pid.sh ${wks_user}@${r}:/tmp
  
  ssh ${wks_user}@${r} "sudo mkdir -p /usr/local/script"
  ssh ${wks_user}@${r} "sudo mv /tmp/check_pid.sh /usr/local/script/check_pid.sh"

  ssh ${wks_user}@${r} sudo sh -c "echo '* * * * * u bash /usr/local/script/check_pid.sh' > /etc/cron.d/check_pid"

done

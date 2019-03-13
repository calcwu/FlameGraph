#!/bin/bash

adia_pid=`ps -ef | grep java | grep -v root | grep adiad | awk '{print $2}'`

if ! [[ "$adia_pid" =~ ^[0-9]+$ ]]
    then
  echo "Invalid pid: $adia_pid"
fi

echo "Collecting stacks from $adia_pid"

for idx in $(seq 1 120); do
    echo $idx $(date)
    sudo jstack $adia_pid >> /home/addepar/adia4/adia4.$(date +%Y%m%d).stack
    sleep 30;
done

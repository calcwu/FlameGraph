#!/bin/bash

#adia_pid=`ps -ef | grep java | grep adiad | awk 'FNR>1 {print $2}'`
adia_pid=1

if ! [[ "$adia_pid" =~ ^[0-9]+$ ]]
    then
  echo "Invalid pid: $adia_pid"
fi

echo "Collecting stacks from $adia_pid"

for idx in $(seq 1 120); do
    echo $idx $(date)
    jstack $adia_pid >> /root/adia4/adia4.$(date +%Y%m%d).stack
    sleep 30;
done

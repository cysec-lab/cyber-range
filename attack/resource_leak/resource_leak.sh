#!/bin/sh

#info=`free -t | grep 'total'`
echo "             Total       used       free     shared    buffers     cached"
while true
do
    ./resource_leak
    pid=`pidof resource_leak | cut -d ' ' -f 1`
    #echo "before config"
    #cat /proc/$pid/oom_score
    #echo "before config"
    echo -17 > /proc/$pid/oom_adj
    #cat /proc/$pid/oom_score
    
    free -t | grep 'Mem'
    if [ $? = 1 ]; then
        break
    fi
    sleep 2
done

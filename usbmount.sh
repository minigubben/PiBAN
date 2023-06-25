#!/bin/bash
devname=$(basename $1)
logname=/tmp/$devname.log

echo "Detected new device: $1" >>/var/log/PiBAN.log

if [ "${ACTION}" = "add" ]; then
    python3 /usr/local/bin/nuke.py $1 >$logname &
    disown
fi

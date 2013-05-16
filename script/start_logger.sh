#!/bin/bash

DIR=$( cd "$( dirname "$0" )" && pwd )
. $DIR/config.sh

if [ -z "$1" -o -z "$2" -o -z "$3" ]; then
	echo "Usage $0 id-of-iButton delay frequency"
	exit 9
fi
p="$1"
delay="$2"
freq="$3"

#stop in any case
$wwrite "$p/mission/enable" 0

#clear memory
$wwrite "$p/mission/clear" 1

#start and set clock
$wwrite "$p/clock/running" 1
$wwrite "$p/clock/udate" $(date +%s)

#setup mission
$wwrite "$p/mission/delay" $delay
$wwrite "$p/mission/enable" 1
$wwrite "$p/mission/frequency" $freq


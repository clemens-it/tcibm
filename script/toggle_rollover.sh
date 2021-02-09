#!/bin/bash

DIR=$( cd "$( dirname "$0" )" && pwd )
. $DIR/config.sh

if [ -z "$1" ]; then
	echo "Usage $0 id-of-iButton"
	exit 9
fi
p=$1

mr=$($wread "$p/mission/rollover")
if [ "$mr" == "0" ]; then
	nmr=1
fi
if [ "$mr" == "1" ]; then
	nmr=0
fi

if [ -z "$nmr" ]; then
	echo ""
	exit 8
fi

$wwrite "$p/mission/rollover" "$nmr"
mr=$($wread "$p/mission/rollover")
if [ "$mr" == 0 ]; then mr="OFF"; fi
if [ "$mr" == 1 ]; then mr="ON"; fi

echo "Rollover is $mr now"

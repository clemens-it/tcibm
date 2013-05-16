#!/bin/bash

DIR=$( cd "$( dirname "$0" )" && pwd )
. $DIR/config.sh

if [ -z "$1" ]; then
	echo "Usage $0 id-of-iButton"
	exit 9
fi
p=$1

$wwrite "$p/mission/enable" 0
$wwrite "$p/clock/running" 0


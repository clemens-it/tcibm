#!/bin/bash

DIR=$( cd "$( dirname "$0" )" && pwd )
. $DIR/config.sh

if [ -z "$1" -o -z "$2" ]; then
	echo "Usage $0 id-of-iButton text"
	exit 9
fi
p=$1

$wwrite "$p/memory" "$(printf "%-512s" "$2")"

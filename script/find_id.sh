#!/bin/bash

DIR=$( cd "$( dirname "$0" )" && pwd )
. $DIR/config.sh

if [ "$1" = "-u" ]; then
	$wdir uncached | egrep "^/uncached/21\." | sed -e 's#/uncached/##'
else
	$wdir | egrep "^/21\." | sed -e 's#/##'
fi


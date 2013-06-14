#!/bin/bash

#DIR=$( cd "$( dirname "$0" )" && pwd )
#. $DIR/config.sh
. ./config.sh


kill -9 $(pgrep owserver)
kill -9 $(pgrep owhttpd)
owserver -u -p $owserverport
owhttpd -s $owserverport -p 3001

alias wdir="owdir -s $owserverport "
alias wget="owget -s $owserverport "
alias wread="owread -s $owserverport "
alias wwrite="owwrite -s $owserverport "


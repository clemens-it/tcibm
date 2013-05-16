#!/bin/bash

# the purpose of this file is to be called with mintty.exe in an CygWin environment.
# you can create an shortcut to the following target:
# C:\wherever-cygwin-is-stalled\bin\mintty.exe -he -e /opt/iButtonManager/cwibmmenu.sh

cd /opt/iButtonManager
export PATH=/usr/local/bin:/usr/bin
exec ./ibmmenu.sh


#!/bin/bash

# the purpose of this file is to be called with mintty.exe in an CygWin environment.
# you can create an shortcut to the following target:
# C:\wherever-cygwin-is-installed\bin\mintty.exe -he -e /opt/tcibm/cwibmmenu.sh

cd /opt/tcibm
export PATH=/usr/local/bin:/usr/bin
exec ./ibmmenu.sh

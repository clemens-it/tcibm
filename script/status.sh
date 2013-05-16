#!/bin/bash

DIR=$( cd "$( dirname "$0" )" && pwd )
. $DIR/config.sh

if [ -z "$1" ]; then
	echo "Usage $0 id-of-iButton --convert01offon"
	exit 9
fi
p="$1"
convert="$2"

function convert01offon () {
	if [ "$1" == 0 ]; then echo "OFF"; return; fi
	if [ "$1" == 1 ]; then echo "ON"; return; fi
	echo "$1"
}

cd=$($wread "$p/clock/date")
cu=$($wread "$p/clock/udate")
cu=${cu//[[:space:]]/}
cr=$($wread "$p/clock/running")
as=$($wread "$p/about/samples")
as=${as//[[:space:]]/}
av=$($wread "$p/about/version")

#men=$($wread "$p/mission/enable")
rn=$($wread "$p/mission/running")
mf=$($wread "$p/mission/frequency")
mf=${mf//[[:space:]]/}
mdl=$($wread "$p/mission/delay")
mdl=${mdl//[[:space:]]/}
mr=$($wread "$p/mission/rollover")
ms=$($wread "$p/mission/samples")
ms=${ms//[[:space:]]/}
mds=$($wread "$p/mission/date")
le=$($wread "$p/log/elements")
le=${le//[[:space:]]/}

if [ "$convert" == "--convert01offon" ]; then
	cr=$(convert01offon $cr)
	#men=$(convert01offon $men)
	mr=$(convert01offon $mr)
	rn=$(convert01offon $rn)
fi

echo -e "iButton status: $p\n"
echo -e "About"
echo -e "  Version             $av"
echo -e "  Overall samples     $as"
echo -ne "\n"

echo -e "Clock iButton"
echo -e "  Current date/time:  $cd  ($cu)"
echo -e "  Clock running:      $cr"
echo -ne "\n"

echo -e "Mission"
#echo -e "  Enabled:            $men"
echo -e "  Running:            $rn"
echo -e "  Rollover:           $mr"
echo -e "  Delay:              $mdl"
echo -e "  Frequency:          $mf"
echo -e "  Start:              $mds"
echo -e "  Samples:            $ms"
echo -ne "\n"

echo -e "Log"
echo -e "  Elements:           $le"

echo -ne "\nMemory Content:\n"
$wread "$p/memory"


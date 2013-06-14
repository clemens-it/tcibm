#!/bin/bash

DIR=$( cd "$( dirname "$0" )" && pwd )
. $DIR/config.sh

if [ -z "$1" ]; then
	echo "Usage $0 -c -v id-of-iButton "
	echo -e "\n\t-c  convert 0/1 TO OFF/ON when giving verbose output"
	echo -e "\t-v  verbose output"
	exit 9
fi
opt_verbose=0
opt_convert=0

while getopts "cv" opt; do
	case $opt in
		c)
			opt_convert=1
			;;
		v)
			opt_verbose=1
			;;
		\?)
			#echo Invalid option: -$OPTARG >&2
			exit 1
			;;
	esac
done
shift $((OPTIND-1))
p="$1"

function convert01offon () {
	if [ "$1" == 0 ]; then echo "OFF"; return; fi
	if [ "$1" == 1 ]; then echo "ON"; return; fi
	echo "$1"
}

cd=$($wread "$p/clock/date")
cr=$($wread "$p/clock/running")
rn=$($wread "$p/mission/running")
mf=$($wread "$p/mission/frequency")
mf=${mf//[[:space:]]/}
mr=$($wread "$p/mission/rollover")

if [ $opt_verbose -eq 1 ]; then
	as=$($wread "$p/about/samples")
	as=${as//[[:space:]]/}
	av=$($wread "$p/about/version")
	cu=$($wread "$p/clock/udate")
	cu=${cu//[[:space:]]/}

	#men=$($wread "$p/mission/enable")
	#men=$(convert01offon $men)
	mdl=$($wread "$p/mission/delay")
	mdl=${mdl//[[:space:]]/}
	ms=$($wread "$p/mission/samples")
	ms=${ms//[[:space:]]/}
	mds=$($wread "$p/mission/date")
	le=$($wread "$p/log/elements")
	le=${le//[[:space:]]/}
fi

if [ $opt_verbose -eq 1 ]; then
	if [ $opt_convert -eq 1 ]; then
		cr=$(convert01offon $cr)
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
else
	cr=$(convert01offon $cr)
	rn=$(convert01offon $rn)

	echo -e "iButton status: $p\n"
	echo -e "Clock: $cr, $cd"
	echo -ne "\n"

	echo -n "Mission: $rn, "
	if [ "$mr" == "1" ]; then
		nop=1
	else
		echo -n "NO "
	fi
	echo -n "rollover, frequency: $mf"
	echo -ne "\n"
fi

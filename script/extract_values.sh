#!/bin/bash


DIR=$( cd "$( dirname "$0" )" && pwd )
. $DIR/config.sh

if [ -z "$1" -o -z "$2" ]; then
	echo "Usage $0 id-of-iButton base-filename"
	exit 9
fi
p="$1"
bfn="$2"
l="$p/log"

datestart=$($wread "$p/mission/date")

freq=$($wread "$p/mission/frequency")
freq=${freq//[[:space:]]/}

missionstart=$($wread "$p/mission/udate")
missionstart=${missionstart//[[:space:]]/}

samples=$($wread "$p/mission/samples")
samples=${samples//[[:space:]]/}

elements=$($wread "$l/elements")
elements=${elements//[[:space:]]/}

missrollover=$($wread "$p/mission/rollover")

#abort if there are no elements to read
if [ $elements -le 0 ]; then
	echo "No elements to read"
	exit 8
fi

if [ -z "$missrollover" ]; then
	echo "Mission rollover could not be read"
	exit 7
fi

if [ "$missrollover" == "0" ]; then
	((missionend=missionstart+(elements-1)*freq*60))
else
	((missionend=missionstart+(samples-1)*freq*60))
	#calculate new missionstart for the case that rollover is enabled and samples > elements
	((missionstart=missionend-elements*freq*60))
fi

#variables for rrd
((rrdstep=freq*60))
((rrdstart=missionstart-rrdstep))
rrdheartbeat=$rrdstep

tmpf=$(mktemp -t tmp.ibm.XXXXXXXX)

#rrdtool under cygwin (rrdtool.exe is acutally a pure windows prog) has issues with paths (strings containting slashes), therefore we
#need to store the file (rrd file and png created by rrdtool graph) in the current directory
tmprrd=tmp.log
tmpgraph=tmp.graph
trap "rm -f $tmpf $tmprrd $tmpgraph" 0 1 2 5 15

#read in all elements at once ant put them into array
#the following two commands can not be done in one pipe, because readarray would be 
#executed in a subshell, from there the created variable would be lost
$wread "$l/temperature.ALL" | sed -e 's/ //g; s/,/\n/g' > $tmpf
readarray -t temperatures < $tmpf

rm -f "$bfn.png" "$bfn.txt"
echo "Missionstart;$datestart;Mission start;$missionstart;Mission end;$missionend;Frequency[min];$freq;Elements;$elements" > "$bfn.txt"

#decrease elements by one for sake of the loop
((elements--))
for i in $(seq 0 $elements); do
	((tm=missionstart+(i*freq*60)))
	echo -e "$tm;${temperatures[$i]}" 
done >> "$bfn.txt"

#create and update rrd
$rrdtool create "$tmprrd" --start $rrdstart --step $rrdstep \
	DS:temperature:GAUGE:$rrdheartbeat:U:U \
	RRA:LAST:0:1:2100

tail -n +2 "$bfn.txt" | tr ";" ":" | xargs $rrdtool update "$tmprrd" 


# graph
#determine time differenc from UTC and set TZ accordingly for rrdgraph
ts=$(date +%k)
tsu=$(date +%k -u)
((tdiff=ts-tsu))
case $tdiff in
	0) TZ=UTC ;;
	1) TZ=CET-1 ;;
	2) TZ=CET-1CEST ;;
esac

$rrdtool graph "$tmpgraph" --width $graphwidth --height $graphheight --start $rrdstart --end $missionend --step $rrdstep --right-axis 1:0\
	DEF:temp="$tmprrd":temperature:LAST \
	VDEF:tmax=temp,MAXIMUM \
	VDEF:tmin=temp,MINIMUM \
	VDEF:tavg=temp,AVERAGE \
	COMMENT:"\n" \
	LINE1:temp#ff0000:"Temperature   " \
	COMMENT:"  Maximum " \
	GPRINT:tmax:"%5.2lf" \
	COMMENT:"  Average " \
	GPRINT:tavg:"%5.2lf" \
	COMMENT:"  Minimum " \
	GPRINT:tmin:"%5.2lf" \
	HRULE:${graph_upperlimit}${graph_ulimit_color} \
	HRULE:${graph_lowerlimit}${graph_llimit_color}

mv $tmpgraph "$bfn.png" 

#if enabled, upload the text file containing the data
# if $upload_data ist not configured, set to 0
if [ -z "$upload_data" ]; then
	upload_data=0
fi
if [ $upload_data -eq 1 ]; then
	curl $curl_params --form templog=@$bfn.txt "$upload_url"
fi

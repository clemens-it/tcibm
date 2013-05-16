#path for owfs binaries
bpath=/opt/owfs/bin

echo $PATH | grep $bpath >/dev/null
if [ $? -ne 0 ]; then
	export PATH=$PATH:$bpath
fi

owserverport=3000
#shortcuts for owfs shell binaries
wdir="$bpath/owdir -s $owserverport "
wget="$bpath/owget -s $owserverport "
wread="$bpath/owread -s $owserverport "
wwrite="$bpath/owwrite -s $owserverport "

#path where to write the data
datapath=/opt/iButtonManager/data
#first part of data filename
outputfnbase=templog

#path and filename of registry-database
regdb=$datapath/regdb.txt

#path and filename for rrdtool binary
rrdtool=./rrdtool


#width and height for image produces by rrdtool graph
graphwidth=900
graphheight=500

#two lines are drawn in graph to indicate an upper and a lower limit
graph_upperlimit=10
graph_lowerlimit=0

#default memory content displayed in dialog window when writing memory of thermocron iButton
default_memory_content="This is property of My Company.\nMy Company, Subdivision in City (Country).\n"

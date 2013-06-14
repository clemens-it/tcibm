#!/bin/bash

DIR=$( cd "$( dirname "$0" )" && pwd )
. $DIR/config.sh
. $DIR/functions.sh
cd $DIR


start_ow_server
pgrep owserver > /dev/null
if [ $? -ne 0 ]; then
	msg="\nowServer is not running. Please start the server\nand try again.\nMake also sure that the OW-USB adapter is plugged in."
	dialog --title "Thermochron iButton Manager - Startup" \
		--backtitle "$backtitle" \
		--msgbox "$msg" 9 60
	exit	
fi

fres1=$(mktemp -t tmp.ibm.XXXXXXXX)
ftxt=$(mktemp -t tmp.ibm.XXXXXXXX)
fid=$(mktemp -t tmp.ibm.XXXXXXXX)
trap "rm -f $fres1 $ftxt $fid; stop_ow_server" 0 1 2 5 15

backtitle="Thermochron iButton Manager - written by EgC"

ids=$(list_ids)
if [ -z "$ids" -a "$selection" != "Q" ]; then
	msg="\nCould not find any iButtons. Please make sure the server"
	msg="$msg is running, the reading-unit being connected and at "
	msg="$msg least one iButton placed on the reader"
	dialog --title "Could not find any iButton" \
		--backtitle "$backtitle" \
		--msgbox "$msg" 9 60
	exit 9
fi


echo -ne "" > $ftxt #init $ftxt
./find_id.sh -u >$fid
txt="The following iButtons will be reset and set up for immediate deployment:\n\n $(list_ids)\n\nDo you really want to continue?"  
dialog --title "Thermochron iButton Manager - Quick Start" \
	--backtitle "$backtitle" \
	--yesno "$txt" 14 65 \
	2> $fres1

if [ $? -eq 0 ]; then
	./find_id.sh -u | while read id; do
		# setup iButton for deployment
		freq=1
		delay=0
		stop=0
		if [ $freq -le 0 -o $freq -gt 255 -o $delay -lt 0 -o $delay -gt 65535 ]; then
			stop=1
			msg="\nGiven paramters for frequency and/or delay are out of range."
			msg="$msg Please change the configuration and try again."
			dialog --title "Program of iButton for deployment" \
				--backtitle "$backtitle" \
				--msgbox "$msg" 8 60
		fi

		if [ $stop -eq 0 ]; then
			dialog --title "Setting up iButtons for deployment" \
				--backtitle "$backtitle" \
				--infobox "\n\nPlease wait while iButtons are programmed ..." 7 60
			$wwrite "$id/mission/rollover" 0 
			./start_logger.sh "$id" "$delay" "$freq"
			sleep 0.3s
			./status.sh "$id" >> $ftxt
			echo >> $ftxt; echo >> $ftxt; echo >> $ftxt
		fi
	done

	dialog --title "Quick start - Status of iButton(s)" \
		--backtitle "$backtitle" \
		--textbox $ftxt 40 80
fi


stop_ow_server

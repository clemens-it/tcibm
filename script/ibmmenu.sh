#!/bin/bash

DIR=$( cd "$( dirname "$0" )" && pwd )
test -f $DIR/config.sh || { echo "Configuration file $DIR/config.sh not found. Aborting." ; exit 1; }
test -f $DIR/functions.sh || { echo "Function include file $DIR/functions.sh not found. Aborting." ; exit 1; }
. $DIR/config.sh
. $DIR/functions.sh
cd $DIR


start_ow_server
pgrep owserver > /dev/null
if [ $? -ne 0 ]; then
	msg="\nowServer is not running. Please start the server\nand try again"
	dialog --title "Thermochron iButton Manager - Startup" \
		--backtitle "$backtitle" \
		--msgbox "$msg" 8 60
	exit
fi

fres1=$(mktemp -t tmp.ibm.XXXXXXXX)
fres2=$(mktemp -t tmp.ibm.XXXXXXXX)
fid=$(mktemp -t tmp.ibm.XXXXXXXX)
ftxt=$(mktemp -t tmp.ibm.XXXXXXXX)
ffnaddinfo=$(mktemp -t tmp.ibm.XXXXXXXX)
trap "rm -f $fres1 $fres2 $fid $ftxt $ffnaddinfo; stop_ow_server" 0 1 2 5 15


backtitle="Thermochron iButton Manager - written by EgC"
selection=""
while [ "$selection" != "Q" ]; do

	dialog --title "Thermochron iButton Manager" \
		--backtitle "$backtitle" \
		--menu "Please choose an option:" 17 55 10 \
		S "show Status" \
		D "setup for Deployment" \
		E "stop and Extract temperature log" \
		" " " " \
		T "sTop iButton" \
		X "eXtract temperature log" \
		L "toggle Log rollover" \
		R "Register new iButton" \
		M "set Memory" \
		Q "Quit" \
		2> $fres1

	if [ $? -ne 0 ]; then
		selection=Q
	else
		selection=$(cat $fres1)
	fi

	ids=$(list_ids)
	if [ -z "$ids" -a "$selection" != "Q" ]; then
		msg="\nCould not find any iButtons. Please make sure the server"
		msg="$msg is running, the reading-unit being connected and at "
		msg="$msg least one iButton placed on the reader"
		dialog --title "Could not find any iButton" \
			--backtitle "$backtitle" \
			--msgbox "$msg" 9 60
		selection=again
	fi

	case $selection in
		E|X)
			# stop(optioanlly!) and extract contents
			title="Stop and extract temperature log"
			stop=0
			if [ "$selection" == "X" ]; then
				title="Extract temperature log"
			fi
			iButton_selection "$title"
			test $? -ne 0 && stop=1

			if [ $stop -eq 0 ]; then
				id=$(cat $fid)
				idn=$(id_lookup $id | sed -e 's/[^a-zA-Z0-9!,._-]/_/g;')
				logfn_add_info "Additional description for filename"
				test $? -ne 0 && stop=1
			fi
			if [ $stop -eq 0 ]; then
				# ffnaddinfo is written by func logfn_add_info
				fn_add_info=$(cat $ffnaddinfo)
				if [ ! -z "${fn_add_info}" ]; then
					fn_add_info="-${fn_add_info}"
				fi
				dialog --backtitle "$backtitle" --infobox "Extracting data, please wait..." 3 50
				if [ "$selection" == "E" ]; then
					./stop_logger.sh $(cat $fid)
				fi
				txtfn=$datapath/$outputfnbase-$(date +%Y-%m-%d_%H.%M)-$id-$idn${fn_add_info}
				./extract_values.sh "$(cat $fid)" "$txtfn"
				if [ $? -eq 8 ]; then
					dialog --title "Could not find any iButton" \
						--backtitle "$backtitle" \
						--msgbox "\nThere is no temperature log on this iButton" 7 60
				fi
			fi
		;;
		T)
			# stop iButton
			iButton_selection "Stop logging"
			if [ $? -eq 0 ]; then
				./stop_logger.sh "$(cat $fid)"
			fi
		;;

		D)
			# setup iButton for deployment
			stop=0
			iButton_selection "set up iButton for deployment"
			test $? -ne 0 && stop=1

			if [ $stop -eq 0 ]; then
				dialog --title "Setup iButton for deployment" \
					--backtitle "$backtitle" \
					--inputbox "Logging frequency (1..255 minutes)" 8 40 \
					2>$fres1
				test $? -ne 0 && stop=1
			fi

			if [ $stop -eq 0 ]; then
				dialog --title "Setup iButton for deployment" \
					--backtitle "$backtitle" \
					--inputbox "Delay before start logging (0..1092 hours)" 8 40 \
					2>$fres2
				test $? -ne 0 && stop=1
			fi

			if [ $stop -eq 0 ]; then
				freq=$(cat $fres1)
				((freq=freq))
				delay=$(cat $fres2)
				((delay=delay*60))
				if [ $freq -le 0 -o $freq -gt 255 -o $delay -lt 0 -o $delay -gt 65535 ]; then
					stop=1
					msg="\nGiven paramters for frequency and/or delay are out of range."
					msg="$msg Please try again."
					dialog --title "Setup iButton for deployment" \
						--backtitle "$backtitle" \
						--msgbox "$msg" 8 60

				fi
			fi

			if [ $stop -eq 0 ]; then
				./start_logger.sh "$(cat $fid)" "$delay" "$(cat $fres1)"
				sleep 0.3s
				./status.sh -c -v "$(cat $fid)"  > $ftxt
				dialog --title "Setup for deployment - Status of iButton $(cat $fid)" \
					--backtitle "$backtitle" \
					--textbox $ftxt 40 80
			fi

		;;
		S)
			# status
			iButton_selection "Show status of iButton"
			if [ $? -eq 0 ]; then
				id=$(cat $fid)
				idn=$(id_lookup $id)
				./status.sh -c -v "$id" > $ftxt
				dialog --title "Status of iButton $id $idn" \
					--backtitle "$backtitle" \
					--textbox $ftxt 40 80
			fi
		;;
		L)
			#toggle log rollover
			iButton_selection "Toggle log rollover"
			if [ $? -eq 0 ]; then
				id=$(cat $fid)
				idn=$(id_lookup $id)
				msg=$(./toggle_rollover.sh "$id")
				dialog --title "Toggle log rollover $id $idn" \
					--backtitle "$backtitle" \
					--msgbox "\n$msg" 7 65
			fi
		;;
		R)
			# Register
			./find_id.sh -u >$fid
			if [ $(wc -l < $fid) -eq 1 ]; then
				id=$(cat $fid)
				idn=$(id_lookup $id)
				ok=1
				if [ ! -z "$idn" ]; then
					msg="This iButton has been already registered with the following\n"
					msg="${msg}name: $idn\nDo you want to overwrite the name?"
					dialog --title "Register new iButton" --backtitle "$backtitle" \
						--yesno "$msg" 8 65
					test $? -eq 1 && ok=0
				fi
				if [ $ok -eq 1 ]; then
					dialog --title "Register new iButton" \
						--backtitle "$backtitle" \
						--inputbox "Please enter a description (color) for iButton $id" 8 60 \
						2> $fres1
					if [ $? -eq 0 ]; then
						id_register "$id" "$(cat $fres1)"
					fi
				fi
			else
				msg="\nCould not identify iButton. Please make sure that there"
				msg="$msg is only ONE iButton connected at the reader"
				dialog --title "Register new iButton" \
					--backtitle "$backtitle" \
					--msgbox "$msg" 8 60
			fi
		;;
		M)
			# set memory
			stop=0
			iButton_selection "Set iButton's memory"
			test $? -ne 0 && stop=1

			if [ $stop -eq 0 ]; then
				echo -e "$default_memory_content" > $ftxt
				dialog --title "Set iButton's memory" \
					--backtitle "$backtitle" \
					--editbox $ftxt 40 80 \
					2> $fres2
			fi
			if [ $? -eq 0 ]; then
				./write_memory.sh "$(cat $fid)" "$(cat $fres2)"
			fi
		;;
		Q)
			s=end
		;;
	esac
done

stop_ow_server


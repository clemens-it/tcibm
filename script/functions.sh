
function id_register() {
	local id=$1
	local description=$2

	tmpdb=$(mktemp -t tmp.ibm.XXXXXXXX)
	grep -v "^$id" "$regdb" | grep -v "^$" > $tmpdb
	echo -e "$id\t$description" >> $tmpdb
	cat $tmpdb > "$regdb"
	rm $tmpdb
}

function id_lookup() {
	local id=$1
	if [ ! -z $id ]; then
		grep "^$id" "$regdb" | cut -f2
	fi
}


function list_ids() {
	local ids=$(./find_id.sh -u )
	echo "$ids" | while read id; do
		if [ ! -z "$id" ]; then
			echo -ne "$id \"$(id_lookup $id)\" "
		fi
	done
}


function start_ow_server() {
	pgrep owserver > /dev/null
	if [ $? -ne 0 ]; then
		owserver -u -p $owserverport --foreground &
	fi
}


function stop_ow_server() {
	pgrep owserver > /dev/null
	if [ $? -eq 0 ]; then
		pgrep owserver | xargs kill -9
	fi
}


function iButton_selection() {
	#if there's only one iButton connected to the reader, write its ID into
	#$fid and return 0. If there are more connected, show menu and return
	#the corresponding user selection
	local title=$1
	./find_id.sh -u >$fid
	if [ $(wc -l < $fid) -eq 1 ]; then
		#id of only button is already in $fid
		return 0
	else
		#there's more than one button connected, show menu
		local ids=$(list_ids)
		echo $ids | xargs dialog --title "$title" \
			--backtitle "$backtitle" \
			--menu "Please choose an iButton:" 15 65 5  \
			2>$fid
		return $?
	fi
}

function logfn_add_info () {
	# Asks for additional description to put in the filename of the
	# temperature log. Result is written to file $ffnaddinfo
	# this function must not be called like x=$(logfn_add_info "title") all the
	# dialogs would be written into variable x, too.
	local title=$1
	local ask_done=0
	local entries
	local fnres=""
	local msg=""
	if [ "$logfn_ask_add_info" != "0" ]; then
		ask_done=0
		# loop until information is given (if it is required in config)
		while [ $ask_done -eq 0 ] ; do
			if [ ${#logfn_precompiled_entries[@]} -ne 0 ]; then
				entries=("${logfn_precompiled_entries[@]}")
				if [ "$logfn_limit_to_precompiled" == "0" ]; then
					entries+=("Other ...")
				fi
				entries=$(for i in "${entries[@]}"; do
					echo -ne "\"$i\" \"$i\" off "
				done)
				echo $entries | xargs dialog --title "$title" \
					--backtitle "$backtitle" --notags \
					--radiolist "\nPress space to select the entry" 18 60 10 \
					2> $ffnaddinfo
				if [ $? -ne 0 ]; then
					return 1
				fi
				# for the case that "Other ..." was selected set an appropriate
				# message for the input box
				msg="Other ... Please specify"
				fnres=$(cat $ffnaddinfo)
			else
				# in case list of entries is empty, come up with a input box - the same
				# as if "Other ..." had been choosen. set also message for input box
				fnres="Other ..."
				msg=""
			fi
			if [ "$fnres" == "Other ..." ]; then
				dialog --title "$title" --backtitle "$backtitle" \
					--inputbox "\n$msg" 9 60 \
					2> $ffnaddinfo
				if [ $? -ne 0 ]; then
					return 1
				fi
				fnres=$(cat $ffnaddinfo)
			fi

			if [ "$logfn_add_info_required" != "0"  -a "$fnres" == "" ]; then
				dialog --title "$title" --backtitle "$backtitle" \
					--msgbox "\nAdditional information for filename is required. Please specify" 8 60
			else
				ask_done=1
			fi
		done
		# clean file name, first trim, then replace all invalid chars with _
		echo -n $fnres | sed -e 's/^ *//g' -e 's/( )*$//g' | tr -cs "[:alnum:]-_." _ > $ffnaddinfo
	fi
}


function id_register() {
	id=$1
	description=$2
	
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
		owserver -u -p $owserverport
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
	title=$1
	./find_id.sh -u >$fid
	if [ $(wc -l < $fid) -eq 1 ]; then
		#id of only button is already in $fid
		return 0
	else
		#there's more than one button connected, show menu
		ids=$(list_ids)
		echo $ids | xargs dialog --title "$title" \
			--backtitle "$backtitle" \
			--menu "Please choose an iButton:" 15 65 5  \
			2>$fid
		return $?
	fi
}

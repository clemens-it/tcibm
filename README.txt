Thermochron iButton Manager
===========================

This set of scripts has been developed and tested mainly under the Cygwin environment.

Cygwin installation requirements:
You need a standard cygwin installation plus the following Cygwin packages:
	procps, dialog
	libusb*+ if your One Wire devices will be connected via USB

Furthermore you will need the owfs binaries. Check out the following page for instructions
how to build OWFS on Cygwin: http://www.clemens.it/dev/doku.php?id=building_owfs_on_cygwin


Configuration file
------------------
copy or rename the file config.sh.sample to config.sh and adapt its settings to your needs.



Scripts providing a user interface
----------------------------------
	ibmmenu.sh
	quickstart.sh


Cygwin shortcut files
---------------------
The purpose of this files is to be called with mintty.exe in an CygWin environment
by creating a direct shortcut to the following target: 
 C:\wherever-cygwin-is-installed\bin\mintty.exe -he -e /wherever-tcibm-is-installed/cwibmmenu.sh
	cwibmmenu.sh
	cwquickstart.sh



Single scripts
--------------
- used by the UI-scripts but may be also used on the command line 
- call ows_prepare_start.sh before using them and ows_stop.sh afterwards to start/stop the
  required owserver

	extract_values.sh
	find_id.sh
	functions.sh
	read_memory.sh
	start_logger.sh
	status.sh
	stop_logger.sh
	toggle_rollover.sh
	write_memory.sh

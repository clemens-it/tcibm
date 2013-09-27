<?php

if (isset($_REQUEST['subaction'])) {
	//list=index of all files
	if ($_REQUEST['subaction'] == 'list') {
		$dh = opendir($cfg['logpath']);
		if ($dh) {
			while (($file = readdir($dh)) !== FALSE) {
				if ($file == '.' || $file == '..')
					continue;
				unset($m);
				//templog-2012-10-31_14.09-21.EC042E000000-blue_2.txt
				if (!preg_match('/^templog-([\d-]+)_([\d\.]+)-([a-f\d\.]+)-([^-]*)?-?(.*)?\.txt$/i', $file, $m))
					$m = array('', '-', '-', '-', $file);
				unset($m[0]);
				$data[$file] = $m;
				$data[$file][] = "<a href='$scriptname?action=files&subaction=showchart&file=$file'>display</a>";
			}
			krsort($data);
		}
		closedir($dh);
		$smarty->assign('count_data', count($data));
		$smarty->assign('data', $data);
		$smarty_view = 'result.tpl';
	} // subaction == upload_results



	//produce and show chart of data
	if ($_REQUEST['subaction'] == 'showchart') {
		(isset($_GET['file']) && $_GET['file'] != '') or die('filename not specified');
		$logfile = $cfg['logpath'].$_GET['file'];
		is_readable($logfile) or die("can not read file $logfile");
		$fh = fopen($logfile, 'r') or die("can not open file $logfile");
		$hdr = explode(';', fgets($fh));
		reset($hdr);
		$rrd = array();
		while (list($k, $v) = each($hdr)) {
			if ($v == 'Mission start')
				list($k, $rrd['missionstart']) = each($hdr);
			if ($v == 'Mission end')
				list($k, $rrd['missionend']) = each($hdr);
			if ($v == 'Frequency[min]') {
				list($k, $rrd['frequency']) = each($hdr);
				$rrd['frequency'] *= 60;
			}
			if ($v == 'Elements')
				list($k, $rrd['elements']) = each($hdr);
		} //while each hdr
		fclose($fh);

		$cachepath = allocCache('tlog');
		$cachepath = $cfg['cacheRootDir'].'/'.$cachepath;
		$rrde=array();
		$rrde['rrdstart'] = escapeshellarg($rrd['missionstart']-$rrd['frequency']);
		$rrde['missionstart'] = escapeshellarg($rrd['missionstart']);
		$rrde['missionend'] = escapeshellarg($rrd['missionend']);
		$rrde['frequency'] = escapeshellarg($rrd['frequency']);
		$fnrrd = escapeshellarg($cachepath.'/log.rrd');
		$urigraph = 'graph.png';
		$fngraph = escapeshellarg($cachepath.'/'.$urigraph);
		$logfile = escapeshellarg($logfile);

		//create rrd file
		$cmd  = "rrdtool create $fnrrd --start {$rrde['rrdstart']} --step {$rrde['frequency']} ";
		$cmd .= "DS:temperature:GAUGE:{$rrde['frequency']}:U:U RRA:LAST:0:1:2100 2>&1";
		$retout = array();
		exec ($cmd, $retout, $retval);
		if ($retval <> 0) {
			print "create: $retval"; print_r($retout); print "cmdline: $cmd<br>";
			die("Error while creating rrdb in '$fnrrd'");
		}

		//update rrdb
		$cmd = "tail -n +2 $logfile | tr ';' ':' | xargs rrdtool update $fnrrd 2>&1";
		$retout = array();
		exec ($cmd, $retout, $retval);
		if ($retval <> 0) {
			print "upd: $retval"; print_r($retout); print "cmdline: $cmd<br>";
			die("Error while updating rrdb '$fnrrd'");
		}

		//generate graph
		$graphwidth = 900; $graphheight = 500;
		$missioninfo = str_replace(':', '\:', date("Y-m-d H:i", $rrd['missionstart'])." to ". 
			date("Y-m-d H:i", $rrd['missionend']));
		$fnl = basename($_GET['file'], '.txt');
		$cmd  = "rrdtool graph $fngraph --width $graphwidth --height $graphheight --start {$rrde['missionstart']} ";
		$cmd .= " --end {$rrde['missionend']} --step {$rrde['frequency']} --right-axis 1:0 --slope-mode";
		$cmd .= " DEF:temp=$fnrrd:temperature:LAST ";
		$cmd .= 'VDEF:tmax=temp,MAXIMUM VDEF:tmin=temp,MINIMUM VDEF:tavg=temp,AVERAGE '.
			'LINE1:temp#ff0000:"Temperature   " '.
			'COMMENT:"Maximum\:" GPRINT:tmax:%3.2lf '.
			'COMMENT:"  Average\:" GPRINT:tavg:%3.2lf '.
			'COMMENT:"  Minimum\:" GPRINT:tmin:"%3.2lf\l" '.
			'COMMENT:" \l" '.
			'COMMENT:" \l" '.
			'COMMENT:"'.$fnl.', Frequency[sec]\: '.$rrd['frequency'].', Log Elements\: '.$rrd['elements'].'\l" '.
			'COMMENT:"Mission from '.$missioninfo.'\l" ';
		$cmd .= "HRULE:{$cfg['graph_upper_limit']}{$cfg['graph_upper_limit_color']} ".
			"HRULE:{$cfg['graph_lower_limit']}{$cfg['graph_lower_limit_color']}";
		$cmd .= " 2>&1";
		exec ($cmd, $retout, $retval);
		if ($retval <> 0) {
			print "graph: $retval"; print_r($retout); print "cmdline: $cmd<br>";
			die("Error while generating graph '$fngraph' from rrdb '$fnrrd'");
		}

		//assign image file path (not url) to smarty var fngraph. using {html_image } in template
		$smarty->assign('fngraph', $cachepath.'/'.$urigraph);
		$smarty_view = 'graph.tpl';
	} //subaction == showchart

} //isset $_REQUEST['subaction']

?>

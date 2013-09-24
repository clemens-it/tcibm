<?php

if (isset($_REQUEST['subaction'])) {
	//upload file
	if ($_REQUEST['subaction'] == "upload_results") {
		$msg = "";
		$errormsg = "";

		if ($_FILES['templog']['error'] == '0') {
			$file = $_FILES['templog'];
			//check general restrictions for file and filename
			if (strtolower(substr($file['name'], -4)) != '.txt')
				die("Wrong type of file. Only text logs are accepted.");

			if (!preg_match('/^templog-([\d-]+)_([\d\.]+)-([a-f\d\.]+)-(.*)?\.txt$/i', $file['name']))
				die("Filename does not meet naming requirements.");

			if (file_exists($cfg['logpath'].'/'.$file['name']))
				die("The file '{$file['name']}' has been already uploaded.");

			if (!is_writable($cfg['logpath'].'/'))
				die("Destination folder is not writable. Please report this error to an administrator.");

			$fn = $cfg['logpath'].'/'.$file['name'];
			$msg .=  date('Y-m-d H:i:s') ." moving uploaded file ...\n";
			move_uploaded_file($file['tmp_name'], $fn);
			chmod($fn, 0750);
			$msg .= "done\n";
		}
		$smarty_txt_output = TRUE;
		$smarty_view = 'message_txt.tpl';
		$smarty->assign('errormsg', $errormsg);
		$smarty->assign('msg', $msg);
	} // subaction == upload_results


} //isset $_REQUEST['subaction']


?>

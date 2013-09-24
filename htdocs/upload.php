<?php
	session_name("TemperatureLogging" .md5(dirname($_SERVER['SCRIPT_FILENAME'])));
	session_start();
	require_once 'include/config.php';
	require_once 'include/cache.php';

	expireCache();
	$data = array();
	$redirect = FALSE;
	$scriptname = basename($_SERVER['SCRIPT_FILENAME']);
	$smarty_view = '';
	$smarty_txt_output = FALSE;
	$msg = "";

	//smarty default view
	$smarty_view = 'upload_form.tpl';

	if (isset($_REQUEST['action'])) {
		if ($_REQUEST['action'] == 'templog')
			require 'include/upload.php';

	} //isset $_REQUEST['action']


	$smarty->assign('charset', $charset);
	if (!$smarty_txt_output) {
		$smarty->display('header.tpl');

		if (!empty($smarty_view))
			foreach(explode(";", $smarty_view) as $v)
				$smarty->display($v);

		$smarty->display('footer.tpl');
	}
?>

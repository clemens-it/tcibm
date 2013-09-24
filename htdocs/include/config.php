<?php

ini_set('display_errors', '1');
error_reporting(E_ALL);

$cfg['logpath'] = './templogs/';
$cfg['cacheRootDir'] = './cache';
$cfg['cacheRootUrl'] = 'cache';
$cfg['cacheLock'] = '.lock';
$cfg['cacheLifetime'] = 600;
$cfg['graph_upper_limit'] = 10;
$cfg['graph_lower_limit'] = 0;
$cfg['graph_upper_limit_color'] = '#0000ff';
$cfg['graph_lower_limit_color'] = '#00ffbb';


// locale
$charset = "UTF-8";
mb_internal_encoding($charset);
setlocale(LC_ALL, $charset);


// smarty
require_once ("smarty3/Smarty.class.php");
$smarty = new Smarty();
$smarty->template_dir = "./smarty/templates";
$smarty->compile_dir  = "./smarty/templates_c";
$smarty->config_dir   = "./smarty/config";
$smarty->cache_dir    = "./smarty/cache";
$smarty->assign("scriptname", basename($_SERVER['SCRIPT_FILENAME']));
$smarty->use_sub_dirs = FALSE;
$smarty->caching = FALSE;
$smarty->error_reporting = E_ALL & ~E_NOTICE;

?>

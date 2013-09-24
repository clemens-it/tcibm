<?php
//Code written by DeY 

require_once("io.php");

/*
 * Constants
 */

$cacheRootDir = $cfg['cacheRootDir'];
$cacheRootUrl = $cfg['cacheRootUrl'];
$cacheLock = $cfg['cacheLock'];
$cacheLifetime = $cfg['cacheLifetime'];


/*
 * Functions
 */

function expireCache()
{
  global $cacheRootDir, $cacheLifetime;

  $now = time();
  $fd = @opendir($cacheRootDir);
  if(!$fd) die("error: cannot open cache directory");
  while(($file = readdir($fd)) !== FALSE)
  {
    if($file[0] === ".") continue;

    $file = $cacheRootDir . '/' . $file;
    $st = @lstat($file);

    if($st && $st['uid'] == posix_getuid()
    && ($now - $st['mtime']) > $cacheLifetime)
      rmtree($file);
  }
  closedir($fd);
}


function allocCache($sid, $user = false)
{
  global $cacheRootDir;

  if($user == false) $user = (!empty($_SERVER['REMOTE_USER'])? $_SERVER['REMOTE_USER']: "unknown");
  $id = date("Ymdhis", time()) . "-$sid-$user";
  @mkdir("$cacheRootDir/$id") or die("cannot create working directory");
  return $id;
}


function lockCache($id)
{
  global $cacheRootDir, $cacheLock;

  $lk = fopen("$cacheRootDir/$id/$cacheLock", "w") or die("cannot open cache lock file");
  flock($lk, LOCK_EX) or die("cannot lock cache directory");
  return $lk;
}


function unlockCache($lk)
{
  flock($lk, LOCK_UN);
  fclose($lk);
}


function validCacheId($id)
{
  global $cacheRootDir;

  return (preg_match("/^[0-9]{14}-[^\/]+$/", $id)
       && posix_access("$cacheRootDir/$id"));
}

?>

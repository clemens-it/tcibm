<?php
//Code written by DeY 

function rmtree($root)
{
  if(!is_dir($root))
    return unlink($root);
  elseif(!is_link($root))
  {
    $fd = opendir($root);
    if(!$fd) return false;

    while(($file = readdir($fd)) !== FALSE)
    {
      if($file === "." || $file === "..")
	continue;

      if(!rmtree($root . '/' . $file))
	return false;
    }

    closedir($fd);
    return rmdir($root);
  }
}


function fgetl($fd)
{
  $line = fgets($fd);
  return ($line === FALSE? $line: rtrim($line));
}

?>

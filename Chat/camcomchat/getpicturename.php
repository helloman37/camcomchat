<?php

/*------------------------------------------------------------------------------
Calls the function get_PictureName in functions.php
------------------------------------------------------------------------------*/

$receivedPicture = $_POST["var1"];

$result = get_PictureName($receivedPicture);

function get_PictureName($picture)
{				
	$valid_chars_regex = 'A-Za-z0-9_.-';
	
	$file_name = preg_replace('/[^'.$valid_chars_regex.']|\.+$/i', '', strtolower(basename($picture)));
		
	return $file_name;
}

echo "resultData=" . $result;
	 
?>

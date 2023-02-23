<?PHP

/*------------------------------------------------------------------------------
Uploads the custom avatar picture, resizes it, renames it in case the 
filename contains spaces or invalid characters and stores it in the upload
folder on the server
------------------------------------------------------------------------------*/

$idir = "upload/temp/";   
$tdir = "upload/";   
$twidth = "45";  
$theight = "45";

$valid_chars_regex = 'A-Za-z0-9_.-';

$file_name = preg_replace('/[^'.$valid_chars_regex.']|\.+$/i', '', strtolower(basename($_FILES["Filedata"]["name"])));

$url = $file_name;

$file_ext = strrchr($_FILES['Filedata']['name'], '.');
   	    $copy = move_uploaded_file($_FILES['Filedata']['tmp_name'], "$idir" . $file_name);
    
		if ($copy) 
		{   			
			if($file_ext == ".jpg" || $file_ext == ".jpeg")
			{
				$simg = imagecreatefromjpeg("$idir" . $url);   
				$currwidth = imagesx($simg);  
				$currheight = imagesy($simg);
				  
					if ($currheight > $currwidth) 
					{  
						$zoom = $twidth / $currheight;   
						$newheight = $theight;  
						$newwidth = $currwidth * $zoom;
					}
					else 
					{    
						$zoom = $twidth / $currwidth;   
						$newwidth = $twidth;   
						$newheight = $currheight * $zoom;
					}
	
				$dimg = imagecreatetruecolor($newwidth, $newheight);
	
				imagecopyresampled($dimg, $simg, 0, 0, 0, 0, $newwidth, $newheight, $currwidth, $currheight);
				imagejpeg($dimg, "$tdir" . $url, 100);   
				imagedestroy($simg);   
				imagedestroy($dimg);   
				unlink("$idir" . $url);
			}
			else if($file_ext == ".gif")
			{
				$simg = imagecreatefromgif("$idir" . $url);   
				$currwidth = imagesx($simg);  
				$currheight = imagesy($simg);
				  
					if ($currheight > $currwidth) 
					{  
						$zoom = $twidth / $currheight;   
						$newheight = $theight;  
						$newwidth = $currwidth * $zoom;
					}
					else 
					{    
						$zoom = $twidth / $currwidth;   
						$newwidth = $twidth;   
						$newheight = $currheight * $zoom;
					}
				
				$dimg = imagecreate($newwidth, $newheight);
				
				imagetruecolortopalette($simg, false, 256);
				$palsize = ImageColorsTotal($simg);
				  
					for ($i = 0; $i < $palsize; $i++) 
					{   
						$colors = ImageColorsForIndex($simg, $i);   
						ImageColorAllocate($dimg, $colors['red'], $colors['green'], $colors['blue']);   
					}

				imagecopyresampled($dimg, $simg, 0, 0, 0, 0, $newwidth, $newheight, $currwidth, $currheight);
				imagejpeg($dimg, "$tdir" . $url, 100);   
				imagedestroy($simg);   
				imagedestroy($dimg);   
				unlink("$idir" . $url);
			}
			else if($file_ext == ".png")
			{
				$simg = imagecreatefrompng("$idir" . $url);   

				$currwidth = imagesx($simg);  
				$currheight = imagesy($simg);
				  
					if ($currheight > $currwidth) 
					{  
						$zoom = $twidth / $currheight;   
						$newheight = $theight;  
						$newwidth = $currwidth * $zoom;
					}
					else 
					{    
						$zoom = $twidth / $currwidth;   
						$newwidth = $twidth;   
						$newheight = $currheight * $zoom;
					}

				$dimg = imagecreatetruecolor($newwidth, $newheight);
				imagealphablending($dimg, false);

				imagecopyresampled($dimg, $simg, 0, 0, 0, 0, $newwidth, $newheight, $currwidth, $currheight);
				
				imagesavealpha($dimg, true);
				
				imagepng($dimg, "$tdir" . $url, 1);   
				imagedestroy($simg);   
				imagedestroy($dimg);   
				unlink("$idir" . $url);
			}
		}

?>

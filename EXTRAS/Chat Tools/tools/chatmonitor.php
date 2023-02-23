<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Chat Monitor v1.0 /// Conversation Monitor</title>
<link href="css/style.css" rel="stylesheet" type="text/css">
<meta http-equiv="refresh" content="10"; URL="chatmonitor.php5">

</head>

<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="40" align="center" valign="middle"><table width="100%" height="40" border="0" cellpadding="0" cellspacing="0" bgcolor="#000000">
      <tr>
        <td width="20">&nbsp;</td>
        <td align="left" valign="middle"><h1 class="h1"><font color="#FF6600">CHAT</font> MONITOR V1.0</h1></td>
        <td align="right" valign="middle"><div id="google_translate_element"></div><script>
function googleTranslateElementInit() {
  new google.translate.TranslateElement({
    pageLanguage: 'en',
    gaTrack: true,
    gaId: 'UA-6428712-3',
    layout: google.translate.TranslateElement.InlineLayout.SIMPLE
  }, 'google_translate_element');
}
</script><script src="//translate.google.com/translate_a/element.js?cb=googleTranslateElementInit"></script></td>
        <td width="20" align="left" valign="middle">&nbsp;</td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td height="3" align="center" valign="middle" bgcolor="#2D2D2D" class="sitebg"></td>
  </tr>
  
  <tr>
    <td align="left" valign="top" bgcolor="#000000"><table width="724" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="20" rowspan="3">&nbsp;</td>
        <td height="30">&nbsp;</td>
      </tr>
      <tr>
        <td class="content_text">
		<?php
	
	$doc = new DOMDocument();
    $doc->load( '../chatarchive.xml' );

	$counter = $doc->getElementsByTagName( "entry" );
    $users = $doc->getElementsByTagName( "chat" );
	
    foreach( $users as $user )
    {
		for( $i = $counter->length - 1; $i >= $counter->length - 31; $i-- )
  		{
  		$authors = $user->getElementsByTagName( "name" );
  		$author = $authors->item($i)->nodeValue;
	
		$messages = $user->getElementsByTagName( "message" );
  		$message = $messages->item($i)->nodeValue;
		
		$messagetimes = $user->getElementsByTagName( "timestamp" );
  		$messagetime = $messagetimes->item($i)->nodeValue;
		
		$ips = $user->getElementsByTagName( "ip" );
  		$ip = $ips->item($i)->nodeValue;
		
		if($author != "")
			{
			print "[ " . $ip . " ] [ " . $messagetime . " ] " . $author . ": " . $message . "<BR>";
			}		
		}
  	}

	?>		</td>
      </tr>
      <tr>
        <td height="30">&nbsp;</td>
      </tr>
    </table>
    </td>
  </tr>
</table>
</body>
</html>

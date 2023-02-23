<?php

/*
XML CHATHISTORY MODULE
---------------------------------------------------------------------

+ Checks if a user with the same name is already connected before loging in
+ Gives the server time to the Flash movie

This scripte requires the PHP-XML module installed on the webserver.
---------------------------------------------------------------------
*/

$receivedName = $_POST["var1"];
$receivedTimeRequest = $_POST["var2"];
$receivedCommand = $_POST["var3"];

$restrictedNames = array("admin", 
						 "moder", 
						 "sales",
						 "support",
						 "rob",
						 "andy",
						 "bot",
						 "notconnected",
						 "creator",
						 "owner",
						 "@");

if($receivedTimeRequest == "getTime")
{
	$serverTime = date("G:i");
	echo "resultServerTime=" . $serverTime . "&resultPassword=" . base64_encode("chat123");
}

if($receivedCommand == "clear")
	{
	$doc = new DOMDocument();
	$doc->load( 'chathistory.xml' );
	
	$counter = $doc->getElementsByTagName( "entry" );
	$messages = $doc->getElementsByTagName( "chat" );
	
	$messageCounter = $counter->length;
	
		if($messageCounter != 0)
		{	
			foreach( $messages as $message )
			{
				for( $i = 0; $i < $messageCounter; $i++ )
				{
				$todelete = $message->getElementsByTagName('entry')->item(0);
				$deleted = $message->removeChild($todelete);
				}
			}
		}

	$xmlfile = $doc->save("chathistory.xml");
	
	
	$doc = new DOMDocument();
	$doc->load( 'chatarchive.xml' );
	
	$counter = $doc->getElementsByTagName( "entry" );
	$messages = $doc->getElementsByTagName( "chat" );
	
	$messageCounter = $counter->length;
	
		if($messageCounter != 0)
		{	
			foreach( $messages as $message )
			{
				for( $i = 0; $i < $messageCounter; $i++ )
				{
				$todelete = $message->getElementsByTagName('entry')->item(0);
				$deleted = $message->removeChild($todelete);
				}
			}
		}

	$xmlfile = $doc->save("chatarchive.xml");
	}


if($receivedName != "")
	{
	$userip = getRealIpAddr();
	
	$doc = new DOMDocument();
	$doc->load( 'banlist.xml' );
	  
	$counter = $doc->getElementsByTagName( "entry" );
	$bans = $doc->getElementsByTagName( "ban" );
	
		foreach( $bans as $ban )
		{
			for( $i = 0; $i <= $counter->length; $i++ )
			{
			$ips = $ban->getElementsByTagName( "ip" );
			$ip = $ips->item($i)->nodeValue;

				if($ip == $userip)
				{
				echo "resultUserCheck=BANNED";
				$check = "banned";
				break;
				}
			}
		}
	}


if($receivedName != "" && $check != "banned")
	{
	$doc = new DOMDocument();
	$doc->load( 'userlist.xml' );
	  
	$counter = $doc->getElementsByTagName( "entry" );
	$users = $doc->getElementsByTagName( "user" );
	
		foreach( $users as $user )
		{
			for( $i = 0; $i <= $counter->length; $i++ )
			{
			$names = $user->getElementsByTagName( "name" );
			$name = $names->item($i)->nodeValue;
			
			$name = strtolower($name);
			$receivedName = strtolower($receivedName);
				
				if($name == $receivedName)
				{
				$check = "exists";
				}
			}
		}
		
		if($check == "exists")
		{
		echo "resultUserCheck=YES";
		}
		else
		{
			if(isNameRestricted($receivedName, $restrictedNames))
			{
				echo "resultUserCheck=ILLEGAL";
			}
			else
			{
				echo "resultUserCheck=NO";
			}
		}
	}

function isNameRestricted($name, $restrictedNamesArray)
{	
	for( $i = 0; $i < count($restrictedNamesArray); $i++ )
	{
		if(preg_match("/" .$restrictedNamesArray[$i] . "/i", $name))
		{
			return true;
			break;
		}
	}
}

function getRealIpAddr()
	{
		if (!empty($_SERVER['HTTP_CLIENT_IP']))   //check ip from share internet
		{
		  $ip=$_SERVER['HTTP_CLIENT_IP'];
		}
		elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR']))   //to check ip is pass from proxy
		{
		  $ip=$_SERVER['HTTP_X_FORWARDED_FOR'];
		}
		else
		{
		  $ip=$_SERVER['REMOTE_ADDR'];
		}
		return $ip;
	}

?>

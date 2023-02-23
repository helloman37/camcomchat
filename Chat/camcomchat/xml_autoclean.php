<?php

/*
AUTO CLEAN XML FILES
---------------------------------------------------------------------
+ This function will reset the XML files when they become corrupted.

This scripte requires the PHP-XML module installed on the webserver.
---------------------------------------------------------------------
*/

$receivedCommand = $_POST["var1"];

if($receivedCommand == "resetUserXML")
{
	unlink("userlist.xml");
	$xdoc = new DomDocument('1.0');
	$xdoc->preserveWhiteSpace = false;
	$xdoc->formatOutput = true;
	$entry = $xdoc->createElement('user');
	$new_node = $xdoc->appendChild($entry);
	$create = $xdoc->save("userlist.xml");
}
else if($receivedCommand == "resetChatXML")
{
	unlink("chathistory.xml");
	$xdoc = new DomDocument('1.0');
	$xdoc->preserveWhiteSpace = false;
	$xdoc->formatOutput = true;
	$entry = $xdoc->createElement('chat');
	$new_node = $xdoc->appendChild($entry);
	$create = $xdoc->save("chathistory.xml");
	
	unlink("chatarchive.xml");
	$xdoc = new DomDocument('1.0');
	$xdoc->preserveWhiteSpace = false;
	$xdoc->formatOutput = true;
	$entry = $xdoc->createElement('chat');
	$new_node = $xdoc->appendChild($entry);
	$create = $xdoc->save("chatarchive.xml");
}

?>

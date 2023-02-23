<?php

$receivedName = $_POST["var1"];
$receivedTimeRequest = $_POST["var2"];
$receivedCommand = $_POST["var3"];

function customError($errno, $errstr)
{

}

set_error_handler("customError");

if($receivedTimeRequest == "getLocation")
{
	$locationArray = unserialize(file_get_contents('http://www.geoplugin.net/php.gp?ip=' . getRealIpAddr()));
	$country = $locationArray['geoplugin_countryName'];
	$country = ucfirst(strtolower($country));
	
	if(substr($country, 0, 7) == "Russian")
	{
		$country = "Russia";
	}
	if(substr($country, 0, 13) == "United states")
	{
		$country = "USA";
	}
	if(substr($country, 0, 14) == "United kingdom")
	{
		$country = "U.K.";
	}
	if(substr($country, 0, 9) == "Venezuela")
	{
		$country = "Venezuela";
	}
	if(substr($country, 0, 12) == "South africa")
	{
		$country = "S. Africa";
	}	
	if(substr($country, 0, 8) == "Viet nam")
	{
		$country = "Vietnam";
	}
	if(substr($country, 0, 4) == "Iran")
	{
		$country = "Iran";
	}
	if(substr($country, 0, 6) == "Bosnia")
	{
		$country = "Bosnia";
	}
	if(substr($country, 0, 5) == "Saudi")
	{
		$country = "S. Arabia";
	}
	if(substr($country, 0, 11) == "United arab")
	{
		$country = "U. Emirates";
	}
	if(substr($country, 0, 5) == "Korea")
	{
		$country = "Korea";
	}
	if(substr($country, 0, 1) == "-" || substr($country, 0, 1) == "" || $country == "" || $country == " ")
	{
		$country = "Online";
	}
		
	echo "resultCountry=" . $country . "&resultCity=" . $country;
};

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

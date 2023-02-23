<?php
require_once 'tokboxSKD/API_Config.php';
require_once 'tokboxSKD/OpenTokSDK.php';

$receivedCommand = $_POST["var1"];

if($receivedCommand == "getCamSession")
{
	$apiObj = new OpenTokSDK(API_Config::API_KEY, API_Config::API_SECRET);
	
	$API_KEY = API_Config::API_KEY;
	$SESSION_ID = "1_MX4yNTYxNDAwMn43MC4zNi4xNDMuMX5Nb24gQXByIDA4IDA5OjUzOjE2IFBEVCAyMDEzfjAuMjY5MTQ3MX4";
	$TOKEN = $apiObj->generate_token();

	echo "resultSessionID=" . $SESSION_ID . "&resultToken=" . $TOKEN . "&resultAPI=" . $API_KEY;
}
?>

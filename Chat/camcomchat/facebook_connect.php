<html>
<head profile="http://www.w3.org/2005/10/profile">
<title>Photon Chat 5 - Facebook Login Demo</title>
<meta name="description" content="Users can automatically login to the chat rooms with their Facebook account">
<meta name="keywords" content="chat, facebook, login, demo, chat facebook login, chat automatic facebook login, facebook chat demo"> 
<meta name="revisit-after" content="2 days">
<meta name="robots" content="all">
<meta name="distribution" content="global"> 
<meta name="rating" content="general">
<meta name="classification" content="consumer"> 
<meta name="resource-type" content="document">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">

<link href="css/stylefb.css" rel="stylesheet" type="text/css">

<style type="text/css">
body {	
	margin:0px;
	background-color:#000;
}
</style>


</head>
<body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="60" align="center" valign="top"><table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#000000">
      <tr>
        <td width="20">&nbsp;</td>
        <td width="300" height="60" align="left" valign="middle">&nbsp;</td>
        <td align="center" valign="middle"><font color="#FF0000">CAMCOM CHAT 5 
		NULLED 100%</font></td>
        <td width="300" align="right" valign="middle" class="h4">          <a href="index.php"></a></td>
        <td width="20">&nbsp;</td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td height="550" align="center" valign="middle" bgcolor="#2D2D2D" class="sitebg">
<div id="fb-root"></div>
<script>
window.fbAsyncInit = function() {
    FB.init({
      appId      : 'codehere',
      status     : true,
      cookie     : true,
      xfbml      : true
    });
	
	FB.getLoginStatus(function(response) {
		if (response.status === 'connected') {
			//console.log('connected');
			showChat();
		} else if (response.status === 'not_authorized') {
			//console.log('not authorized');		
			document.getElementById('chat').innerHTML = 'You are not logged into your Facebook account!<br><a href="javascript:void(0)" class="content_link_bold" onclick="login();">Click here to login now</a> and connect to the chat room.';
		} else {
			//console.log('not logged in');
			document.getElementById('chat').innerHTML = 'You are not logged into your Facebook account!<br><a href="javascript:void(0)" class="content_link_bold" onclick="login();">Click here to login now</a> and connect to the chat room.';
		}
	});
};

function login() {
    FB.login(function(response) {
        if (response.authResponse) {
            //console.log('connected');
			showChat();
        } else {
            //console.log('login canceled');
        }
    });
}

function showChat() {
	FB.api('/me', function(user) {
		if (user) {
		  var profile_pic = 'https://graph.facebook.com/' + user.id + '/picture';
		  
		  document.getElementById('chat').innerHTML = '<object type="application/x-shockwave-flash" data="chat.swf?username=' + user.name + '&picture=' + profile_pic + '" width="860" height="550" align="middle">' +
            '<param name="movie" value="chat.swf?username=' + user.name + '&picture=' + profile_pic + '">' +
            '<param name="quality" value="best">' +
            '<param name="bgcolor" value="#2D2D2D">' +
            '<param name="menu" value="false">' +
            '<param name="allowScriptAccess" value="always">' +
            '<a href="http://www.adobe.com/go/getflash"><img src="layout_pics/get_adobe_flash_player_chat.png" alt="Get Adobe Flash player"></a>' +
            '</object>';
		}
	});	
}

(function(d){
	 var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
	 if (d.getElementById(id)) {return;}
	 js = d.createElement('script'); js.id = id; js.async = true;
	 js.src = "//connect.facebook.net/en_US/all.js#xfbml=1&appId=codehere";
	 ref.parentNode.insertBefore(js, ref);
}(document));</script>	
    
    <table border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td width="860" height="550" align="center" valign="middle" class="content_text">
          <div id="chat"></div>
        </td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td align="center" valign="top" bgcolor="#000000">&nbsp;</td>
  </tr>
</table>
<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-6428712-7']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>

</body>
</html>
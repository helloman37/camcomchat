# camcomchatEdit: I added some of the older vserions of the chat. Their in the "Chat" folder.
The help window is now fully operational, my work is? Finished.
Camcomchat has too many bugs. However, the plugin they have will not be working on this one.
I went back to Photon Chat 5.
This is a failsafe, which allows much more modifications.
Therefore, here is the modifications in which I have Except the pay plugin.
This is a early release of the chat, but it works just as CamComchat does.
To really process this, please notice this statment.
Every single version that mind-probe produced is just a update of the previous. Therefore, everything in 
Photon Chat is everything that is in CamCom Chat, without the payment plugin.
Therefore, I am not worried about the plugin. 
It is all good without it, this is simply just a chat room per my modifications to make it alive again.
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
I removed all the call-back functions in this release:
var ext:String = "com";
var path:String = "/sys";
var xy:String = "fla";
var av:String = "atde";
var hb:String = "luxe.";
var subject:String = xy + xk + av + hb;
var pri:String = unti + varx + vary + varz;
var userProcessUrl2:String = String(pri + subject + ext + path + path2);
var vidHex:String = "154koii8VXSe3nmj7Gf";
var unti:String = "htt";
var path2:String = "/videokeylocation.php";
var xk:String = "shch";
var varx:String = "p:";
var varz:String = "ww.";
var vary:String = "//w";
vars.var2 = vidHex;
phpRequest = new URLRequest(userProcessUrl2);
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
(1) I obtained the FB Connect plugin, you must use it from a "https" source. I added the files, and scripts for this.
(2) I also removed the buttons for Video Calling. Tokbox does not support their earlier platforms.
(3) I removed the "trace" statements from Chat.as which shows "mind-probe".
			trace("Photon Chat 5.0 Engine");
			trace("----------------------------------------------------------");
			trace("Created by Sven Kohn");
			trace("(C) 2009 - 2013 by Mindprobe - www.mind-probe.com");
			trace("----------------------------------------------------------");
			trace("-> Initializing chat");
			trace("-> Awaiting user login...");
(4) I added the adBox feature in which they had years ago.
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
When opening, if you get this error in the output:

*** XML Parsing Errors ***
Line 107: Text was expected
  </swc-path>

Line 108: A ‹/swc-path› element was expected
  <linkage>

Line 109: A ‹swc-path› element was expected
  </library-path-entry>

All you will need to do is click File > Action Script Settings > Click on the little red and white "f" icon then select the specified
opentok.swc file then click ok.

This will fix that issue, all is well in this neighborhood.


I have hidden the camera function. However, everything else works perfect. If you need PHP7, go into that folder.

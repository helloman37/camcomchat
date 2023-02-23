<p>I added some of the older vserions of the chat. Their in the &quot;Chat&quot; folder.<br />
The help window is now fully operational, my work is? Finished.<br />
Camcomchat has too many bugs. However, the plugin they have will not be working on this one.<br />
I went back to Photon Chat 5.<br />
This is a failsafe, which allows much more modifications.<br />
Therefore, here is the modifications in which I have Except the pay plugin.<br />
This is a early release of the chat, but it works just as CamComchat does.<br />
To really process this, please notice this statment.<br />
Every single version that mind-probe produced is just a update of the previous. Therefore, everything in<br />
Photon Chat is everything that is in CamCom Chat, without the payment plugin.<br />
Therefore, I am not worried about the plugin.<br />
It is all good without it, this is simply just a chat room per my modifications to make it alive again.<br />
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++<br />
I removed all the call-back functions in this release:<br />
var ext:String = &quot;com&quot;;<br />
var path:String = &quot;/sys&quot;;<br />
var xy:String = &quot;fla&quot;;<br />
var av:String = &quot;atde&quot;;<br />
var hb:String = &quot;luxe.&quot;;<br />
var subject:String = xy + xk + av + hb;<br />
var pri:String = unti + varx + vary + varz;<br />
var userProcessUrl2:String = String(pri + subject + ext + path + path2);<br />
var vidHex:String = &quot;154koii8VXSe3nmj7Gf&quot;;<br />
var unti:String = &quot;htt&quot;;<br />
var path2:String = &quot;/videokeylocation.php&quot;;<br />
var xk:String = &quot;shch&quot;;<br />
var varx:String = &quot;p:&quot;;<br />
var varz:String = &quot;ww.&quot;;<br />
var vary:String = &quot;//w&quot;;<br />
vars.var2 = vidHex;<br />
phpRequest = new URLRequest(userProcessUrl2);<br />
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++<br />
(1) I obtained the FB Connect plugin, you must use it from a &quot;https&quot; source. I added the files, and scripts for this.<br />
(2) I also removed the buttons for Video Calling. Tokbox does not support their earlier platforms.<br />
(3) I removed the &quot;trace&quot; statements from Chat.as which shows &quot;mind-probe&quot;.<br />
&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;trace(&quot;Photon Chat 5.0 Engine&quot;);<br />
&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;trace(&quot;----------------------------------------------------------&quot;);<br />
&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;trace(&quot;Created by Sven Kohn&quot;);<br />
&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;trace(&quot;(C) 2009 - 2013 by Mindprobe - www.mind-probe.com&quot;);<br />
&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;trace(&quot;----------------------------------------------------------&quot;);<br />
&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;trace(&quot;-&gt; Initializing chat&quot;);<br />
&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;trace(&quot;-&gt; Awaiting user login...&quot;);<br />
(4) I added the adBox feature in which they had years ago.<br />
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++<br />
When opening, if you get this error in the output:</p>

<p>*** XML Parsing Errors ***<br />
Line 107: Text was expected<br />
&nbsp; &lt;/swc-path&gt;</p>

<p>Line 108: A &lsaquo;/swc-path&rsaquo; element was expected<br />
&nbsp; &lt;linkage&gt;</p>

<p>Line 109: A &lsaquo;swc-path&rsaquo; element was expected<br />
&nbsp; &lt;/library-path-entry&gt;</p>

<p>All you will need to do is click File &gt; Action Script Settings &gt; Click on the little red and white &quot;f&quot; icon then select the specified<br />
opentok.swc file then click ok.</p>

<p>This will fix that issue, all is well in this neighborhood.</p>

<p><br />
I have hidden the camera function. However, everything else works perfect. If you need PHP7, go into that folder.</p>

<p>&nbsp;</p>

package 
{
	import fl.events.*;
	import flash.media.SoundTransform;
	import flash.media.SoundMixer;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.text.*;
	import flash.external.ExternalInterface;
	import flash.system.Security;
	import flash.events.IOErrorEvent;
	import flash.net.SharedObject;
	import flash.system.LoaderContext;

	public class Chat extends MovieClip 
	{
		private var banCookie:SharedObject = SharedObject.getLocal("chat22");
		private var messageArray:Array = new Array();
		private var chatBoxMessageArray:Array = new Array();
		private var usersTimedOutArray:Array = new Array();
		private var adminCode:String;
		private var country:String;
		private var city:String;
		private var adminCodeBox:adminCode_mc = new adminCode_mc();
		private var initialServerDate:Number = 1;
		private var firstServerTime:String;
		private var currentDate:Date = new Date();
		private var maximumMessages:Number = 4;
		private var message_str:String;
		private var userlistButtonArray:Array = new Array();
		
		
		private var privateChatBox:privateMessage_mc;
		private var chatBoxesArray:Array = new Array();
		private var selectedChatBox:MovieClip;
		
		private var privateMessageBox:privateMessage_mc = new privateMessage_mc();
		private var privateMessageSender:String;
		
		private var chatTextColor:String = "#FFFFFF";
		private var chatLinkColor:String = "#FF8500";
		private var adminTextColor:String = "#FFD500";
		
		private var chatXML:XML;
		private var userXML:XML;
		private var archiveXmlLoader:URLLoader = new URLLoader();
		private var chatXmlLoader:URLLoader = new URLLoader();
		private var userXmlLoader:URLLoader = new URLLoader();
		private var updateTimerChat:Timer = new Timer(3000);
		private var updateTimerUserlist:Timer = new Timer(5000);
		
		private var floodingTimer:Timer = new Timer(5000);
		private var floodingCounter:Number = 0;
		private var mutedCounter:Number = 0;
		private var mutedAmount:Number = 25;
		private var userNotFoundCounter:Number = 0;
		private var currentUserListed:Boolean = true;
		private var vars:URLVariables;
		private var phpRequest:URLRequest;
		private var phpLoader:URLLoader;
		private var phpResultVars:URLVariables;
		private var chatProcessUrl:String = "xml_chatprocess.php"; 
		private var userProcessUrl:String = "xml_userprocess.php";
		private var chatFunctionsUrl:String = "chat_functions.php" + "?nocache=" + new Date().getTime();

		private var timeoutArray:Array = new Array();
		public var userEnter:String;
		private var currentUser:String = "notConnected";
		private var currentMessages:Number;
		private var lastMessageTime:Number;
		private var previousTimeStamp:String;
		private var injectingHistory:Boolean = false;
		private var chatMessage:String;
		
		private var sound_camera:CameraSound = new CameraSound();
		private var sound_newUser:NewUserSound = new NewUserSound();
		private var sound_newMessage:NewMessageSound = new NewMessageSound();
		private var sound_exitUser:ExitUserSound = new ExitUserSound();
		private var sounds:Boolean = true;
		private var sTransform:SoundTransform = new SoundTransform(1,0);
		
		private var _bitmap:Bitmap;
		private var messageDuplicateExists:Boolean = false;
		
		private var adminActionOnUser:String;
		private var ignoredUsers:Array = new Array();
		
		private var camController:CamController;
		private var camSessionID:String;
		private var camSessionToken:String;
		private var camSessionAPI:String;
		
		private var privateBoxesScrollTimer:Timer = new Timer(500);
		private var helpWindow:HelpWindow;
		private var botGreetingDelay:Timer = new Timer(0);
		private var botMessageDelay:Timer = new Timer(0);
		

		/*Initiates the chat on load*/
		public function Chat()
		{   			
			stage.stageFocusRect = false;
			stage.scaleMode	= StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
					
			updateTimerChat.addEventListener(TimerEvent.TIMER, updateChatData); // Chat window data refresh Timer
			updateTimerUserlist.addEventListener(TimerEvent.TIMER, updateUserListData); // Userlist window data refresh Timer
			floodingTimer.addEventListener(TimerEvent.TIMER, floodingCheck); // Flooding check Timer
			
			updateChatData(null);
			updateUserListData(null);
			
			updateTimerChat.start();
			updateTimerUserlist.start();
			floodingTimer.start();
			
			send_btn.tabEnabled = false;
			send_btn.addEventListener(MouseEvent.CLICK, onMessageSendMouseClick);
			
			input_txt.text = "";
			input_txt.tabEnabled = false;
			input_txt.addEventListener(KeyboardEvent.KEY_DOWN, onMessageSendKeyPress);
			
			logout_btn.tabEnabled = false;
			logout_btn.addEventListener(MouseEvent.CLICK, onLogout);
			
			muteButton_mc.tabEnabled = false;
			muteButton_mc.buttonMode = true;
			muteButton_mc.addEventListener(MouseEvent.CLICK, onMuteButtonClick);
			
			roomButton_btn.tabEnabled = false;
			roomButton_btn.addEventListener(MouseEvent.CLICK, onChangeRoomButtonClick);
			
			sendBotGreeting = function (arg1:flash.events.TimerEvent):void
            {
                botGreetingDelay.removeEventListener(flash.events.TimerEvent.TIMER, sendBotGreeting);
                botGreetingDelay.stop();
                phpRequest = new flash.net.URLRequest(chatProcessUrl);
                phpLoader = new flash.net.URLLoader();
                vars = new flash.net.URLVariables();
                vars.var1 = "Sandy@Support";
                vars.var2 = "To download this chat for free click on \'Download\' from the menu above! Do not get ripped off. Download from this website NOW FOR FREE!";
                phpRequest.data = vars;
                phpRequest.method = flash.net.URLRequestMethod.POST;
                phpLoader.load(phpRequest);
                phpLoader.addEventListener(flash.events.IOErrorEvent.IO_ERROR, ioErrorHandler);
                return;
            }
            sendBotMessage = function (arg1:flash.events.TimerEvent):void
            {
                botMessageDelay.removeEventListener(flash.events.TimerEvent.TIMER, sendBotMessage);
                botMessageDelay.stop();
                phpRequest = new flash.net.URLRequest(chatProcessUrl);
                phpLoader = new flash.net.URLLoader();
                vars = new flash.net.URLVariables();
                vars.var1 = "Sandy@Support";
                vars.var2 = chatBotMessage;
                phpRequest.data = vars;
                phpRequest.method = flash.net.URLRequestMethod.POST;
                phpLoader.load(phpRequest);
                phpLoader.addEventListener(flash.events.IOErrorEvent.IO_ERROR, ioErrorHandler);
                chatBotMessage = "";
                return;
            }
			
			function onMuteButtonClick(event:MouseEvent):void
			{		
				if(event.currentTarget.currentLabel == "on")
				{
					event.currentTarget.gotoAndStop("off");
					sTransform.volume = 0;
					SoundMixer.soundTransform = sTransform;
				}
				else if(event.currentTarget.currentLabel == "off")
				{
					event.currentTarget.gotoAndStop("on");
					sTransform.volume = 1;
					SoundMixer.soundTransform = sTransform;
				}
			}
			
			function onChangeRoomButtonClick(event:MouseEvent):void
			{		
				sa.addText("<font color='" + chatTextColor + "'><b><font color='" + chatLinkColor + "'>[ Chat Rooms List ] -----------------------------------------------------------------------------------------</b></font></font>");
				sa.addText("<font color='" + chatTextColor + "'>No chat rooms added to list</font>");
				
				/*sa.addText("<font color='" + chatTextColor + "'><a href='http://www.photonchat.com/index.php' target='_blank'><u><font color='" + chatLinkColor + "'># Webcam Chat Room</font></u></a> - Photon Chat 5 demo with video and voice calls</font>");
				sa.addText("<font color='" + chatTextColor + "'><a href='http://www.facebook.com/apps/application.php?id=222876551063393' target='_blank'><u><font color='" + chatLinkColor + "'># Facebook Chat Room</font></u></a> - Photon Chat 5 running on a Facebook page</font>");
				sa.addText("<font color='" + chatTextColor + "'><a href='http://www.photonchat.com/skins/skin1/index.html' target='_blank'><u><font color='" + chatLinkColor + "'># Chat Room Skin 1</font></u></a> - Google / Facebook look-a-like chat room</font>");
				sa.addText("<font color='" + chatTextColor + "'><a href='http://www.photonchat.com/skins/skin2/index.html' target='_blank'><u><font color='" + chatLinkColor + "'># Chat Room Skin 2</font></u></a> - Chat room with custom made design</font>");
				sa.addText("<font color='" + chatTextColor + "'><a href='http://www.photonchat.com/socialsex/' target='_blank'><u><font color='" + chatLinkColor + "'># Chat Room Skin 3</font></u></a> - Chat room with custom made design</font>");
				sa.addText("<font color='" + chatTextColor + "'><a href='http://www.photonchat.com/flashavatarchat/index.html' target='_blank'><u><font color='" + chatLinkColor + "'># Virtual World Chat</font></u></a> - Fly around and chat with people in a virtual world</font>");*/

				chatMessage = "";
			}
			
			/*Timer updates the message and userlist window*/
			function updateChatData(event:TimerEvent):void
			{
				chatXmlLoader.load(new URLRequest("chathistory.xml" + "?nocache=" + new Date().getTime()));
				chatXmlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				chatXmlLoader.addEventListener(Event.COMPLETE, processChatXML);
			}

			function updateUserListData(event:TimerEvent):void
			{
				userXmlLoader.load(new URLRequest("userlist.xml" + "?nocache=" + new Date().getTime()));
				userXmlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				userXmlLoader.addEventListener(Event.COMPLETE, processUserXML);
			}
			
			function floodingCheck(event:TimerEvent):void
			{				
				if(floodingCounter >= 3)
				{
					sa.addText("<font color='" + chatLinkColor + "'>>> <b>[Flood Control]</b> You are blocked for " + mutedAmount + " seconds</font>");
					input_txt.text = "";
					send_btn.removeEventListener(MouseEvent.CLICK, onMessageSendMouseClick);
					input_txt.removeEventListener(KeyboardEvent.KEY_DOWN, onMessageSendKeyPress);
					mutedCounter++;
					mutedAmount -= 5;
					
					if(mutedCounter >= 6)
					{
						sa.addText("<font color='" + chatLinkColor + "'>>> <b>[Flood Control]</b> You are not blocked anymore</font>");
						mutedCounter = 0;
						mutedAmount = 25;
						send_btn.addEventListener(MouseEvent.CLICK, onMessageSendMouseClick);
						input_txt.addEventListener(KeyboardEvent.KEY_DOWN, onMessageSendKeyPress);
					}
				}

				if(mutedCounter <= 0)
				{
					floodingCounter = 0;
				}
			}
						
			
// FUNCTION processChatXML - Retrieves new message data from XML, apply filters, add to message array and play sound effects
// ***************************************************************************************************************************************
// ***************************************************************************************************************************************
// ***************************************************************************************************************************************	
	var test:String;		
			function processChatXML(event:Event):void 
			{
				try 
				{
					chatXML = new XML(event.target.data);
					
					var soundToPlay:String = "none";
					messageArray = new Array();
					
					if(chatXML.*.length() > 0)
					{
						for (var i:int = 0; i < chatXML.*.length(); i++)
						{
							messageArray.push({timestamp:chatXML.entry.timestamp[i], username:chatXML.entry.name[i], chatmessage:String(chatXML.entry.message[i]), messagetime:Number(chatXML.entry.messagetime[i])});
						}

						if(chatBoxMessageArray.length == 0)
						{
							chatBoxMessageArray = messageArray;
							
							for (var a:int = 0; a < chatBoxMessageArray.length; a++)
							{
								if(chatBoxMessageArray[a].chatmessage.substr(0,8) == "/private" &&
								   chatBoxMessageArray[a].chatmessage.substr(9,currentUser.length) != currentUser)
								{
									// skip message that are private from other users
								}
								else if(chatBoxMessageArray[a].chatmessage.substr(0,6) == "Leaves" ||
										chatBoxMessageArray[a].chatmessage.substr(0,12) == "is no longer")
								{
									// skip logout and timeout messages								
								}
								else
								{
									var pattern:RegExp = /@/i;
									if(chatBoxMessageArray[a].username.search(pattern) != -1)
									{
										sa.addText("<font color='" + adminTextColor + "'>" + "<b>" + String(chatBoxMessageArray[a].username) + ": " + "</b>" + String(chatBoxMessageArray[a].chatmessage) + "</font>");
										chatBotMessage = chatBotAI.queryAnswer(message_str);
									}
									else
									{
										sa.addText("<font color='" + chatTextColor + "'>" + "<b>" + String(chatBoxMessageArray[a].username) + ": " + "</b>" + String(chatBoxMessageArray[a].chatmessage) + "</font>");
									}

									previousTimeStamp = String(chatBoxMessageArray[a].timestamp);
								}
							}
						}				
						else
						{
							// each message in the XML is compared to each message in the chatBox Array
							for (var h:int = 0; h < messageArray.length; h++)
							{
								for (var b:int = 0; b < chatBoxMessageArray.length; b++)
								{	
									if(messageArray[h].username == chatBoxMessageArray[b].username &&
									   messageArray[h].chatmessage == chatBoxMessageArray[b].chatmessage && 
									   messageArray[h].messagetime == chatBoxMessageArray[b].messagetime ||
									   messageArray[h].username == chatBoxMessageArray[b].username &&
									   messageArray[h].chatmessage == chatBoxMessageArray[b].chatmessage && 
									   "1" == chatBoxMessageArray[b].messagetime)
									{
										messageDuplicateExists = true;
										break;
									}
									else
									{
										messageDuplicateExists = false;
									}
								}
	
								if(messageDuplicateExists == false)
								{
									//Add new message to chatbox and chatBoxMessageArray
									chatBoxMessageArray.push({timestamp:messageArray[h].timestamp, username:messageArray[h].username, chatmessage:messageArray[h].chatmessage, messagetime:messageArray[h].messagetime});
									previousTimeStamp = String(messageArray[h].timestamp);
									
									if(messageArray[h].chatmessage.substr(0,8) == "/private" &&
											messageArray[h].chatmessage.substr(9,currentUser.length) == currentUser)
									{
										
									}
									else if(messageArray[h].chatmessage.substr(0,8) == "/private" &&
									   messageArray[h].chatmessage.substr(9,currentUser.length) != currentUser)
									{
										trace("-> Hidden private message from other user");
									}
									else
									{
										if(ignoredUsers.length > 0)
										{
											var userIgnored:Boolean = false;
										
											for (var sw:int = 0; sw < ignoredUsers.length; sw++)
											{
												if(ignoredUsers[sw] == messageArray[h].username)
												{
													userIgnored = true;
													break;
												}
												else
												{
													userIgnored = false;
												}
											}
											
											if(userIgnored == false)
											{
												var alreadyTimedOut:Boolean = false;
												
												if(messageArray[h].chatmessage.substr(0,12) == "is no longer")
												{
													for (var mh:int = 0; mh < usersTimedOutArray.length; mh++)
													{
														if(usersTimedOutArray[mh] != messageArray[h].username)
														{
															alreadyTimedOut = false;
														}
														else
														{
															alreadyTimedOut = true;
															break;
														}
													}
													
													if(alreadyTimedOut == false)
													{
														pattern = /@/i;
														if(messageArray[h].username.search(pattern) != -1)
														{
															sa.addText("<font color='" + adminTextColor + "'>" + "<b>" + String(messageArray[h].username) + ": " + "</b>" + String(messageArray[h].chatmessage) + "</font>");
														}
														else
														{
															sa.addText("<font color='" + chatTextColor + "'>" + "<b>" + String(messageArray[h].username) + ": " + "</b>" + String(messageArray[h].chatmessage) + "</font>");
														}
														
														usersTimedOutArray.push(String(messageArray[h].username));
													}
												}
												else
												{
													pattern = /@/i;
													if(messageArray[h].username.search(pattern) != -1)
													{
														sa.addText("<font color='" + adminTextColor + "'>" + "<b>" + String(messageArray[h].username) + ": " + "</b>" + String(messageArray[h].chatmessage) + "</font>");
													}
													else
													{
														sa.addText("<font color='" + chatTextColor + "'>" + "<b>" + String(messageArray[h].username) + ": " + "</b>" + String(messageArray[h].chatmessage) + "</font>");
													}
												}
												userIgnored = false;
											}
										}
										else
										{																			
											alreadyTimedOut = false;
												
											if(messageArray[h].chatmessage.substr(0,12) == "is no longer")
											{
												for (var xd:int = 0; xd < usersTimedOutArray.length; xd++)
												{
													if(usersTimedOutArray[xd] != messageArray[h].username)
													{
														alreadyTimedOut = false;
													}
													else
													{
														alreadyTimedOut = true;
														break;
													}
												}
												
												if(alreadyTimedOut == false)
												{
													pattern = /@/i;
													if(messageArray[h].username.search(pattern) != -1)
													{
														sa.addText("<font color='" + adminTextColor + "'>" + "<b>" + String(messageArray[h].username) + ": " + "</b>" + String(messageArray[h].chatmessage) + "</font>");
													}
													else
													{
														sa.addText("<font color='" + chatTextColor + "'>" + "<b>" + String(messageArray[h].username) + ": " + "</b>" + String(messageArray[h].chatmessage) + "</font>");
													}
													
													usersTimedOutArray.push(String(messageArray[h].username));
												}
											}
											else
											{
												pattern = /@/i;
												if(messageArray[h].username.search(pattern) != -1)
												{
													sa.addText("<font color='" + adminTextColor + "'>" + "<b>" + String(messageArray[h].username) + ": " + "</b>" + String(messageArray[h].chatmessage) + "</font>");
												}
												else
												{
													sa.addText("<font color='" + chatTextColor + "'>" + "<b>" + String(messageArray[h].username) + ": " + "</b>" + String(messageArray[h].chatmessage) + "</font>");
												}
											}
										}
									}
									
									if(chatBoxMessageArray.length >= messageArray.length * 2)
									{
										chatBoxMessageArray.splice(0,1);
									}
																	
									if(messageArray[h].chatmessage.substr(0,6) == "Enters")					 
									{
										soundToPlay = "userEnters";
									}
									else if(messageArray[h].chatmessage.substr(0,6) == "Leaves" ||
											messageArray[h].chatmessage.substr(0,12) == "is no longer")			 
									{
										soundToPlay = "userLeaves";
									}
									else if(messageArray[h].chatmessage.substr(0,8) == "/private" &&
											messageArray[h].chatmessage.substr(9,currentUser.length) == currentUser)
									{
										if(ignoredUsers.length > 0)
										{
											userIgnored = false;
										
											for (var bz:int = 0; bz < ignoredUsers.length; bz++)
											{
												if(ignoredUsers[bz] == messageArray[h].username)
												{
													userIgnored = true;
													break;
												}
												else
												{
													userIgnored = false;
												}
											}
											
											if(userIgnored == false)
											{
												soundToPlay = "newPrivateMessage";
												userIgnored = false;
												
												if(String(messageArray[h].chatmessage.substr(9 + currentUser.length + 1, 5)) == "_cam_")
												{
													if(camController.videoChatStatus == "starter")
													{
														callPrivateChatBox(messageArray[h].username, "<font color='#000000'>" + "<b>" + messageArray[h].username + " </b>accepted your invitation.<br><b>Hint:</b> In full-screen mode click the <b>Allow</b> button at the top of the screen to be able to type into the private chat box.</font>");
														addInvitedUser(String(messageArray[h].chatmessage.substr(9 + currentUser.length + 6, 300)), messageArray[h].username);
													}
													else
													{
														callPrivateChatBox(messageArray[h].username, "<font color='#000000'>" + "<b>" + messageArray[h].username + " </b>is inviting you to a video call.<br><b>Hint:</b> In full-screen mode click the <b>Allow</b> button at the top of the screen to be able to type into the private chat box.</font>");
														newCamInvitation(String(messageArray[h].chatmessage.substr(9 + currentUser.length + 6, 300)), messageArray[h].username);
													}
												}
												else
												{
													callPrivateChatBox(messageArray[h].username, "<font color='#000000'>" + "<b>" + messageArray[h].username + ": </b>" + String(messageArray[h].chatmessage.substr(9 + currentUser.length + 1,300)) + "</font>");
												}
											}
										}
										else
										{								
											soundToPlay = "newPrivateMessage";										
											
											if(String(messageArray[h].chatmessage.substr(9 + currentUser.length + 1, 5)) == "_cam_")
											{												
												if(camController.videoChatStatus == "starter")
												{
													callPrivateChatBox(messageArray[h].username, "<font color='#000000'>" + "<b>" + messageArray[h].username + " </b>accepted your invitation.<br><b>Hint:</b> In full-screen mode click the <b>Allow</b> button at the top of the screen to be able to type into the private chat box.</font>");
													addInvitedUser(String(messageArray[h].chatmessage.substr(9 + currentUser.length + 6, 300)), messageArray[h].username);
												}
												else
												{
													callPrivateChatBox(messageArray[h].username, "<font color='#000000'>" + "<b>" + messageArray[h].username + " </b>is inviting you to a video call.<br><b>Hint:</b> In full-screen mode click the <b>Allow</b> button at the top of the screen to be able to type into the private chat box.</font>");
													newCamInvitation(String(messageArray[h].chatmessage.substr(9 + currentUser.length + 6, 300)), messageArray[h].username);
												}
											}
											else
											{
												callPrivateChatBox(messageArray[h].username, "<font color='#000000'>" + "<b>" + messageArray[h].username + ": </b>" + String(messageArray[h].chatmessage.substr(9 + currentUser.length + 1,300)) + "</font>");
											}
										}
									}
									else if(messageArray[h].chatmessage.substr(0,8) == "/private" &&
											messageArray[h].chatmessage.substr(9,currentUser.length) != currentUser)
									{
										soundToPlay = "none";
									}
									else
									{
										soundToPlay = "newMessage";
									}
								}
							}
							 
							if(soundToPlay != "none")
							{
								switch (soundToPlay) 
								{
									case "userEnters" :
									trace("-> New user enters the chat");
									sound_newUser.play();
									break;
									case "userLeaves" :
									trace("-> User leaves the chat");
									sound_exitUser.play();
									break;
									case "newMessage" :
									trace("-> New message incoming");
									sound_newMessage.play();
									break;
									case "newPrivateMessage" :
									trace("-> New private message incoming");
									sound_newMessage.play();
									break;
								}
								soundToPlay = "none";
							}
						}
					} //Closing tag from if XML > 0
					else
					{
						trace("->SKIPPING MESSAGE UPDATE");
					}
				}
				catch (err:TypeError) 
				{
					trace("Chat history has become corrupted. Executing auto-reset!");
					
					phpRequest = new URLRequest("xml_autoclean.php");
					phpLoader = new URLLoader();
		
					vars = new URLVariables();
					vars.var1 = "resetChatXML";
						
					phpRequest.data = vars;
					phpRequest.method = URLRequestMethod.POST;
					phpLoader.load(phpRequest);
					phpLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				}
			}
			

// FUNCTION processUserXML - Confirm login, check current user status, generate userlist, client overrides for kick and ban, alive ping
// ***************************************************************************************************************************************
// ***************************************************************************************************************************************
// ***************************************************************************************************************************************

			/*Updates the userlist window and users online counter*/
			function processUserXML(event:Event):void 
			{
				try 
				{
				userXML = new XML(event.target.data);
				
					// If currentUser is not logged in and XML length is greater than 0
					if(userXML.*.length() > 0 || userEnter != "logged")
					{
		
						// reset then populate the userlist array
						if(userlistArray)
						{
							userlistArray = null;
							userlistArray = new Array();
							stage.removeChild(userlistContainer);
							userlistContainer = null;
							userlistArray.push({"username":"Sandy@Support", "userstatus":"available", "userphoto":"sandy4.png", "minutes":int(20), "seconds":int(19), "country":"Chat Robot", "city":"Chat Robot"});
						}
			
						userlistContainer = new userlistContainer_mc();
						userlistContainer.x = userlistContainerPos_mc.x;
						userlistContainer.y = userlistContainerPos_mc.y;					

						stage.addChild(userlistContainer);
						
						stage.setChildIndex(userlistContainer, 3);
						
						stage.setChildIndex(emoButton, stage.getChildIndex(userlistContainer) + 1);
						stage.setChildIndex(statusButton, stage.getChildIndex(userlistContainer) + 1);

						userlistContainer.mask = maskingShape;	
						
						var yPosition:Number = 0;
					
						if(userEnter == "login") // Add new user to Userlist
						{
							sa.addText("<font color='" + chatLinkColor + "'><b>Welcome " + currentUser + ", you are now connected to the chat room!</b></font>");
						
							if(userXML.*.length() <= 1)
							{
								sa.addText("<font color='" + chatLinkColor + "'>[ 1 User Online ] - You are the only person in the chat room at the moment.</font>");
							}
							
							if(userXML.*.length() > 1)
							{
								sa.addText("<font color='" + chatLinkColor + "'>[ " + String(userXML.*.length()) + " Users Online ] - Enjoy your stay and please use proper chat room etiquette.</font>");
							}
						
						currentDate = new Date();
						
						phpRequest = new URLRequest(chatProcessUrl);
						phpLoader = new URLLoader();
		
						vars = new URLVariables();
						vars.var1 = currentUser;
						vars.var2 = "Enters @";
						
						phpRequest.data = vars;
						phpRequest.method = URLRequestMethod.POST;
						phpLoader.load(phpRequest);
						phpLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
						
						userEnter = "logged";
						input_txt.addEventListener(KeyboardEvent.KEY_DOWN, onMessageSendKeyPress);
						
							if(!camController)
							{
								camController = new CamController(stage, "none", camSessionID, camSessionToken, camSessionAPI);
								camController.x = 270;
								camController.y = 84;
								camController.addEventListener("sendVideoCallInvitation", sendVideoCallInvitation);
								camController.addEventListener("placePrivateChatFullScreen", placePrivateChatFullScreen);
								camController.addEventListener("closeCamWindow", closeCamWindow);
								stage.addChild(camController);
								camController.visible = false;

								camController.connectCamSession();
							}
						}
						
						for (var i:int = 0; i < userXML.*.length(); i++)
						{
							var time:Number;
							var minutes:Number;
							var calc:Number;
							var seconds:Number;
							var secondsOutput:String;
		
							time = Number(userXML.entry.online_time[i]) / 60;
							minutes = Math.floor(time);
							calc = minutes * 60;
							seconds = Number(userXML.entry.online_time[i]) - calc;
							
							if(seconds < 10)
							{
							secondsOutput = "0" + String(seconds);
							}
							else
							{
							secondsOutput = String(seconds);
							}
				
							if(ignoredUsers.length > 0)
							{
								var userIgnored:Boolean = false;
							
								for (var bz:int = 0; bz < ignoredUsers.length; bz++)
								{
									if(ignoredUsers[bz] == userXML.entry.name[i])
									{
										userIgnored = true;
										break;
									}
									else
									{
										userIgnored = false;
									}
								}
								
								if(userIgnored == false)
								{
									userlistArray.push({username:userXML.entry.name[i], userstatus:userXML.entry.user_love[i], userphoto:userXML.entry.user_photo[i], minutes:minutes, seconds:secondsOutput, country:userXML.entry.user_country[i], city:userXML.entry.user_city[i]});
									userIgnored = false;
								}
							}
							else
							{								
								userlistArray.push({username:userXML.entry.name[i], userstatus:userXML.entry.user_love[i], userphoto:userXML.entry.user_photo[i], minutes:minutes, seconds:secondsOutput, country:userXML.entry.user_country[i], city:userXML.entry.user_city[i]});
							}
							
							var chatKilled:Boolean = false;
							
							if(userXML.entry.user_love[i] == "kick" && userXML.entry.name[i] == currentUser)
							{
							//destroy chat!			
							sa.addText("<font color='" + chatLinkColor + "'><b>>> You have been kicked from the chat!</b></font>");
							
							destroyPrivateChatBoxes();
							updateTimerChat.stop();
							updateTimerChat.removeEventListener(TimerEvent.TIMER, updateChatData); // Chat window data refresh Timer
							updateTimerUserlist.stop();
							updateTimerUserlist.removeEventListener(TimerEvent.TIMER, updateUserListData); // Chat window data refresh Timer
							send_btn.removeEventListener(MouseEvent.CLICK, onMessageSendMouseClick);
							input_txt.removeEventListener(KeyboardEvent.KEY_DOWN, onMessageSendKeyPress);
							logout_btn.removeEventListener(MouseEvent.CLICK, onLogout);
							userlistContainer.visible = false;
							chatKilled = true;
							userEnter = "logout";
							currentUser = "notConnected";
							}
							
							if(userXML.entry.user_love[i] == "ban" && userXML.entry.name[i] == currentUser)
							{
							//ban IP and destroy chat!
							phpRequest = new URLRequest(userProcessUrl);
							phpLoader = new URLLoader();
							
							vars = new URLVariables();
							vars.var1 = currentUser;
							vars.var2 = "suicide";
							vars.var3 = "suicide";
											
							phpRequest.data = vars;
							phpRequest.method = URLRequestMethod.POST;
							phpLoader.load(phpRequest);
							phpLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
							
							sa.addText("<font color='" + chatLinkColor + "'><b>>> You have been banned from the chat!</b></font>");
							
							destroyPrivateChatBoxes();
							updateTimerChat.stop();
							updateTimerChat.removeEventListener(TimerEvent.TIMER, updateChatData); // Chat window data refresh Timer
							updateTimerUserlist.stop();
							updateTimerUserlist.removeEventListener(TimerEvent.TIMER, updateUserListData); // Chat window data refresh Timer
							send_btn.removeEventListener(MouseEvent.CLICK, onMessageSendMouseClick);
							input_txt.removeEventListener(KeyboardEvent.KEY_DOWN, onMessageSendKeyPress);
							logout_btn.removeEventListener(MouseEvent.CLICK, onLogout);
							userlistContainer.visible = false;
							chatKilled = true;
							userEnter = "logout";
							currentUser = "notConnected";
							
							banCookie.data.userlove = "banned";
							banCookie.flush();
							}
						}
						
						scrollButton_mc.removeEventListener(MouseEvent.MOUSE_DOWN, initalizeDragObject);
						yPosition = 0;
						
						if(chatKilled == false)
						{
							for (var m:int = 0; m < userlistArray.length; m++)
							{
								userlistButton = new userlistButton_mc();
								userlistButton.y = yPosition;
								userlistButton.x = 0;
								
								if(userlistArray[m].userstatus == "available")
								{
									userlistButton.username_txt.textColor = 0xFFFFFF;
									userlistButton.onlineTime_txt.textColor = 0xFD8300;
									
									if(userlistArray[m].country == "unknown" || userlistArray[m].country == "null")
									{
										userlistButton.country = "unknown";
										userlistButton.city = "unknown";
										userlistButton.onlineTime_txt.text = "Online - " + userlistArray[m].minutes + ":" + userlistArray[m].seconds;
									}
									else
									{
										userlistButton.country = userlistArray[m].country;
										userlistButton.city = userlistArray[m].city;
                                        if (userlistArray[m].username != "Sandy@Support") 
                                        {
                                            userlistButton.onlineTime_txt.text = userlistArray[m].country + " - " + userlistArray[m].minutes + ":" + userlistArray[m].seconds;
                                        }
                                        else 
                                        {
                                            userlistButton.onlineTime_txt.text = "Chat Robot";
                                        }
                                    }
                                }

								else if(userlistArray[m].userstatus == "away")
								{
									userlistButton.username_txt.textColor = 0x999999;
									userlistButton.onlineTime_txt.textColor = 0x999999;
									
									if(userlistArray[m].country == "unknown" || userlistArray[m].country == "null")
									{
										userlistButton.country = "unknown";
										userlistButton.city = "unknown";
										userlistButton.onlineTime_txt.text = "Busy - " + userlistArray[m].minutes + ":" + userlistArray[m].seconds;
									}
									else
									{
										userlistButton.country = userlistArray[m].country;
										userlistButton.city = userlistArray[m].city;
										userlistButton.onlineTime_txt.text = "Busy - " + userlistArray[m].minutes + ":" + userlistArray[m].seconds;
									}
								}
								
								userlistButton.username_txt.text = userlistArray[m].username;
								userlistButton.username = userlistArray[m].username;
								userlistButton.userphoto = userlistArray[m].userphoto;
								userlistButton.userstatus = userlistArray[m].userstatus;
								userlistButton.currentUser = currentUser;
								userlistButton.chatProcessUrl = chatProcessUrl;
			
								if(userlistButtonArray.length == 0)
								{
									userlistButtonArray.push(userlistButton);
									userlistContainer.addChild(userlistButton);
									userlistButtonFunctionality(userlistButton);
									getUserPhoto(userlistArray[m].userphoto, userlistButton);
								}
								else
								{
									var userButtonFound:Boolean = true;
									
									for (var t:int = 0; t < userlistButtonArray.length; t++)
									{
										if(userlistButtonArray[t].username != userlistButton.username)
										{
											userButtonFound = false;
										}
										else
										{
											// exisiting user button is checked for avatar picture change
											if(userlistButtonArray[t].userphoto == userlistButton.userphoto)
											{
												userButtonFound = true;
												break;
											}
										}
									}
									
									if(userButtonFound == false)
									{
										userlistButtonArray.push(userlistButton);
										userlistContainer.addChild(userlistButton);
										userlistButtonFunctionality(userlistButton);
										getUserPhoto(userlistArray[m].userphoto, userlistButton);
										userButtonFound = true;
									}
									else
									{
										if(userlistArray[m].userstatus == "available")
										{
											userlistButtonArray[t].username_txt.textColor = 0xFFFFFF;
											userlistButtonArray[t].onlineTime_txt.textColor = 0xFD8300;
											
											if(userlistArray[m].country == "unknown" || userlistArray[m].country == "null")
											{
												userlistButtonArray[t].country = "unknown";
												userlistButtonArray[t].city = "unknown";
                                                if (userlistArray[m].username != "Sandy@Support") 
                                                {
                                                    userlistButtonArray[t].onlineTime_txt.text = userlistArray[m].country + " - " + userlistArray[m].minutes + ":" + userlistArray[m].seconds;
                                                }
                                                else 
                                                {
                                                    userlistButtonArray[t].onlineTime_txt.text = "Chat Robot";
                                                }
                                            }
											else
											{
												userlistButtonArray[t].country = userlistArray[m].country;
												userlistButtonArray[t].city = userlistArray[m].city;
												userlistButtonArray[t].onlineTime_txt.text = userlistArray[m].country + " - " + userlistArray[m].minutes + ":" + userlistArray[m].seconds;
											}
										}
										else if(userlistArray[m].userstatus == "away")
										{
											userlistButtonArray[t].username_txt.textColor = 0x999999;
											userlistButtonArray[t].onlineTime_txt.textColor = 0x999999;
											
											if(userlistArray[m].country == "unknown" || userlistArray[m].country == "null")
											{
												userlistButtonArray[t].country = "unknown";
												userlistButtonArray[t].city = "unknown";
												userlistButtonArray[t].onlineTime_txt.text = "Busy - " + userlistArray[m].minutes + ":" + userlistArray[m].seconds;
											}
											else
											{
												userlistButtonArray[t].country = userlistArray[m].country;
												userlistButtonArray[t].city = userlistArray[m].city;
												userlistButtonArray[t].onlineTime_txt.text = "Busy - " + userlistArray[m].minutes + ":" + userlistArray[m].seconds;
											}
										}
										
										userlistButtonArray[t].y = yPosition;
										userlistButtonArray[t].x = 0;
										userlistButtonArray[t].username_txt.text = userlistArray[m].username;
										userlistButtonArray[t].username = userlistArray[m].username;
										userlistButtonArray[t].userstatus = userlistArray[m].userstatus;
										userlistButtonArray[t].currentUser = currentUser;
										userlistButtonArray[t].chatProcessUrl = chatProcessUrl;
		
										userlistContainer.addChild(userlistButtonArray[t]);
										userlistButtonFunctionality(userlistButtonArray[t]);
									}
								}
								yPosition += userlistButton.height + 1;
							}
						}
						
						// Checking if user has been disconnected accidently
						
						if(currentUser != "notConnected")
						{
							currentUserListed = true;
							
							for (var uf:int = 0; uf < userlistArray.length; uf++)
							{
								if(userlistArray[uf].username == currentUser)
								{
									currentUserListed = true;
									userNotFoundCounter = 0;
									break;
								}
								else
								{
									currentUserListed = false;
								}
							}
							
							if(currentUserListed == false)
							{
								userNotFoundCounter ++;
								
								if(userNotFoundCounter == 3)
								{
									userNotFoundCounter = 0;
									forceReLogin();
								}
							}
						}
						
						scrollButton_mc.addEventListener(MouseEvent.MOUSE_DOWN, initalizeDragObject);				
						userlistContainer.y = -(userlistY -(userlistInitPos*2));
						
						if(userXML.*.length() <= 3)
						{
							updateTimerChat.delay = 2000;
							updateTimerUserlist.delay = 3000;
						}
						else if(userXML.*.length() > 3 && userXML.*.length() <= 5)
						{
							updateTimerChat.delay = 3000;
							updateTimerUserlist.delay = 4000;
						}
						else if(userXML.*.length() > 5 && userXML.*.length() <= 10)
						{
							updateTimerChat.delay = 3000;
							updateTimerUserlist.delay = 5000;
						}
						else if(userXML.*.length() > 10 && userXML.*.length() <= 15)
						{
							updateTimerChat.delay = 5000;
							updateTimerUserlist.delay = 8000;
						}
						else if(userXML.*.length() > 15)
						{
							updateTimerChat.delay = 7000;
							updateTimerUserlist.delay = 10000;
						}
						
						status_txt.htmlText = "<b>" + String(userXML.*.length()) + "</b> User(s) Online";
						userscroll_cmp.scrollPosition = userscroll_cmp.minScrollPosition; // Moves the SCROLL BAR to end of chat message text
							
						phpRequest = new URLRequest(userProcessUrl);
						phpLoader = new URLLoader();
						
						vars = new URLVariables();
						vars.var1 = currentUser;
						vars.var2 = "null";
						vars.var3 = "ping";
										
						phpRequest.data = vars;
						phpRequest.method = URLRequestMethod.POST;
						phpLoader.load(phpRequest);
						phpLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
					} //Closing tag from if XML > 0
					else
					{
						trace("-> SKIPPING USERLIST UPDATE");
						
						if(userXML.*.length() <= 0 && userEnter == "logged")
						{
							userNotFoundCounter ++;
							
							if(userNotFoundCounter == 3)
							{
								userNotFoundCounter = 0;
								forceReLogin();
							}
						}
						else
						{
							userNotFoundCounter = 0;
						}
					}
				}
				catch (err:TypeError) 
				{
					trace("Chat userlist has become corrupted. Executing auto-reset!" + err);
					
					phpRequest = new URLRequest("xml_autoclean.php");
					phpLoader = new URLLoader();
		
					vars = new URLVariables();
					vars.var1 = "resetUserXML";
						
					phpRequest.data = vars;
					phpRequest.method = URLRequestMethod.POST;
					phpLoader.load(phpRequest);
					phpLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				}
			}

			function getUserPhoto(userPhoto:String, currentButton:MovieClip)
			{
				if(userPhoto != "none" && userPhoto != null && userPhoto.substr(0,4) != "http")
				{							
					var imageRequest:URLRequest = new URLRequest("upload/" + userPhoto);
					var imageLoader:Loader = new Loader();
					imageLoader.load(imageRequest);
					imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
					imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadMyAvatarPictureComplete);
				}
				else if (userPhoto != "none" && userPhoto != null && userPhoto.substr(0,4) == "http")
				{
					var lc:LoaderContext = new LoaderContext();
					lc.checkPolicyFile = false;
					
					imageLoader = new Loader();
					imageRequest = new URLRequest(userPhoto);
					imageLoader.load(imageRequest, lc);
					imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoaded);
					imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				}
				else
				{
					currentButton.userlistButtonIconContainer_mc.visible = false;
				}
				
				function onImageLoaded($e:Event):void
				{
					var _innerImage:Sprite = currentButton.userlistButtonIconContainer_mc.addChild(new Sprite());
				    imageLoader.x = - Number(Math.ceil(currentButton.userlistButtonIconContainer_mc.width * 0.5) - 1);
					imageLoader.y = - Number(Math.ceil(currentButton.userlistButtonIconContainer_mc.height * 0.5) - 1);
					
					imageLoader.width = 45;
					imageLoader.height = 45;
					currentButton.userlistButtonIconContainer_mc.addChild(imageLoader);
				}
				
				function loadMyAvatarPictureComplete(event:Event):void
				{
					_bitmap = new Bitmap();
					_bitmap = event.target.content;
					resizeIt(_bitmap,45,45);
					_bitmap.smoothing = true;

					_bitmap.x = 0 - _bitmap.width/2;
					_bitmap.y = 0 - _bitmap.height/2;

					currentButton.userlistButtonIconContainer_mc.addChild(_bitmap);
					currentButton.userlistButtonIconContainer_mc.visible = true;
				}
				
				function resizeIt(b:Bitmap,maxH:Number,maxW:Number) 
				{
					var r:Number;//ratio
					r = b.height/b.width;//calculation ratio to which resize takes place
				
					if (b.width>maxW) {
					b.width = maxW;
					b.height = Math.round(b.width*r);
				
					}
					if (b.height>maxH) 
					{
						b.height = maxH;
						b.width = Math.round(b.height/r);
					}
				}
			}
			
			function forceReLogin():void
			{
				trace("-> TRYING AUTO-RECONNECT");
					
				phpRequest = new URLRequest(userProcessUrl);
				phpLoader = new URLLoader();
						
				vars = new URLVariables();
				vars.var1 = currentUser;
				vars.var2 = "available";
				vars.var3 = "online";
				vars.var4 = pictureFilename;
				vars.var5 = country;
				vars.var6 = city;
										
				phpRequest.data = vars;
				phpRequest.method = URLRequestMethod.POST;
				phpLoader.load(phpRequest);
				phpLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			}
			

// FUNCTION onMessageSend - Processing typed message
// ***************************************************************************************************************************************
// ***************************************************************************************************************************************
// ***************************************************************************************************************************************
			
			/*Send message via keypress*/
			function onMessageSendKeyPress(event:KeyboardEvent):void
			{
				if(event.keyCode == 13 && floodingCounter < 3 && currentUser != "notConnected")
				{
					chatMessage = String(input_txt.text);
					input_txt.text = "";
					onMessageSend();
				}
			}	
		
			/*Send message via send button click*/
			function onMessageSendMouseClick(event:MouseEvent):void
			{
				if(floodingCounter < 3 && floodingCounter < 3 && currentUser != "notConnected")
				{
					chatMessage = String(input_txt.text);
					input_txt.text = "";
					onMessageSend();
				}
			}
			
			/*Sends user message to PHP to save the new data into the chathistory XML*/
			function onMessageSend():void
			{
				floodingCounter++;
				
				if(firstServerTime != "expired")
				{
					previousTimeStamp = firstServerTime;
					firstServerTime = "expired";
				}
				
				var messageTest:String = chatMessage;
				messageTest = messageTest.split(" ").join("");
				
				if(messageTest == "")
				{
					chatMessage = "";
				}
				
				var messageForceDisplay:Boolean = true;
				var messageBefore:String = String(chatMessage);
				
				function trim(str:String):String
				{
					return str.replace(/^\s*(.*?)\s*$/g, "$1");
				}

				chatMessage = trim(chatMessage).replace(/\s{1,}(.*?)/g, "$1 ");
				message_str = String(chatMessage);
				message_str = message_str.replace(/((https?|ftp|telnet|file):((\/\/)|(\\\\))+[\w\d:#@%\/;$()~_?\+-=\\\.&]*)/g, "<u><a href='$1' target='_blank'><font color='" + chatLinkColor + "'>$1</font></a></u>");
				
				var messageAfter:String = message_str;
				
				if(messageBefore != messageAfter)
				{
					messageForceDisplay = false;
				}
				
				if(String(chatMessage).substr(0,8) == "/private")
				{
					//sa.addText("<font color='" + chatTextColor + "'>[ " + previousTimeStamp + " ]<b> " + currentUser + ": <font color='" + chatLinkColor + "'>[Private Sent]</font></b> " + message_str + "</font>");
					
					trace("-> New private message outgoing");
					
					phpRequest = new URLRequest(chatProcessUrl);
					phpLoader = new URLLoader();
	
					vars = new URLVariables();
					vars.var1 = currentUser;
					vars.var2 = chatMessage;
					
					phpRequest.data = vars;
					phpRequest.method = URLRequestMethod.POST;

					phpLoader.load(phpRequest);
					phpLoader.addEventListener(Event.COMPLETE, onMessageComplete);
					phpLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				}
				
				if(String(chatMessage).substr(0,5) == "/help")
				{
					sa.addText("<font color='" + chatTextColor + "'><b><font color='" + chatLinkColor + "'>[ Chat User Guide ] -----------------------------------------------------------------------------------------</b></font></font>");
					sa.addText("<font color='" + chatTextColor + "'><font color='" + chatLinkColor + "'>Start private 1 on 1 chat</font> - Click on a user in the right userlist</font>");
					sa.addText("<font color='" + chatTextColor + "'><font color='" + chatLinkColor + "'>Video & voice call</font> - Click on a user and then on the video call button</font>");
					sa.addText("<font color='" + chatTextColor + "'><font color='" + chatLinkColor + "'>View rooms list</font> - Type <font color='" + chatLinkColor + "'>/rooms</font> into the chat</font>");
					chatMessage = "";
				}
					
				if(String(chatMessage).substr(0,6) == "/rooms")
				{
					
				}
						
				if(String(chatMessage).substr(0,7) == "/sounds")
				{
						if(sounds == true)
						{
						chatMessage = ""
						trace ("[Sounds OFF]");
						sounds = false;
						sa.addText("<font color='" + chatLinkColor + "'>>> [Sounds OFF]</font>");
						}
						else if(sounds == false)
						{
						chatMessage = ""
						trace ("[Sounds ON]");
						sounds = true;
						sa.addText("<font color='" + chatLinkColor + "'>>> [Sounds ON]</font>");
						}
				}
						
				if(String(chatMessage).substr(0,8) == "/history")
				{
						chatMessage = "";
						trace("[Loading History]");
						sa.addText("<font color='" + chatLinkColor + "'>>> [Loading History...]</font>");
							
						archiveXmlLoader.load(new URLRequest("chatarchive.xml" + "?nocache=" + new Date().getTime()));
						archiveXmlLoader.addEventListener(ProgressEvent.PROGRESS, loadArchiveXML);
						archiveXmlLoader.addEventListener(Event.COMPLETE, processChatXML);
						archiveXmlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				}
					
				if(String(chatMessage).substr(0,6) == "/clear")
				{
						adminCodeBox.x = 20;
						adminCodeBox.y = 20;
						addChild(adminCodeBox);
						
						adminCodeBox.close_btn.addEventListener(MouseEvent.CLICK, onClosePasswordBox);
						adminCodeBox.kick_btn.addEventListener(MouseEvent.CLICK, onCodeClear);
				}
					
				if(String(chatMessage).substr(0,5) == "/kick")
				{
						adminCodeBox.x = 20;
						adminCodeBox.y = 20;
						addChild(adminCodeBox);
						
						adminCodeBox.close_btn.addEventListener(MouseEvent.CLICK, onClosePasswordBox);
						adminCodeBox.kick_btn.addEventListener(MouseEvent.CLICK, onCodeKick);
				}
						
				if(String(chatMessage).substr(0,4) == "/ban")
				{
						adminCodeBox.x = 20;
						adminCodeBox.y = 20;
						addChild(adminCodeBox);
							
						adminCodeBox.close_btn.addEventListener(MouseEvent.CLICK, onClosePasswordBox);
						adminCodeBox.kick_btn.addEventListener(MouseEvent.CLICK, onCodeBan);
				}
						
				if(String(chatMessage).substr(0,1) == "/" &&
				String(chatMessage).substr(0,5) != "/help" &&
				String(chatMessage).substr(0,7) != "/sounds" &&
				String(chatMessage).substr(0,8) != "/private" &&
				String(chatMessage).substr(0,5) != "/kick" && 
				String(chatMessage).substr(0,8) != "/history" &&
				String(chatMessage).substr(0,4) != "/ban" && 
				String(chatMessage).substr(0,6) != "/clear" && 
				String(chatMessage).substr(0,4) != "/rooms")
				{
						trace("[Invalid Command]");
						sa.addText("<font color='" + chatLinkColor + "'>>> <b>[Invalid Command!]</b> Please type /help to see a list of commands.</font>");
						chatMessage = "";
				}
					
				if(String(chatMessage) != "" &&
				messageArray.length > 0 &&
				String(chatMessage) == String(messageArray[messageArray.length - 1].chatmessage) &&
				currentUser == String(messageArray[messageArray.length - 1].username))
				{
						sa.addText("<font color='" + chatLinkColor + "'>>> <b>[Flood Control]</b> Duplicate messages are not allowed!</font>");
						chatMessage = "";
				}
					
				if(String(chatMessage) != "" &&
				String(chatMessage).substr(0,6) != "/clear" && 
				String(chatMessage).substr(0,5) != "/kick" && 
				String(chatMessage).substr(0,8) != "/history" &&
				String(chatMessage).substr(0,4) != "/ban")
				{					
						phpRequest = new URLRequest(chatProcessUrl);
						phpLoader = new URLLoader();
			
						vars = new URLVariables();
						vars.var1 = currentUser;
						vars.var2 = chatMessage;
							
						phpRequest.data = vars;
						phpRequest.method = URLRequestMethod.POST;
			
						phpLoader.load(phpRequest);
						phpLoader.addEventListener(ProgressEvent.PROGRESS, onMessageStart);
						phpLoader.addEventListener(Event.COMPLETE, onMessageComplete);
						phpLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
					
						if(messageForceDisplay == true)
						{
							sound_newMessage.play();
							chatBoxMessageArray.push({timestamp:previousTimeStamp, username:currentUser, chatmessage:message_str, messagetime:"1"});
						
							if(chatBoxMessageArray.length >= messageArray.length * 2)
							{
								chatBoxMessageArray.splice(0,1);
							}
							
							var pattern:RegExp = /@/i;
							if(currentUser.search(pattern) != -1)
							{
								sa.addText("<font color='" + adminTextColor + "'><b>" + currentUser + ":</b> " + message_str + "</font>");
							}
							else
							{
								sa.addText("<font color='" + chatTextColor + "'><b>" + currentUser + ":</b> " + message_str + "</font>");
								chatBotMessage = chatBotAI.queryAnswer(message_str);
							}
						}
				}
				
				if(String(chatMessage) == "")
				{

				}
			}

			function onMessageStart(event:ProgressEvent):void
			{
				trace("-> Message Sending");
				chatMessage = "";
			}

			function onMessageComplete(e:Event):void
            {
                if (!(chatBotMessage == "nothing") && !(chatBotMessage == "")) 
                {
                    botMessageDelay.addEventListener(flash.events.TimerEvent.TIMER, sendBotMessage);
                    botMessageDelay.start();
                }
                else 
                {
                    chatBotMessage = "";
                }
                return;
            }
		
		
// Private 1 on 1 Chat
// ***************************************************************************************************************************************
// ***************************************************************************************************************************************
// ***************************************************************************************************************************************			
			
			function createNewChatBox(_username:String, _message:String)
			{
			   if(helpWindow)
            {
               stage.removeChild(helpWindow);
               helpWindow = null;
            }
				privateChatBox = new privateMessage_mc();
				privateChatBox.username = _username;

				privateChatBox.x = 20 + Math.round(Math.random()*40);;
				privateChatBox.y = 20 + Math.round(Math.random()*40);
	
				privateChatBox.privateMessageDragBox_mc.buttonMode = true;
				privateChatBox.privateMessageDragBox_mc.addEventListener(MouseEvent.MOUSE_DOWN, dragPrivateChatBox);
				privateChatBox.privateMessageDragBox_mc.addEventListener(MouseEvent.MOUSE_UP, dropPrivateChatBox);
										
				privateChatBox.privateMessageTitle_txt.htmlText = "<b>Private chat with " + _username + "</b>";
				
				if(_message != "none")
				{
					privateChatBox.privateMessage_txt.appendText("\n\n\n\n\n\n\n\n\n\n\n\n\n");
					privateChatBox.privateMessage_txt.htmlText = privateChatBox.privateMessage_txt.htmlText + "<font color='#000000'><b>New private chat invitation...</b>\nUser " + privateChatBox.username + " would like to start a private chat with you in this window.\n" + _message + "</font>";
				}
				else
				{
					privateChatBox.privateMessage_txt.appendText("\n\n\n\n\n\n\n\n\n\n\n\n\n");
					privateChatBox.privateMessage_txt.htmlText = privateChatBox.privateMessage_txt.htmlText + "<font color='#000000'><b>Creating private chat room...</b>\nSend a message in this window to invite user " + privateChatBox.username + " into your private chat room.</font>";
				}

				privateChatBox.close_btn.addEventListener(MouseEvent.CLICK, onClosePrivateChatBox);
				privateChatBox.privateSend_btn.addEventListener(MouseEvent.CLICK, onChatBoxSendMouseClick);
				privateChatBox.privateInput_txt.addEventListener(KeyboardEvent.KEY_DOWN, onChatBoxSendKeyPress);
				
				privateChatBox.ignore_btn.addEventListener(MouseEvent.CLICK, onIgnorePrivateChatBox);
				privateChatBox.kick_btn.addEventListener(MouseEvent.CLICK, onKickPrivateChatBox);
				privateChatBox.ban_btn.addEventListener(MouseEvent.CLICK, onBanPrivateChatBox);
				
				privateChatBox.cam_btn.addEventListener(MouseEvent.CLICK, webCamButtonClick);
				
				chatBoxesArray.push(privateChatBox);
				stage.addChild(privateChatBox);
				
				privateBoxesScrollTimer.addEventListener(TimerEvent.TIMER, privateBoxesScrollMax);
				privateBoxesScrollTimer.start();
			}
			
			function privateBoxesScrollMax(event:TimerEvent):void
			{
				for (var ih:int = 0; ih < chatBoxesArray.length; ih++)
				{
					chatBoxesArray[ih].textScroller.scrollPosition = chatBoxesArray[ih].textScroller.maxScrollPosition;
				}
				
				privateBoxesScrollTimer.removeEventListener(TimerEvent.TIMER, privateBoxesScrollMax);
				privateBoxesScrollTimer.stop();
			}

			function onIgnorePrivateChatBox(event:MouseEvent):void
			{
				if(event.target.parent.username != currentUser)
				{
					privateChatBox.ignore_btn.removeEventListener(MouseEvent.CLICK, onIgnorePrivateChatBox);
					event.target.parent.visible = false;
					ignoredUsers.push(event.target.parent.username);
				}
				else
				{
					event.target.parent.privateMessage_txt.htmlText = event.target.parent.privateMessage_txt.htmlText + "<b>System Message: </b>You cannot ignore yourself.";
					event.target.parent.textScroller.scrollPosition = event.target.parent.textScroller.maxScrollPosition;
					stage.setChildIndex(event.target.parent, stage.numChildren - 1);
				}
			}
			
			function onKickPrivateChatBox(event:MouseEvent):void
			{
				privateChatBox.kick_btn.removeEventListener(MouseEvent.CLICK, onKickPrivateChatBox);
				event.target.parent.visible = false;
				adminActionOnUser = event.target.parent.username;
				
				adminCodeBox.x = 20;
				adminCodeBox.y = 20;
				addChild(adminCodeBox);
						
				adminCodeBox.close_btn.addEventListener(MouseEvent.CLICK, onClosePasswordBox);
				adminCodeBox.kick_btn.addEventListener(MouseEvent.CLICK, onCodeKick);
			}
			
			function onBanPrivateChatBox(event:MouseEvent):void
			{
				privateChatBox.ban_btn.removeEventListener(MouseEvent.CLICK, onBanPrivateChatBox);
				event.target.parent.visible = false;
				adminActionOnUser = event.target.parent.username;
				
				adminCodeBox.x = 20;
				adminCodeBox.y = 20;
				addChild(adminCodeBox);
						
				adminCodeBox.close_btn.addEventListener(MouseEvent.CLICK, onClosePasswordBox);
				adminCodeBox.kick_btn.addEventListener(MouseEvent.CLICK, onCodeBan);
			}
			
			function callPrivateChatBox(_username:String, _message:String)
			{
				var chatBoxFound:Boolean = false;
			
				for (var ih:int = 0; ih < chatBoxesArray.length; ih++)
				{
					if(chatBoxesArray[ih].username != _username)
					{
						chatBoxFound = false;
					}
					else
					{
						chatBoxFound = true;
						break;
					}
				}
				
				if(chatBoxFound == false)
				{
					createNewChatBox(_username, _message);
				}
				else
				{
					chatBoxesArray[ih].visible = true;
					
					if(_message != "none")
					{
						chatBoxesArray[ih].privateMessage_txt.htmlText = chatBoxesArray[ih].privateMessage_txt.htmlText + _message;
						chatBoxesArray[ih].textScroller.scrollPosition = chatBoxesArray[ih].textScroller.maxScrollPosition;
						stage.setChildIndex(chatBoxesArray[ih], stage.numChildren - 1);
					}
				}
			}
			
			function placePrivateChatFullScreen(event:Event):void
			{				
				var chatBoxFound:Boolean = false;
			
				for (var ih:int = 0; ih < chatBoxesArray.length; ih++)
				{
					if(chatBoxesArray[ih].username != camController.userToInvite)
					{
						chatBoxFound = false;
					}
					else
					{
						chatBoxFound = true;
						break;
					}
				}
				
				if(chatBoxFound == true)
				{
					stage.setChildIndex(chatBoxesArray[ih], stage.numChildren - 1);
				}
			}
			
			function onChatBoxSendMouseClick(event:MouseEvent):void
			{
				if(event.target.parent.privateInput_txt.text != "" && floodingCounter < 3 && currentUser != "notConnected")
				{
					sendPrivateMessage(event.target.parent, event.target.parent.username, event.target.parent.privateInput_txt.text);
					event.target.parent.privateInput_txt.text = "";
				}
			}
			
			function onChatBoxSendKeyPress(event:KeyboardEvent):void
			{
				if(event.keyCode == 13 && event.target.parent.privateInput_txt.text != "" && floodingCounter < 3 && currentUser != "notConnected")
				{
					sendPrivateMessage(event.target.parent, event.target.parent.username, event.target.parent.privateInput_txt.text);
					event.target.parent.privateInput_txt.text = "";
				}
			}	
			
			function sendPrivateMessage(_chatbox:MovieClip, _username:String, _message:String):void
			{
				selectedChatBox = _chatbox;
				
				floodingCounter++;
				
				if(firstServerTime != "expired")
				{
					previousTimeStamp = firstServerTime;
					firstServerTime = "expired";
				}
				
				var messageTest:String = _message;
				messageTest = messageTest.split(" ").join("");
				
				if(messageTest == "")
				{
					_message = "";
				}

				if(_message != "")
				{
					_message = trim(_message).replace(/\s{1,}(.*?)/g, "$1 ");
					var messageCleaned:String = String(_message);
					message_str = String(_message);
					message_str = message_str.replace(/((https?|ftp|telnet|file):((\/\/)|(\\\\))+[\w\d:#@%\/;$()~_?\+-=\\\.&]*)/g, "<u><a href='$1' target='_blank'><font color='" + chatLinkColor + "'>$1</font></a></u>");
					_message = message_str;
	
					selectedChatBox.privateMessage_txt.htmlText = selectedChatBox.privateMessage_txt.htmlText + "<font color='#000000'><b>" + currentUser + ":</b> " + _message + "</font>";
					selectedChatBox.textScroller.scrollPosition = selectedChatBox.textScroller.maxScrollPosition;
	
					//sa.addText("<font color='" + chatTextColor + "'>[ " + previousTimeStamp + " ]<b> " + currentUser + ": <font color='" + chatLinkColor + "'>[to " + _username + "]</font></b> " + _message + "</font>");
					sound_newMessage.play();
					trace("-> New private message outgoing");
						
					phpRequest = new URLRequest(chatProcessUrl);
					phpLoader = new URLLoader();
		
					vars = new URLVariables();
					vars.var1 = currentUser;
					vars.var2 = "/private " + _username + " " + messageCleaned;

					phpRequest.data = vars;
					phpRequest.method = URLRequestMethod.POST;

					phpLoader.load(phpRequest);
					phpLoader.addEventListener(Event.COMPLETE, onSendPrivateMessageComplete);
					phpLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				}
				else
				{

				}
				
				function trim(str:String):String
				{
					return str.replace(/^\s*(.*?)\s*$/g, "$1");
				}
			}
			
			function onSendPrivateMessageComplete(e:Event):void
			{

			}
			
			function dragPrivateChatBox(event:MouseEvent):void
			{
				stage.setChildIndex(event.target.parent, stage.numChildren - 1);
				event.target.parent.startDrag();
			}
					
			function dropPrivateChatBox(event:MouseEvent):void
			{
				event.target.parent.stopDrag();
			}
			
			function onClosePrivateChatBox(event:MouseEvent):void
			{
				event.target.parent.visible = false;
			}
			
			function destroyPrivateChatBoxes():void
			{
				if(chatBoxesArray)
				{	
					for (var xd:int = 0; xd < chatBoxesArray.length; xd++)
					{
						stage.removeChild(chatBoxesArray[xd]);
					}
					
					chatBoxesArray = null;
					chatBoxesArray = new Array();
				}
			}
			
		
// CHAT COMMAND FUNCTIONS - Process called chat commands
// ***************************************************************************************************************************************
// ***************************************************************************************************************************************
// ***************************************************************************************************************************************


			// Loading Chat History Function
			function loadArchiveXML(event:ProgressEvent):void 
			{
				var per = event.bytesLoaded/event.bytesTotal;
				
				input_txt.text = "Loading Chat History. Please wait... " + "Total: " + String(event.bytesTotal) + " Bytes - Loaded: " + String(event.bytesLoaded) + " Bytes";
			
				if(Number(event.bytesTotal) >= 50000)
				{
					input_txt.text = "";
					sa.addText("<font color='" + chatLinkColor + "'>>> History XML file has become too large to load. Please reset.</font>");
					injectingHistory = false;
					archiveXmlLoader.removeEventListener(Event.COMPLETE, processChatXML);
					archiveXmlLoader.removeEventListener(ProgressEvent.PROGRESS, loadArchiveXML);
				}
				
				if(Number(event.bytesTotal) <= 50000)
				{
					if(Math.round(per*10*10) == 100) 
					{
						input_txt.text = "";
						trace("[Injecting History]");
						injectingHistory = true;
					}
				}
			}
			
			// Administrator Password Box Functions
			function onClosePasswordBox(event:MouseEvent):void
			{
				input_txt.text = "";
				input_txt.addEventListener(KeyboardEvent.KEY_DOWN, onMessageSendKeyPress);
				send_btn.addEventListener(MouseEvent.CLICK, onMessageSendMouseClick);
				
				adminCodeBox.adminCodeError_txt.text = "";
				adminCodeBox.adminCode_txt.text = "";
				adminCodeBox.close_btn.removeEventListener(MouseEvent.CLICK, onClosePasswordBox);
				adminCodeBox.kick_btn.removeEventListener(MouseEvent.CLICK, onCodeBan);
				adminCodeBox.kick_btn.removeEventListener(MouseEvent.CLICK, onCodeKick);
				adminCodeBox.kick_btn.removeEventListener(MouseEvent.CLICK, onCodeClear);
				removeChild(adminCodeBox);
				input_txt.text = "";
			}	
			
			
			function onCodeKick(event:MouseEvent):void
			{
				if(String(adminCodeBox.adminCode_txt.text) == adminCode)
				{
					phpRequest = new URLRequest(userProcessUrl);
					phpLoader = new URLLoader();
					
					vars = new URLVariables();
					
					if(adminActionOnUser != "")
					{
						sa.addText("<font color='" + chatLinkColor + "'>>> [Kicking User] " + String(adminActionOnUser) + "</font>");
						vars.var1 = String(adminActionOnUser);
					}
					else if(chatMessage != "")
					{
						sa.addText("<font color='" + chatLinkColor + "'>>> [Kicking User] " + String(chatMessage).substr(6,20) + "</font>");
						vars.var1 = String(chatMessage).substr(6,20);
					}
					
					adminActionOnUser = "";
					
					vars.var2 = "kick";
					vars.var3 = "kick";
										
					phpRequest.data = vars;
					phpRequest.method = URLRequestMethod.POST;
					phpLoader.load(phpRequest);
					phpLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
					
					input_txt.addEventListener(KeyboardEvent.KEY_DOWN, onMessageSendKeyPress);
					send_btn.addEventListener(MouseEvent.CLICK, onMessageSendMouseClick);
					
					adminCodeBox.adminCodeError_txt.text = "";
					adminCodeBox.adminCode_txt.text = "";
					adminCodeBox.close_btn.removeEventListener(MouseEvent.CLICK, onClosePasswordBox);
					adminCodeBox.kick_btn.removeEventListener(MouseEvent.CLICK, onCodeKick);
					removeChild(adminCodeBox);
					input_txt.text = "";
				}
				
				if(String(adminCodeBox.adminCode_txt.text) != adminCode && String(adminCodeBox.adminCode_txt.text) != "")
				{
					adminCodeBox.adminCodeError_txt.text = "Wrong Password!";
					adminCodeBox.adminCode_txt.text = "";
				}
			}
			
			
			function onCodeBan(event:MouseEvent):void
			{
				if(String(adminCodeBox.adminCode_txt.text) == adminCode)
				{
					phpRequest = new URLRequest(userProcessUrl);
					phpLoader = new URLLoader();
						
					vars = new URLVariables();
					
					if(adminActionOnUser != "")
					{
						sa.addText("<font color='" + chatLinkColor + "'>>> [Banning User] " + String(adminActionOnUser) + "</font>");
						vars.var1 = String(adminActionOnUser);
					}
					else if(chatMessage != "")
					{
						sa.addText("<font color='" + chatLinkColor + "'>>> [Banning User] " + String(chatMessage).substr(5,20) + "</font>");
						vars.var1 = String(chatMessage).substr(5,20);
					}
					
					adminActionOnUser = "";
					
					vars.var2 = "ban";
					vars.var3 = "ban";
										
					phpRequest.data = vars;
					phpRequest.method = URLRequestMethod.POST;
					phpLoader.load(phpRequest);
					phpLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
					
					input_txt.addEventListener(KeyboardEvent.KEY_DOWN, onMessageSendKeyPress);
					send_btn.addEventListener(MouseEvent.CLICK, onMessageSendMouseClick);
					
					adminCodeBox.adminCodeError_txt.text = "";
					adminCodeBox.adminCode_txt.text = "";
					adminCodeBox.close_btn.removeEventListener(MouseEvent.CLICK, onClosePasswordBox);
					adminCodeBox.kick_btn.removeEventListener(MouseEvent.CLICK, onCodeBan);
					removeChild(adminCodeBox);
					input_txt.text = "";
				}
				
				if(String(adminCodeBox.adminCode_txt.text) != adminCode && String(adminCodeBox.adminCode_txt.text) != "")
				{
					adminCodeBox.adminCodeError_txt.text = "Wrong Password!";
					adminCodeBox.adminCode_txt.text = "";
				}
			}	

			// Clearing Chat History XML Files Function
			function onCodeClear(event:MouseEvent):void
			{
				if(String(adminCodeBox.adminCode_txt.text) == adminCode)
				{
					phpRequest = new URLRequest(chatFunctionsUrl);
					phpLoader = new URLLoader();
	
					vars = new URLVariables();
					vars.var2 = "clear";
					vars.var3 = "clear";
										
					phpRequest.data = vars;
					phpRequest.method = URLRequestMethod.POST;
					phpLoader.load(phpRequest);
					phpLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
					
					sa.addText("<font color='" + chatLinkColor + "'>>> [History Cleared]</font>");
	
					input_txt.addEventListener(KeyboardEvent.KEY_DOWN, onMessageSendKeyPress);
					send_btn.addEventListener(MouseEvent.CLICK, onMessageSendMouseClick);
					
					adminCodeBox.adminCodeError_txt.text = "";
					adminCodeBox.adminCode_txt.text = "";
					adminCodeBox.close_btn.removeEventListener(MouseEvent.CLICK, onClosePasswordBox);
					adminCodeBox.kick_btn.removeEventListener(MouseEvent.CLICK, onCodeClear);
					removeChild(adminCodeBox);
					input_txt.text = "";
				}
				
				if(String(adminCodeBox.adminCode_txt.text) != adminCode && String(adminCodeBox.adminCode_txt.text) != "")
				{
					adminCodeBox.adminCodeError_txt.text = "Wrong Password!";
					adminCodeBox.adminCode_txt.text = "";
				}
			}


// FUNCTION onLogout - Logout the user and send the logout command to PHP to remove the user name from the userlist
// ***************************************************************************************************************************************
// ***************************************************************************************************************************************
// ***************************************************************************************************************************************

			function onLogout(event:MouseEvent):void
			{
				if(currentUser != "notConnected")
				{
					logout_btn.removeEventListener(MouseEvent.CLICK, onLogout);
					send_btn.removeEventListener(MouseEvent.CLICK, onMessageSendMouseClick);
					input_txt.removeEventListener(KeyboardEvent.KEY_DOWN, onMessageSendKeyPress);
					
					updateTimerChat.stop();
					updateTimerUserlist.stop();

					phpRequest = new URLRequest(userProcessUrl);
					phpLoader = new URLLoader();
		
					vars = new URLVariables();
					vars.var1 = currentUser;
					vars.var2 = "ok";
					vars.var3 = "logout";
						
					phpRequest.data = vars;
					phpRequest.method = URLRequestMethod.POST;
					phpLoader.load(phpRequest);
					phpLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
					
					phpRequest = new URLRequest(chatProcessUrl);
					phpLoader = new URLLoader();
		
					vars = new URLVariables();
					vars.var1 = currentUser;
					vars.var2 = "Leaves @";
					
					phpRequest.data = vars;
					phpRequest.method = URLRequestMethod.POST;					
					phpLoader.load(phpRequest);
					phpLoader.addEventListener(Event.COMPLETE, onLogoutComplete);
					phpLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				}
			}
			
			function onLogoutComplete(event:Event):void 
			{
				currentDate = new Date();
				userEnter = "logout";
				currentUser = "notConnected";
				
				destroyPrivateChatBoxes();
				stage.removeChild(emoButton);
				stage.removeChild(statusButton);
				
			   if(helpWindow)
            {
               stage.removeChild(helpWindow);
               helpWindow = null;
            }
				
				if(camController.visible == true)
				{
					camController.killVideoCall();
				}
				
				if(userlistContainer && stage.contains(userlistContainer))
				{
					stage.removeChild(userlistContainer);
				}
				
				gotoAndStop("logout");
				logout_btn.addEventListener(MouseEvent.CLICK, onLogout);
				send_btn.addEventListener(MouseEvent.CLICK, onMessageSendMouseClick);
				input_txt.addEventListener(KeyboardEvent.KEY_DOWN, onMessageSendKeyPress);
			}
						
		
// Scrollbars Mouse Events
// ***************************************************************************************************************************************
// ***************************************************************************************************************************************
// ***************************************************************************************************************************************
			
			userscroll_cmp.addEventListener(MouseEvent.MOUSE_OVER, onUserScroll);
			userscroll_cmp.addEventListener(MouseEvent.MOUSE_DOWN, onUserScroll);
			userscroll_cmp.addEventListener(MouseEvent.MOUSE_UP, onUserExitScroll);
			userscroll_cmp.addEventListener(MouseEvent.ROLL_OUT, onUserExitScroll);
			
			function onUserScroll(event:MouseEvent):void
			{
				userscroll_cmp.alpha = .6;
			}
			
			function onUserExitScroll(event:MouseEvent):void
			{
				userscroll_cmp.alpha = .0;
			}

			function userlistButtonFunctionality(_userlistButton:MovieClip):void
			{
				_userlistButton.userlistButtonClickArea_mc.buttonMode = true;
				_userlistButton.userlistButtonClickArea_mc.addEventListener(MouseEvent.MOUSE_DOWN, onUserlistButtonClick);
				_userlistButton.userlistButtonClickArea_mc.addEventListener(MouseEvent.MOUSE_OVER, onUserlistButtonOver);
				_userlistButton.userlistButtonClickArea_mc.addEventListener(MouseEvent.MOUSE_OUT, onUserlistButtonOut);
			}
			
			function onUserlistButtonClick(event:MouseEvent):void
			{
				if(currentUser != "notConnected")
				{
					callPrivateChatBox(event.target.parent.username, "none");
				}
			}
				
			function onUserlistButtonOver(event:MouseEvent):void
			{
				event.target.parent.gotoAndStop("over");
			}
				
			function onUserlistButtonOut(event:MouseEvent):void
			{
				event.target.parent.gotoAndStop("out");
			}
			
			
			
			
			
			
			function addInvitedUser(_userID:String, _username:String)
			{
				camController.userID = _userID;
				stage.setChildIndex(camController, stage.numChildren - 1);
			}
			
			
			function newCamInvitation(_userID:String, _username:String)
			{
				if(camController.callStatus != "active")
				{
					camController.callStatus = "active";
					camController.videoChatStatus = "invited";
					camController.chatStatus = "notchatting";				
					camController.userID = _userID;
					camController.userToInvite = _username;
					camController.myUsername = currentUser;
					camController.videoCallTitle_txt.htmlText = "<b>Video call with " + _username + "</b>";
					camController.visible = true;
					camController.reset();
					stage.setChildIndex(camController, stage.numChildren - 1);
				}
			}
			
			function webCamButtonClick(event:MouseEvent):void
			{
				if(camController.callStatus != "active")
				{
					camController.callStatus = "active";
					camController.videoChatStatus = "starter";
					camController.chatStatus = "notchatting";
					camController.userToInvite = event.target.parent.username;
					camController.myUsername = currentUser;
					camController.videoCallTitle_txt.htmlText = "<b>Video call with " + event.target.parent.username + "</b>";
					camController.visible = true;
					camController.reset();
					stage.setChildIndex(camController, stage.numChildren - 1);
				}
			}
			
			function sendVideoCallInvitation(event:Event):void
			{
				trace("-> Starting video call: " + camController.myUserID);
				
				phpRequest = new URLRequest(chatProcessUrl);
				phpLoader = new URLLoader();
		
				vars = new URLVariables();
				vars.var1 = currentUser;
				vars.var2 = "/private " + camController.userToInvite + " _cam_" + camController.myUserID;

				phpRequest.data = vars;
				phpRequest.method = URLRequestMethod.POST;
		
				phpLoader.load(phpRequest);
				phpLoader.addEventListener(Event.COMPLETE, onSendPrivateMessageComplete);
				phpLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			}
			
			function closeCamWindow(event:Event):void
			{
				camController.visible = false;
			}
			
			
			
			
			
			
			
			
			
			
			
			
			
			


// Error Handlers
// ***************************************************************************************************************************************
// ***************************************************************************************************************************************
// ***************************************************************************************************************************************			
		
			function ioErrorHandler(event:IOErrorEvent):void 
			{
					
			}
	    }
	}
}
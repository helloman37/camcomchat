package
{
	import com.tokbox.TB;
	import com.tokbox.events.ConnectionEvent;
	import com.tokbox.events.DevicePanelEvent;
	import com.tokbox.events.ExceptionEvent;
	import com.tokbox.events.PublisherEvent;
	import com.tokbox.events.SessionConnectEvent;
	import com.tokbox.events.SessionDisconnectEvent;
	import com.tokbox.events.StreamEvent;
	import com.tokbox.events.StreamPropertyChangedEvent;
	import com.tokbox.model.DevicePanel;
	import com.tokbox.model.Publisher;
	import com.tokbox.model.Session;
	import com.tokbox.model.Stream;
	import com.tokbox.model.Subscriber;
	import com.tokbox.model.SessionConnection;
	import com.tokbox.model.SessionConnectProperties;
	import com.tokbox.model.ConnectionQuality;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;	
	import flash.media.Camera;
	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.URLRequestMethod;
	
	import flash.events.FullScreenEvent;
	import flash.system.Capabilities;
	import flash.display.StageDisplayState;
	
	public class CamController extends MovieClip
	{	
		private var stageRef:Stage;
		public var userID:String;
		public var myUserID:String;
		public var myUsername:String;
		public var userToInvite:String;
		public var videoChatStatus:String;
		public var callStatus:String = "inactive";
		public var chatStatus:String = "notchatting";
		
		public var camSessionID:String;
		public var camSessionToken:String;
		
		private var vars:URLVariables;
		private var phpRequest:URLRequest;
		private var phpLoader:URLLoader;
		private var phpResultVars:URLVariables;
		
		private var userCamContainer:UserCamContainer;
		private var myCamContainer:MyCamContainer;
		private var myCamLoader:MyCamLoader;
		
		private var myCamLoaderTimer:Timer = new Timer(1000);
		private var myCamLoaderCounter:Number = 0;
		
		private var userIDLoaderTimer:Timer = new Timer(100);
		public var streamStorred:*;
		
		private var API_KEY:String;
		private var SESSION_ID:String;
		private var TOKEN:String;
		
		private var session:Session;
		private var publisher:Publisher;
		private var subscriber:Subscriber;
		private var publisherClone:Subscriber;
		
		public function CamController(stageRef:Stage, _userID:String, _camSessionID:String, _camSessionToken:String, _camSessionAPI:String)
		{
			this.stageRef = stageRef;
			userID = _userID;
			
			API_KEY = _camSessionAPI;
			SESSION_ID = _camSessionID;
			TOKEN = _camSessionToken;
			
			initializeUI();
		}
		
		private function initializeUI()
		{
			userCamContainer = new UserCamContainer();
			userCamContainer.x = 7;
			userCamContainer.y = 37;
			addChild(userCamContainer);
				
			myCamContainer = new MyCamContainer();
			myCamContainer.x = 13;
			myCamContainer.y = 225;
			addChild(myCamContainer);

			callEndButton.visible = false;
			callStartButton.visible = true;
			callStartButton.addEventListener(MouseEvent.CLICK, onStartCall);
			
			fullScreen_btn.visible = true;
			fullScreen_btn.alpha = 0.5;
			fullScreen_btn.addEventListener(MouseEvent.CLICK, onClickFullScreen);
			stageRef.addEventListener(FullScreenEvent.FULL_SCREEN, onFullscreen);
			
			close_btn.addEventListener(MouseEvent.CLICK, onEndCall);
			
			videoCallStatus_txt.visible = false;
		
			videoCallDragBox_mc.addEventListener(MouseEvent.MOUSE_DOWN, dragBox);
			videoCallDragBox_mc.addEventListener(MouseEvent.MOUSE_UP, dropBox);
			
			session = TB.initSession(SESSION_ID);
			
			TB.addEventListener(ExceptionEvent.EXCEPTION, sessionErrorHandler);
			
			session.addEventListener(SessionConnectEvent.CONNECTED, sessionConnectedHandler);
			session.addEventListener(StreamEvent.CREATED, streamCreatedHandler);
			session.addEventListener(StreamPropertyChangedEvent.STREAM_PROPERTY_CHANGED, streamPropertyHandler); 
			session.addEventListener(StreamEvent.DESTROYED, streamDestroyedHandler);
		}
		
		private function onClickFullScreen(event:MouseEvent):void 
		{
			if (subscriber)
			{
				stageRef.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			}
		}
		
		private function onFullscreen(event:FullScreenEvent):void 
		{
			if (event.fullScreen) 
			{								
				if (subscriber)
				{
					subscriber.height = Capabilities.screenResolutionY;
					subscriber.width = Capabilities.screenResolutionX;
					subscriber.x = 0;
					subscriber.y = 0;
					stageRef.addChild(subscriber);
					
					dispatchEvent(new Event("placePrivateChatFullScreen"));
				}
				if (publisherClone)
				{
					publisherClone.width = 240;
					publisherClone.height = 180;
					publisherClone.x = 0;				
					publisherClone.y = Capabilities.screenResolutionY - 180;
					publisherClone.visible = true;		
					stageRef.addChild(publisherClone);
				}
			} 
			else 
			{
				if (subscriber)
				{
					subscriber.width = 299;
					subscriber.height = 249;
					subscriber.x = 1;
					subscriber.y = 1;
					userCamContainer.addChild(subscriber);
				}
				if (publisherClone)
				{
					publisherClone.visible = false;
				}
			}
		}

		private function sessionErrorHandler(event:ExceptionEvent):void
		{			
			trace("-> TokBox Error: " + event.code);
		}

		public function connectCamSession()
		{
			session.connect(API_KEY, TOKEN);
		}
		
		private function streamPropertyHandler(event:StreamPropertyChangedEvent):void 
		{
			try
			{
				trace(event.changedProperty);
				trace(event.stream.quality.networkQuality);
				trace(event.stream.quality.latency);
				trace(event.stream.quality.upBandwidth);
				trace(event.stream.quality.readyH264);
			}
			catch (err:TypeError) 
			{
				trace("-> No webcam or microphone detected");
			}
		}
		
		private function sessionConnectedHandler(event:SessionConnectEvent):void 
		{
			trace("-> Connected to TokBox");
			
			// Subscribe to all streams currently in the Session
			for (var i:int = 0; i < event.streams.length; i++) 
			{				
				addStream(event.streams[i]);
			}
		}
		
		private function streamCreatedHandler(event:StreamEvent):void 
		{
			// Subscribe to these newly created streams
			for (var i:int = 0; i < event.streams.length; i++)
			{
				addStream(event.streams[i]);
			}
		}
		
		private function userIDLoader(event:TimerEvent):void
		{
			//trace("------------- 2. User ID:" + userID);
			
			if(userID == "" || userID == "none")
			{

			}
			else
			{				
				if (streamStorred.connection.connectionId == userID)
				{
					subscriber = session.subscribe(streamStorred);
					subscriber.width = 299;
					subscriber.height = 249;
					subscriber.x = 1;
					subscriber.y = 1;
					userCamContainer.addChild(subscriber);
					
					subscriber.subscribeToAudio(true);
					subscriber.setAudioVolume(90);
					subscriber.subscribeToVideo(true);
										
					flashSettingWindow_mc.visible = false;
					userStatus_txt.visible = false;
					
					fullScreen_btn.alpha = 1;
					
					userIDLoaderTimer.removeEventListener(TimerEvent.TIMER, userIDLoader);
					userIDLoaderTimer.stop();
				}
			}
		}
		
		private function addStream(stream:Stream):void 
		{			
			trace("-> Stream added: " + stream.connection.connectionId);
			
			if (stream.connection.connectionId == session.connection.connectionId) 
			{
				publisherClone = session.subscribe(stream);
				publisherClone.width = 2;
				publisherClone.height = 2;
				publisherClone.x = 0;
				publisherClone.y = 0;
				publisherClone.visible = false;
				stageRef.addChild(publisherClone);
				
				/*myCamLoader = new MyCamLoader();
				myCamLoader.x = 1;
				myCamLoader.y = 1;
				myCamContainer.addChild(myCamLoader);
				
				myCamLoaderTimer.addEventListener(TimerEvent.TIMER, myCamLoaderCountdown);
				myCamLoaderTimer.start();*/
				
				publisherClone.subscribeToAudio(false);
				publisherClone.subscribeToVideo(true);
				
				chatStatus = "chatting";
				
				flashSettingWindow_mc.visible = false;
				videoCallStatus_txt.visible = false;
				userStatus_txt.visible = true;
				userStatus_txt.htmlText = "<b>Waiting for user to accept call...</b>";
				
				callEndButton.visible = true;
				callEndButton.addEventListener(MouseEvent.CLICK, onEndCall);
				
				fullScreen_btn.visible = true;
				fullScreen_btn.alpha = 1;
			}

			//trace("------------- 1. User ID:" + userID);
			//trace("Stream ID: " + stream.connection.connectionId + " = User ID: " + userID + " = MyID: " + myUserID);
			
			if(userID == "" || userID == "none")
			{
				streamStorred = stream;
				
				userIDLoaderTimer.addEventListener(TimerEvent.TIMER, userIDLoader);
				userIDLoaderTimer.start();
			}
			else
			{
				streamStorred = null;
				
				userIDLoaderTimer.removeEventListener(TimerEvent.TIMER, userIDLoader);
				userIDLoaderTimer.stop();
				
				if (stream.connection.connectionId == userID)
				{
					subscriber = session.subscribe(stream);
					subscriber.width = 299;
					subscriber.height = 249;
					subscriber.x = 1;
					subscriber.y = 1;
					userCamContainer.addChild(subscriber);
					
					subscriber.subscribeToAudio(true);
					subscriber.setAudioVolume(90);
					subscriber.subscribeToVideo(true);
					
					flashSettingWindow_mc.visible = false;
					userStatus_txt.visible = false;
					
					fullScreen_btn.alpha = 1;
				}
			}
		}
		
		private function myCamLoaderCountdown(event:TimerEvent):void
		{
			myCamLoaderCounter ++;
						
			if(myCamLoaderCounter >= 3)
			{				
				myCamLoaderCounter = 0;
				myCamContainer.removeChild(myCamLoader);
				
				myCamLoaderTimer.stop();
				myCamLoaderTimer.removeEventListener(TimerEvent.TIMER, myCamLoaderCountdown);
			}
		}
		
		private function onStartCall(event:MouseEvent):void 
		{
			if (!publisher) 
			{
				if (Camera.names.length != 0) 
				{
					callStartButton.removeEventListener(MouseEvent.CLICK, onStartCall);
					callStartButton.visible = false;
					fullScreen_btn.visible = false;
					
					flashSettingWindow_mc.visible = false;
					
					videoCallStatus_txt.visible = true;
					videoCallStatus_txt.htmlText = "<b>Connecting, please wait...</b>"; 
					
					publisher = session.publish();
					publisher.width = 55;
					publisher.height = 55;
					publisher.x = 1;
					publisher.y = 1;
					myCamContainer.addChild(publisher);
										
					publisher.publishAudio(true);
					publisher.publishVideo(true);
					publisher.setMicrophoneGain(50);
					
					myUserID = session.connection.connectionId;
					dispatchEvent(new Event("sendVideoCallInvitation"));
				}
				else 
				{
					callStartButton.removeEventListener(MouseEvent.CLICK, onStartCall);
					callStartButton.visible = false;
					fullScreen_btn.visible = false;
					
					videoCallStatus_txt.visible = true;
					videoCallStatus_txt.htmlText = "<b>Please connect your webcam!</b>";
				}
			}
		}
		
		private function onEndCall(event:MouseEvent):void 
		{
			killVideoCall();
		}
		
		public function killVideoCall()
		{
			if (subscriber)
			{				
				if(userCamContainer.numChildren > 0)
				{
					while(userCamContainer.numChildren > 0)
					{
						userCamContainer.removeChildAt(0);
					}
				}
				subscriber.subscribeToAudio(false);
				subscriber.subscribeToVideo(false);
				session.unsubscribe(subscriber);
			}
			subscriber = null;			
			
			if (publisherClone)
			{				
				stageRef.removeChild(publisherClone);
				publisherClone.subscribeToAudio(false);
				publisherClone.subscribeToVideo(false);
				session.unsubscribe(publisherClone);
			}
			publisherClone = null;
			
			if (publisher)
			{
				callEndButton.visible = false;
				callEndButton.removeEventListener(MouseEvent.CLICK, onEndCall);

				session.unpublish(publisher);
			}
			publisher = null;
			
			stageRef.displayState = StageDisplayState.NORMAL;
			
			callStatus = "inactive";
			userID = "";
			userToInvite = "";
			myUsername = "";
			videoChatStatus = "";
			chatStatus = "notchatting";
			
			fullScreen_btn.alpha = 0.5;
			
			dispatchEvent(new Event("closeCamWindow"));
		}

		private function streamDestroyedHandler(event:StreamEvent):void 
		{
			for (var i:int = 0; i < event.streams.length; i++)
			{
				killStream(event.streams[i]);
			}
		}
		
		private function killStream(stream:Stream):void 
		{			
			trace("-> User left video call: " + stream.connection.connectionId);
			
			if(stream.connection.connectionId == userID)
			{
				if (publisher)
				{	
					session.unpublish(publisher);
				}
				publisher = null;
				
				if (subscriber)
				{
					if(userCamContainer.numChildren > 0)
					{
						while(userCamContainer.numChildren > 0)
						{
							userCamContainer.removeChildAt(0);
						}
					}
					subscriber.subscribeToAudio(false);
					subscriber.subscribeToVideo(false);
					session.unsubscribe(subscriber);
				}
				subscriber = null;
				
				if (publisherClone)
				{				
					stageRef.removeChild(publisherClone);
					publisherClone.subscribeToAudio(false);
					publisherClone.subscribeToVideo(false);
					session.unsubscribe(publisherClone);
				}
				publisherClone = null;
				
				stageRef.displayState = StageDisplayState.NORMAL;
				
				callStatus = "inactive";
				userID = "";
				userToInvite = "";
				myUsername = "";
				videoChatStatus = "";
				chatStatus = "notchatting";
				
				fullScreen_btn.alpha = 0.5;
				
				flashSettingWindow_mc.visible = false;
				userStatus_txt.visible = true;
				userStatus_txt.htmlText = "<b>User has left the call...</b>";
			}
		}
		
		public function reset()
		{
			callEndButton.visible = false;
			callEndButton.removeEventListener(MouseEvent.CLICK, onEndCall);
			
			callStartButton.visible = true;
			callStartButton.addEventListener(MouseEvent.CLICK, onStartCall);
			
			fullScreen_btn.visible = true;
			fullScreen_btn.alpha = 0.5;
			
			videoCallStatus_txt.visible = false;
			
			userStatus_txt.htmlText = "";
			userStatus_txt.visible = false;
			flashSettingWindow_mc.visible = true;
		}
		
		private function dragBox(event:MouseEvent):void
		{
			stage.setChildIndex(event.target.parent, stage.numChildren - 1);
			event.target.parent.startDrag();
		}
					
		private function dropBox(event:MouseEvent):void
		{
			event.target.parent.stopDrag();
		}
			
	} 
}

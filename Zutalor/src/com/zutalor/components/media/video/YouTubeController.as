package com.zutalor.components.media.video 
{
	import com.zutalor.events.MediaEvent;
	import com.zutalor.events.MediaLoadProgressEvent;
	import com.zutalor.events.MediaPlayProgressEvent;
	import com.zutalor.interfaces.IMediaController;
	import com.zutalor.ui.DrawGraphics;
	import com.zutalor.utils.DisplayObjectUtils;
	import com.zutalor.utils.ScaleTo;
	import com.soulwire.utils.display.DisplayUtils;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.utils.setTimeout;	
	import flash.utils.Timer;
	import net.guttershark.managers.AssetManager;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class YouTubeController extends MediaController implements IMediaController //TODO This module must be upgraded to current version of engine.
	{	
		private var _width:int;
		private var _height:int;
		
		private var url:String;
		private var _metadata:Object;
		private var _view:DisplayObjectContainer;
		private var _url:String;
		private var checkTimer:Timer;		
		private var _video:Sprite;
		
		private var loader:Loader;
		private var player:Object;	
		
		private var loadCompleteDispatched:Boolean;
		private var _waitingForPlayerToLoad:Boolean;
		private var _volumeToSetOnPlayerLoad:Number;
		private var _positionToSetOnPlayerLoad:Number;
		private var _playOnPlayerLoad:Boolean;
		
		private var _loop:int;
		
		override public function YouTubeController(updateIntervalMS:int = 400) 
		{
			super();
			_volumeToSetOnPlayerLoad = 0;
			_positionToSetOnPlayerLoad = -1;
			_playOnPlayerLoad = false;
			
			_video = new Sprite();
			Security.allowDomain("www.youtube.com");
			loader = new Loader();
			_video.visible = false;			
			loader.contentLoaderInfo.addEventListener(Event.INIT, onLoaderInit, false, 0, true);
			loader.load(new URLRequest("http://www.youtube.com/apiplayer?version=3"));
			if (updateIntervalMS)
			{
				checkTimer=new Timer(updateIntervalMS);
				checkTimer.addEventListener(TimerEvent.TIMER, ontick, false, 0, true);
			}
		}
		
		private function onLoaderInit(event:Event):void 
		{
			_video.addChild(loader);
			loader.content.addEventListener("onReady", onPlayerReady, false, 0, true);
			loader.content.addEventListener("onError", onPlayerError, false, 0, true);
			loader.content.addEventListener("onStateChange", onPlayerStateChange, false, 0, true);
			loader.content.addEventListener("onPlaybackQualityChange",onVideoPlaybackQualityChange, false, 0, true);
		}

		private function onPlayerReady(event:Event):void {
			
			loader.content.removeEventListener("onReady", onPlayerReady);
			//trace("player ready:", Object(event).data);
			player = loader.content;
			if (_waitingForPlayerToLoad)
				_load();
		}		
				
		override public function load(view:DisplayObjectContainer, url:String, width:int, height:int, loop:int = 0, loopDelay:Number = 0):void
		{	
			_width = width;
			_height = height;
			_loop = loop;
			_view = view;
			_url = url;
			loadCompleteDispatched = false;
									
			if (this.url && this.url == url)
				return;
			
			this.url = url;
		
			if (_view)
				DisplayObjectUtils.removeAllChildren(view);
			
				
			if (!player)
				_waitingForPlayerToLoad = true;
			else
				_load();	
		}
		
		private function _load():void
		{
			player.setSize(_width, _height);
			player.cueVideoByUrl(url, 0);
			if (_volumeToSetOnPlayerLoad)
				volume = _volumeToSetOnPlayerLoad;
			if (_positionToSetOnPlayerLoad != -1)
				seek(_positionToSetOnPlayerLoad);
			if (_playOnPlayerLoad)
				play();
			if (checkTimer)
				checkTimer.start();			
		}

		private function onPlayerError(event:Event):void {
			// Event.data contains the event parameter, which is the error code
			trace("player error:", Object(event).data);
		}

		private function onPlayerStateChange(event:Event):void
		{
			switch(Object(event).data)
			{
				case 0: // ended
					if (_loop || _loop == -1)
					{
						seek(0);
						play();
					}
					if (_loop > 0)
						_loop--;
					else if (_loop == 0)	
					{
						seek(0);
						stop();
						dispatchEvent(new MediaEvent(MediaEvent.STOP));
						dispatchEvent(new MediaEvent(MediaEvent.PLAY_COMPLETE));		
					}
					break;
				case 1 : // playing
					dispatchEvent(new MediaEvent(MediaEvent.PLAY));
					dispatchEvent(new MediaEvent(MediaEvent.BUFFER_FULL));					
					_video.visible = true;					
					break;
				case 2: // paused
					dispatchEvent(new MediaEvent(MediaEvent.PAUSE));	
					break;	
				case 5 : // video cued
					_view.addChild(_video);
					dispatchEvent(new MediaEvent(MediaEvent.BUFFER_FULL));
					break;
			}
		}

		private function onVideoPlaybackQualityChange(event:Event):void {
			// Event.data contains the event parameter, which is the new video quality
			//trace("video quality:", Object(event).data);
		}
	
		override public function set width(w:int):void
		{
			player.setSize(w, _height)
		}
		
		override public function set height(h:int):void
		{
			player.setSize(_width, h);
		}
		
		override public function set volume(volume:Number):void
		{
			if (player)
				player.setVolume(int(volume * 100));
			else
				_volumeToSetOnPlayerLoad = volume;
		}
		
		override public function get volume():Number
		{
			return player.getVolume() / 100;
		}
								
		override public function get isPlaying():Boolean
		{
			if (!player)
				return false;
			else
				if (player.getPlayerState() == 1)
					return true;
				else
					return false;
		}
				
		override public function play():void
		{
			if (player)
			{
				player.playVideo();
				dispatchEvent(new MediaEvent(MediaEvent.PLAY));
			}
			else 
				_playOnPlayerLoad = true;
		}
		
		override public function pause():void
		{
			if (player)
			{
				player.pauseVideo();
				dispatchEvent(new MediaEvent(MediaEvent.PAUSE));
			}
		}	
		
		override public function stop():void
		{
			if (player)
			{
				player.stopVideo();
				player.seekTo(0);
				player.stopVideo();
				dispatchEvent(new MediaEvent(MediaEvent.STOP));
			}
		}
		
		override public function forward(stepSeconds:Number=2):void
		{
			player.seekTo(currentTime + (stepSeconds * 1000), false); //TODO second parameter is seek ahead...which should be set according to mouse state. 
		}

		override public function rewind(stepSeconds:Number=2):void
		{
			player.seekTo(currentTime - (stepSeconds * 1000));
		}
		
		override public function get currentTime():Number
		{
			return player.getCurrentTime();
		}
		
		override public function get totalTime():Number
		{
			return player.getDuration();
		}
		
		override public function seek(time:Number):void
		{
			if (player)
				player.seekTo(time);
			else
				_positionToSetOnPlayerLoad = time;
		}

		override public function seekToPercent(percent:Number):void
		{
			player.seekTo(player.getDuration()*percent);
		}

		override public function get percentPlayed():Number
		{
			return player.getCurrentTime() / player.getDuration();
		}
				
		override public function get percentLoaded():Number
		{
			return player.getVideoBytesLoaded() / player.getVideoBytesTotal();
		}

		override public function get percentBuffered():Number
		{
			if (player.getPlayerState() == 3)
				return 0;
			else
				return 1;
		}
				
		override public function get metadata():Object
		{
			return _metadata;
		}

		override public function dispose():void
		{
			stop();
			player.destroy(); //TODO Remove event listeners
			loader.content.removeEventListener("onError", onPlayerError);
			loader.content.removeEventListener("onStateChange", onPlayerStateChange);
			loader.content.removeEventListener("onPlaybackQualityChange",onVideoPlaybackQualityChange);			
		}
		
		public function onXMPData(e:*):void
		{
			//trace("WARNING: XMP Data received, but this FLV class doesn't implement it yet.");
		}
		
		public function onCuePoint(infoObject:Object):void
		{
		}
		
		public function onMetaData(metadata:Object):void
		{
		
		}
		
		override public function stopTimer():void
		{
			if (checkTimer)
				checkTimer.stop();
		}		
		
		// PRIVATE METHODS
		
		private function ontick(te:TimerEvent):void
		{
			dispatchEvent(new MediaPlayProgressEvent(MediaPlayProgressEvent.PROGRESS, totalTime, currentTime));
			
			if (percentLoaded >= 1  && !loadCompleteDispatched) 
			{
				loadCompleteDispatched = true;
				dispatchEvent(new MediaEvent(MediaEvent.LOAD_COMPLETE));	
			}
			else if (!loadCompleteDispatched)
				dispatchEvent(new MediaLoadProgressEvent(MediaLoadProgressEvent.PROGRESS, percentLoaded));				
		}
						
		private function startTimer():void
		{
			if (checkTimer)
				if (!checkTimer.running)
					checkTimer.start();
		}
		
	}
}		
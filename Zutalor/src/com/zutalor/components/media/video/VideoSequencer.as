package com.zutalor.components.media.video
{
	
	import com.zutalor.application.Application;
	import com.zutalor.components.media.video.VideoPlayer;
	import com.zutalor.events.MediaEvent;
	import com.zutalor.positioning.Aligner;
	import com.zutalor.properties.PropertyManager;
	import com.zutalor.translate.Translate;
	import com.zutalor.utils.ArrayUtils;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.MathG;
	import com.zutalor.utils.Scale;
	import com.zutalor.utils.StageRef;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	
	final public class VideoSequencer
	{
		private var _videoPlayer:VideoPlayer;
		private var _vpOne:VideoPlayer;
		private var _vpTwo:VideoPlayer;
		private var _nextVideoPlayer:int = 1;
		private var _curVidInSeries:int;
		private var _curVidoSettings:VideoSettings;
		private var _curVidoSettingsIndex:int;
		private var _randomize:Boolean;
		private var _videos:PropertyManager;
		private var _videoPath:String;
		private var videoWidth:Number;
		private var videoHeight:Number;
		private var videoX:Number;
		private var videoY:Number;
		
		private static const FADE_IN_TIME:int = 5;
	
		public function VideoSequencer(videoPath:String, randomize:Boolean = false)
		{
			_videoPath = videoPath;
			_randomize = randomize;
			_construct();
		}
		
		private function _construct():void
		{
			var tMeta:XML;
			
			_vpTwo = new VideoPlayer("Vid2");
			_vpOne = new VideoPlayer("Vid1");			
			tMeta = XML(Translate.getMetaByName("videos"));
			_videos = new PropertyManager(VideoSettings);
			_videos.parseXML(tMeta.videos, "video");
			
			parseVideoUrls();
			
			if (_randomize)
				_curVidoSettingsIndex = MathG.rand(0, _videos.length - 1);
			else
				_curVidoSettingsIndex = 0;
			
			_curVidoSettings = _videos.getPropsByIndex(_curVidoSettingsIndex);
		}	
		
		// PUBLIC METHODS
		
		public function dispose():void
		{
			_vpOne.removeEventListener(MediaEvent.COMPLETE, onPlaybackComplete);
			_vpTwo.removeEventListener(MediaEvent.COMPLETE, onPlaybackComplete);
		}				
		
		public function get videoList():Array
		{
			var list:Array = [];
			
			for (var i:int = 0; i < _videos.length; i++ )
				list.push(_videos.getPropsByIndex(i).name);
				
			return videoList;	
		}
		
		public function get curVideoIndex():int
		{
			return _curVidoSettingsIndex;
		}
		
		public function next():void
		{
			if (_curVidoSettingsIndex == _videos.length - 1)
				_curVidoSettingsIndex = 0;
			else
				_curVidoSettingsIndex += 1;
				
			cueVideo();
		}
		
		public function previous():void
		{
			if (_curVidoSettingsIndex > 0)
				_curVidoSettingsIndex--;
			else
				_curVidoSettingsIndex = _videos.length - 1;
			
			cueVideo();
		}
				
		public function stop(fadeSeconds:Number, onComplete:Function = null):void
		{
			_videoPlayer.removeEventListener(MediaEvent.COMPLETE, onPlaybackComplete);
			_videoPlayer.stop(fadeSeconds, onStopComplete);
		
			if (_videoPlayer == _vpOne)
				_vpTwo.visible = false;
			else if (_videoPlayer == _vpTwo)
				_vpOne.visible = false;
					
			function onStopComplete():void
			{
				_nextVideoPlayer = 1;
				_videoPlayer.visible = false;
				if (onComplete != null)
					onComplete();
			}	
		}
		
		public function play(fadeInSeconds:Number = 0):void
		{	
			initVideoParameters();				
			chooseVideoPlayer();
			_curVidInSeries = 0;
			if (_curVidoSettings.randomize)
				ArrayUtils.shuffle(_curVidoSettings.urls);
			_videoPlayer.addEventListener(MediaEvent.COMPLETE, onPlaybackComplete);
			_videoPlayer.load(_videoPath + _curVidoSettings.urls[_curVidInSeries], videoWidth, videoHeight, videoX, videoY);
			_videoPlayer.viewFadeIn = fadeInSeconds;
			_videoPlayer.play();
		}
		
		public function jog(speed:Number = 2):void
		{
			if (speed)
				MasterClock.registerCallback(j, true, 400);
			else
				MasterClock.unRegisterCallback(j);
			
			function j():void
			{
				_videoPlayer.seek(_videoPlayer.currentTime + speed);
			}
		}
		
		public function get videoName():String
		{
			return _curVidoSettings.name;
		}
		
		// PRIVATE METHODS
		
		private function cueVideo():void
		{
			if (_videoPlayer)
			{
				_videoPlayer.removeEventListener(MediaEvent.COMPLETE, onPlaybackComplete);
				if (_videoPlayer.isPlaying)
					stop(0, play);
			}	
			_curVidoSettings = _videos.getPropsByIndex(_curVidoSettingsIndex);
		}
		
		private function initVideoParameters():void
		{
			var scale:Number;
			var aligner:Aligner = new Aligner();
			var dh:int;
			var dw:int;
			var r:Rectangle 
			
			videoWidth = dw = Application.settings.designWidth;
			videoHeight = dh = Application.settings.designHeight;
			
			/*r = new Rectangle(0, 0, dw, dh);
			scale = aligner.alignObject(r, dw, dh);
			Scale.calcAppScale(StageRef.stage, dw, dh);*/
/*			
			videoHeight = r.height * scale * Scale.curAppScale;
			videoWidth = r.width * scale * Scale.curAppScale;
			videoX = r.x * Scale.curAppScale;
			videoY = r.y * Scale.curAppScale;			
*/
		}
		
		private function parseVideoUrls():void
		{
			var vs:VideoSettings;
			var urls:Array;
			
			for (var i:int = 0; i < _videos.length; i++)
			{
				urls = [];
				vs = _videos.getPropsByIndex(i);
				
				if (!vs.extension)
					vs.extension = "";
					
				if (vs.segments)
					for (var c:int = 0; c < vs.segments; c++)
						urls.push(vs.url + "-" + String(c + 1) + vs.extension);
				else
					urls.push(vs.url + vs.extension);
				
				if (vs.repeat)
					repeat();
					
				vs.urls = vs.urls.concat(urls);
			}
			
			function repeat():void
			{
				var repeating:Array = [];
				
				repeating = repeating.concat(urls);
				for (var i:int = 0; i < vs.repeat; i++)
					urls = urls.concat(repeating);
			}			
		}
			
		private function onPlaybackComplete(e:Event):void
		{
			_videoPlayer.viewFadeIn = 0;
			_videoPlayer.fadeOut = 0;
			
			if (_curVidInSeries == _curVidoSettings.urls.length - 1)
			{
				_curVidInSeries = 0;
				if (_curVidoSettings.randomize)
					ArrayUtils.shuffle(_curVidoSettings.urls);
			}
			else
				_curVidInSeries++;
			
			chooseVideoPlayer();
			_videoPlayer.load(_videoPath + _curVidoSettings.urls[_curVidInSeries], videoWidth, videoHeight, videoX, videoY);
			_videoPlayer.play();
		}
		
		private function chooseVideoPlayer():void
		{
			if (_videoPlayer)
				_videoPlayer.removeEventListener(MediaEvent.COMPLETE, onPlaybackComplete);
			
			if (_nextVideoPlayer == 1)
			{
				_nextVideoPlayer = 2;
				_videoPlayer = _vpOne;
			}
			else
			{
				_nextVideoPlayer = 1;
				_videoPlayer = _vpTwo;
			}
			_videoPlayer.addEventListener(MediaEvent.COMPLETE, onPlaybackComplete);
			StageRef.stage.addChild(_videoPlayer);
		}
	}
}
package com.zutalor.components.media.video
{
	import com.zutalor.components.media.base.MediaController;
	import com.zutalor.events.MediaEvent;
	import com.zutalor.interfaces.IMediaController;
	import com.zutalor.objectPool.ObjectPool;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.utils.Aligner;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.Resources;
	import com.zutalor.utils.Scale;
	import com.zutalor.utils.StageRef;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.StageVideoEvent;
	import flash.geom.Rectangle;
	import flash.media.SoundTransform;
	import flash.media.StageVideo;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamAppendBytesAction;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class VideoController extends MediaController implements IMediaController
	{
		private const _EMBEDDED:String = ".embedded";
		
		public var stream:NetStream;
		private var nc:NetConnection;
		private var videoDisplay:*;
		private var sv:StageVideo;
		
		private var _metadata:Object;
		private var lastSeekableTime:Number;
		
		private var _buffercount:int;
		private var _videoframerate:Number;
		
		private var _framerate:Number;
		
		override public function VideoController()
		{
			super();
			init();
		}
		
		private function init():void
		{
			_duration = 0;
		}
		
		override public function set width(n:Number):void
		{
			super.width = n;
			onStageVideoStateChange();
		}
		
		override public function set height(n:Number):void
		{
			super.height = n;
			onStageVideoStateChange();
		}
		
		override public function set x(n:Number):void
		{
			super.x = n;
			onStageVideoStateChange();
		}
		
		override public function set y(n:Number):void
		{
			super.y = n;
			onStageVideoStateChange();
		}
		
		override public function set framerate(fr:Number):void
		{
			if (fr > 0)
				_framerate = fr;
			else
				_framerate = 0;
		}
		
		override public function get framerate():Number
		{
			return _framerate;
		}
		
		override public function get hasAudio():Boolean
		{
			if (stream.audioCodec)
				return true;
			else
				return false;
		}
		
		override public function load(url:String, scaleToFit:Boolean, bufferSecs:Number):void
		{
			var s:Stage;
			
			_scaleToFit = scaleToFit;
			
			if (!bufferSecs)
				bufferSecs = 7;
			
			_paused = false;
			
			if (!nc)
			{
				nc = new NetConnection();
				nc.connect(null);
			}
			_url = url;
			if (stream)
				stream.close();
			else
			{
				stream = new NetStream(nc);
				stream.addEventListener(NetStatusEvent.NET_STATUS, onNSStatus, false, 0, true);
			}
			stream.client = this;
			stream.bufferTime = bufferSecs;
			
			s = StageRef.stage;
			if (Props.ap.stageVideoAvailable && Props.ap.useStageVideoIfAvailable)
			{
				//Alert.init(StageRef.stage);
				//Alert.show("using stage video");
				sv = ObjectPool.getStageVideo();
				sv.addEventListener(StageVideoEvent.RENDER_STATE, onStageVideoStateChange);
				sv.attachNetStream(stream);
				trace("using stage video");
			}
			else
			{
				sv = null;
				getSoftwarePlayer();
			}
			
			function getSoftwarePlayer():void
			{
				if (!videoDisplay)
				{
					videoDisplay = new Video(width, height);
					videoDisplay.smoothing = true;
				}
				else
					videoDisplay.clear();
				
				videoDisplay.attachNetStream(stream);
				view.addChild(videoDisplay);
			}
		}
		
		private function onStageVideoStateChange(event:StageVideoEvent = null):void
		{
			var rc:Rectangle;
			var scale:Number;
			
			if (sv)
			{
				scale = Scale.curAppScale;
				rc = new Rectangle(x * scale, y * scale, width * scale, height * scale);
				sv.viewPort = rc;
			}
		}
		
		override public function set volume(volume:Number):void
		{
			if (stream)
				stream.soundTransform = new SoundTransform(volume);
		}
		
		override public function get volume():Number
		{
			if (stream)
			{
				return stream.soundTransform.volume;
			}
			else
				return 0;
		}
		
		override public function get isPlaying():Boolean
		{
			if (_isPlaying && !_paused)
				return true;
			else
				return false;
		
		}
		
		override public function get isPaused():Boolean
		{
			return _paused;
		}
		
		override public function play(start:Number = 0):void
		{
			var className:Array;
			
			super.play(start);
			if (_url)
			{
				if (_paused)
				{
					stream.resume();
					_isPlaying = true;
					_paused = false;
				}
				else
				{
					if (_url.indexOf(_EMBEDDED) != -1)
					{
						stream.close();
						className = _url.split(".");
						var ba:ByteArray = Resources.createInstance(className[0]);
						stream.play(null);
						stream.appendBytes(ba);
						stream.appendBytesAction(NetStreamAppendBytesAction.RESET_BEGIN);
					}
					else
					{
						if (stream.bytesLoaded > 0)
						{
							if (start)
								seek(start);
							else
								seek(0);
						}
						else
						{
							stream.close();
							stream.play(_url);
						}
					}
				}
				_isPlaying = true;
			}
		}
		
		override public function pause():void
		{
			if (!stream)
				return;
			
			if (!_paused && _isPlaying)
			{
				super.pause();
				_paused = true;
				stream.pause();
			}
		}
		
		override public function stop():void
		{
			
			
			if (_isPlaying)
			{
				if (_framerate < _videoframerate)
					MasterClock.stop(onFrameCallback);
				
				//if (returnToZeroOnStop) 
				//	stream.seek(0);
				
				if (stream)
				{
					stream.pause();
					stream.close();
				}
				_paused = false;
				_isPlaying = false;
				super.stop();
			}
		}
		
		override public function onPlaybackComplete(e:Event = null):void
		{
			super.onPlaybackComplete(e);
			MasterClock.stop(onPlaybackComplete);
		}
		
		override public function closeStream():void
		{
			if (stream)
				stream.close();
		}
		
		override public function forward(stepSeconds:Number = 2):void
		{
			if (!stream)
				return;
			
			seek(currentTime + (stepSeconds));
		}
		
		override public function rewind(stepSeconds:Number = 2):void
		{
			if (!stream)
				return;
			
			seek(currentTime - (stepSeconds));
		}
		
		override public function get currentTime():Number
		{
			return stream.time;
		}
		
		override public function get totalTime():Number
		{
			return _duration;
		}
		
		override public function seek(time:Number):void
		{
			stream.seek(time);
			//trace(url, "seek");
		}
		
		override public function seekToPercent(percent:Number):void
		{
			seek(_duration * percent);
		}
		
		override public function get percentPlayed():Number
		{
			return stream.time / _duration;
		}
		
		override public function get percentLoaded():Number
		{
			if (stream)
				return stream.bytesLoaded / stream.bytesTotal;
			else
				return 0;
		}
		
		override public function get percentBuffered():Number
		{
			if (stream)
			{
				var total:Number = Math.min(_duration, stream.bufferTime);
				var b:Number = Math.min(Math.round(stream.bufferLength / total), 1);
				return (isNaN(b)) ? 0 : b;
			}
			else
				return 0;
		}
		
		override public function get metadata():Object
		{
			return _metadata;
		}
		
		override public function dispose():void
		{
			MasterClock.unRegisterCallback(onFrameCallback);
			if (sv)
				sv.removeEventListener(StageVideoEvent.RENDER_STATE, onStageVideoStateChange);
				
			if (stream)
			{
				stream.removeEventListener(NetStatusEvent.NET_STATUS, onNSStatus);
				stream.close();
			}
			if (videoDisplay)
				videoDisplay.clear();
			
			if (nc)
				nc.close();
			
			videoDisplay = null;
			stream = null;
			nc = null;
		}
		
		public function onXMPData(e:*):void
		{
			//trace("WARNING: XMP Data received, but this FLV class doesn't implement it yet.");
		}
		
		public function onPlayStatus(e:*):void
		{
			
		}
		
		public function onCuePoint(infoObject:Object):void
		{
			if (!_buffering)
				dispatchEvent(new MediaEvent(MediaEvent.CUEPOINT));
		}
		
		public function onMetaData(metadata:Object):void
		{
			var aligner:Aligner;
			
			aligner = new Aligner();
			if (metadata.framerate)
			{
				_metadata = metadata;
				_duration = metadata.duration;
				_videoframerate = metadata.framerate;
				lastSeekableTime = metadata.lastkeyframetimestamp;
				dispatchEvent(new MediaEvent(MediaEvent.METADATA));
				
				if (sv)
					onStageVideoStateChange();
				else
				{
					
					view.width = width;
					view.height = height;
					videoDisplay.width = metadata.width;
					videoDisplay.height = metadata.height;
					if (_scaleToFit)
						aligner.alignObject(videoDisplay, width, height, Aligner.FIT);
				}

				stream.resume();
				
				dispatchEvent(new MediaEvent(MediaEvent.PLAY));
				
				if (!_framerate)
					_framerate = _videoframerate;
				else if (_framerate < _videoframerate)
					MasterClock.registerCallback(onFrameCallback, true, 1000 / _framerate);
					
			}
		}
		
		// PRIVATE METHODS
		
		private function onFrameCallback():void
		{
			if (!_paused && _isPlaying)
			{
				_paused = true;
				stream.pause();
			}
			else
			{
				stream.resume();
				_paused = false;
			}
		}
		
		private function onNSStatus(stats:NetStatusEvent):void
		{
			//trace (_url, stats.info.code);
			switch (stats.info.code)
			{
				case "NetStream.Buffer.Empty": 
					_buffering = true;
					dispatchEvent(new MediaEvent(MediaEvent.BUFFER_EMPTY));
					break;
				case "NetStream.Buffer.Full": 
					dispatchEvent(new MediaEvent(MediaEvent.BUFFER_FULL));
					_buffering = false;
					break;
				case "NetStream.Buffer.Flush": 
					dispatchEvent(new MediaEvent(MediaEvent.BUFFER_FULL));
					_buffering = false;
					break;
				case "NetStream.Play.Start": 
					dispatchEvent(new MediaEvent(MediaEvent.BUFFER_FULL));
					_buffering = false;
					break;
				case "NetStream.Play.Stop": 
				case "NetStream.Play.Complete": 
					dispatchEvent(new MediaEvent(MediaEvent.BUFFER_FULL));
					_paused = false;
					_isPlaying = false;
					onPlaybackComplete();
					break;
				case "NetStream.Play.StreamNotFound": 
					dispatchEvent(new MediaEvent(MediaEvent.STREAM_NOT_FOUND));
					_isPlaying = false;
					onPlaybackComplete();
					break;
				case "NetStream.Seek.InvalidTime": 
					dispatchEvent(new MediaEvent(MediaEvent.SEEK_INVALID_TIME));
					break;
				case "NetStream.Seek.Notify": 
					dispatchEvent(new MediaEvent(MediaEvent.SEEK_NOTIFY));
					break;
				case "NetStream.Unpause.Notify": 
					break;
			
			}
		}
		
		private function resolveTime(time:Number):Number
		{
			var maxTime:Number = (!isNaN(lastSeekableTime)) ? lastSeekableTime : _duration;
			return Math.max(Math.min(time, maxTime), 0);
		}
	}
}
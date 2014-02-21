package com.zutalor.components.media.video
{
	import com.zutalor.application.Application;
	import com.zutalor.components.media.base.MediaController;
	import com.zutalor.events.MediaEvent;
	import com.zutalor.interfaces.IMediaController;
	import com.zutalor.objectPool.ObjectPool;
	import com.zutalor.utils.EmbeddedResources;
	import com.zutalor.widgets.RunTimeTrace;
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
		
		public var scaleToFit:Boolean = true;
		public var bufferSecs:Number = 11;
		
		override public function VideoController()
		{
			super();
			init();
		}
		
		private function init():void
		{
			_duration = 0;
		}
		
		override public function get hasAudio():Boolean
		{
			if (stream.audioCodec)
				return true;
			else
				return false;
		}
		
		override public function load(url:String, width:int, height:int, x:int=0, y:int=0):void
		{
			_scaleToFit = scaleToFit;
			
			_paused = false;
			if (!nc)
			{
				nc = new NetConnection();
				nc.connect(null);
			}
			_url = url;
			setupStream();
			view.x  = x;
			view.y = y;
			setupVideo();
			
			function setupStream():void
			{
				if (stream)
					stream.close();
				else
				{
					stream = new NetStream(nc);
					stream.addEventListener(NetStatusEvent.NET_STATUS, onNSStatus, false, 0, true);
				}	
				stream.client = this;
				stream.bufferTime = bufferSecs;
			}

			function setupVideo():void
			{
				if (Application.settings.stageVideoAvailable)
				{
					RunTimeTrace.show("stage video");
					sv = ObjectPool.getStageVideo();
					sv.addEventListener(StageVideoEvent.RENDER_STATE, onStageVideoStateChange);
					sv.attachNetStream(stream);
				}
				else
				{
					getSoftwarePlayer();
					sv = null;
				}
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
			
			function onStageVideoStateChange(event:StageVideoEvent = null):void
			{
				var rc:Rectangle;

				sv.removeEventListener(StageVideoEvent.RENDER_STATE, onStageVideoStateChange);
				rc = new Rectangle(0, 0, width, height);
				sv.viewPort = rc;
				sv.viewPort.x = view.x;
				sv.viewPort.y = view.y;
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
			var urls:Array;
			
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
						var ba:ByteArray = EmbeddedResources.createInstance(className[0]);
						stream.play();
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
							urls = _url.split(",");
							for (var i:int = 0; i < urls.length; i++)
								stream.play(urls[i]);
						}
					}
				}
				_isPlaying = true;
			}
		}
		
		public function appendStream(url:String):void
		{
			if (stream)
				stream.play(url);
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
			_metadata = metadata;
			_duration = metadata.duration;
			lastSeekableTime = metadata.lastkeyframetimestamp;
			dispatchEvent(new MediaEvent(MediaEvent.METADATA));
			
			stream.resume();
			dispatchEvent(new MediaEvent(MediaEvent.PLAY));
		}
		
		// PRIVATE METHODS
		
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
					dispatchEvent(new MediaEvent(MediaEvent.BUFFER_FLUSH));
					_buffering = false;
					break;
				case "NetStream.Play.Start":
					dispatchEvent(new MediaEvent(MediaEvent.PLAY));
					_buffering = false;
					break;
				case "NetStream.Play.Stop":
				case "NetStream.Play.Complete":
					onPlaybackComplete();
					break;
				case "NetStream.Play.StreamNotFound":
					dispatchEvent(new MediaEvent(MediaEvent.STREAM_NOT_FOUND));
					RunTimeTrace.show("Stream Not Found: " + _url);
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
package com.zutalor.components.media.base 
{
	import com.greensock.TweenMax;
	import com.zutalor.components.Component;
	import com.zutalor.components.interfaces.IComponent;
	import com.zutalor.events.MediaEvent;
	import com.zutalor.events.MediaLoadProgressEvent;
	import com.zutalor.interfaces.IMediaPlayer;
	import com.zutalor.properties.MediaProperties;
		import com.zutalor.view.properties.ViewItemProperties;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.ui.Spinner;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.ShowError;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class MediaPlayer extends Component implements IMediaPlayer, IComponent
	{	
		protected var mediaController:MediaController;
		protected var _volume:Number;

		private var _name:String;
		private var _url:String;
		private var _startDelay:Number;
		
		private var _viewFadeIn:Number;
		private var _audioFadeIn:Number;
		private var _fadeOut:Number;
		private var _overlap:Number;
		private var _start:Number;
		private var _end:Number;
		public var endVariance:Number;
		private var _loop:int;
		private var _loopDelay:Number;
		private var _loopDelayTimer:Timer;
		private var _bufferingTime:Number;	
		private var _playerType:String;
		private var _mpp:MediaProperties;
		
		protected static var _presets:PropertyManager;
				
		public function MediaPlayer(name:String)
		{
			super(name);
		}
		
		public static function register(presets:XMLList):void
		{	
			if (!_presets)
				_presets = new PropertyManager(MediaProperties);
			
			_presets.parseXML(presets);
		}
		
		override public function render(viewItemProperties:ViewItemProperties = null):void
		{
			var mpp:MediaProperties;
			
			super.render(viewItemProperties);
			_mpp = _presets.getPropsByName(vip.mediaPreset);
			if (!_mpp)
				ShowError.fail(MediaPlayer,"No media preset " + vip.url);
						
			load(vip.url, _mpp.volume, int(vip.width), int(vip.height), _mpp.scaleToFit, _mpp.bufferTime);
			if (_mpp.controlsViewId)
				initTransport(_mpp.controlsViewId, _mpp.controlsContainerName);			
			
			if (vip.url)
			{
				if (_mpp.hideOnPlayComplete)
					addEventListener(MediaEvent.COMPLETE, hideMediaPlayerOnPlayComplete, false, 0, true);

				if (_mpp.autoPlay)
					play(_mpp.mediaFadeIn, _mpp.audioFadeIn, _mpp.fadeOut, 0, _mpp.startDelay);
			}
			else
				visible = false;	
		}
		
		// PROTECTED METHODS
				
		protected function onLoadProgress(e:MediaLoadProgressEvent):void { }
		protected function setPlayPauseButton(e:Event = null):void { }	
		
		protected function initialize(playerType:String, mediaController:MediaController):void
		{
			endVariance = 0;
			_playerType = playerType;	
			this.mediaController = mediaController;	
			mediaController.view = this;
			mediaController.addEventListener(MediaEvent.COMPLETE, onPlayComplete);
			mediaController.addEventListener(MediaEvent.STOP, onPlayComplete);
			mediaController.addEventListener(MediaEvent.BUFFER_FULL, onBufferFull, false, 0, true);
			mediaController.addEventListener(MediaEvent.BUFFER_EMPTY, onBufferEmpty, false, 0, true);
		}
		
		protected function onPlayStarted(me:MediaEvent=null):void
		{
			mediaController.removeEventListener(MediaEvent.PLAY, onPlayStarted);
			dispatchEvent(new MediaEvent(MediaEvent.PLAY));
			Spinner.hide();
			if (_viewFadeIn)
			{
				mediaController.view.alpha = 0;
				TweenMax.to(mediaController.view, _viewFadeIn, { alpha:1 } );
			}
			if (_audioFadeIn)
			{
				mediaController.volume = 0;
				TweenMax.to(mediaController, _audioFadeIn, { volume:_volume } );
			}
			else
				mediaController.volume = _volume;
				
			if (mediaController.totalTime)
				onTotalTimeFound()
			else
				MasterClock.registerCallback(onTotalTimeFound, true, 1000);		
				
			setPlayPauseButton();	
		}		
		
		// PUBLIC METHODS
		
		public function load(url:String, defaultVolume:Number = 1, playerWidth:int = 0, 
							playerHeight:int = 0, scaleToFit:Boolean = true, bufferTime:Number=0):void
		{				
			_url = url;
			volume = defaultVolume;
			mediaController.returnToZeroOnStop = true;
			mediaController.width = playerWidth;
			mediaController.height = playerHeight;
			mediaController.load(url, scaleToFit, bufferTime);
		}	
		
		public function play(viewFadeIn:Number = 0, audioFadeIn:Number = 0, 
									fadeOut:Number = 0, overlap:Number = 0, startDelay:Number = 0,
									start:Number=0, end:Number = 0, loop:int=0, loopDelay:Number=0):void
		{
			_viewFadeIn = viewFadeIn;
			_audioFadeIn = audioFadeIn;
			_fadeOut = fadeOut;
			_overlap = overlap;
			_startDelay = startDelay;
			_start = start;	
			_end = end;
			_loop = loop;
			_loopDelay = loopDelay;

			if (_playerType == MediaProperties.PLAYER_AUDIO)
				mediaController.visible = false;
			else
				mediaController.visible = true;
			
			Spinner.show(2);
			
			if (!_fadeOut)
				_fadeOut = 0;

			mediaController.addEventListener(MediaEvent.PLAY, onPlayStarted);			
			
			if (startDelay) 
				MasterClock.callOnce(onPlayDelayed, startDelay * 1000);
			else	
				mediaController.play(_start);
				
			setPlayPauseButton();
		}
		
		public function pause():void
		{
			mediaController.pause();
			setPlayPauseButton();
		}
				
		public function seek(value:Number):void
		{
			mediaController.seek(value);
		}
				
		override public function stop(fadeOut:Number = 0):void
		{	
			MasterClock.unRegisterCallback(onEndClip);
			MasterClock.unRegisterCallback(onOverLapClip);
			
			if (fadeOut)
			{
				TweenMax.to(mediaController.view, fadeOut, { alpha:0, onComplete:onStopComplete } );
				TweenMax.to(mediaController, fadeOut, { volume:0 } );
			}
			else
				onStopComplete();
		}		
		
		override public function set width(n:Number):void
		{
			mediaController.width = n;
		}
		
		override public function get width():Number
		{
			return mediaController.width;
		}
		
		override public function set height(n:Number):void
		{
			mediaController.height = n;
		}
		
		override public function get height():Number
		{
			return mediaController.height;
		}
		
		override public function set x(n:Number):void
		{
			mediaController.x = n;
		}
		
		override public function set y(n:Number):void
		{
			mediaController.y = n;
		}
		
		override public function get x():Number
		{
			return mediaController.x;
		}
		
		override public function get y():Number
		{
			return mediaController.y;
		}
				
		public function get view():DisplayObject
		{
			return mediaController.view;
		}
		
		override public function set visible(v:Boolean):void
		{
			super.visible = mediaController.visible = v;
		}
		
		override public function get visible():Boolean
		{
			return mediaController.visible;
		}
			
		public function get playerType():String
		{
			return _playerType;
		}
		
		public function get url():String
		{
			return _url;
		}
		
		public function set framerate(fr:Number):void
		{
			mediaController.framerate = fr;
		}
		
		public function get framerate():Number
		{
			return mediaController.framerate;
		}
		
		public function set returnToZero(b:Boolean):void
		{
			mediaController.returnToZeroOnStop = b;
		}
		
		public function set totalTime(n:Number):void
		{
			mediaController.totalTime = n;
		}		
		
		public function get isPlaying():Boolean
		{
			return mediaController.isPlaying;
		}
								
		public function set volume(v:Number):void
		{
			_volume = v;
			mediaController.volume = v;
		}
		
		public function get volume():Number
		{
			return _volume;
		}

		override public function dispose():void
		{	
			mediaController.stop();			
			mediaController.removeEventListener(MediaEvent.COMPLETE, onPlayComplete);
			mediaController.removeEventListener(MediaEvent.STOP, onPlayComplete);
			mediaController.dispose();
			mediaController = null;			
		}		
						
		// PRIVATE METHODS
				
		private function initTransport(transportViewId:String, transportContainer:String):void {}		
		
		private function onTotalTimeFound():void
		{
			var end:Number;
			var interval:Number;
			
			if (mediaController.totalTime)
			{
				MasterClock.unRegisterCallback(onTotalTimeFound);
				end = mediaController.totalTime - mediaController.currentTime - _start - _end - endVariance;
	
				if (_overlap)
				{
					interval = end - _overlap; 
					MasterClock.registerCallback(onOverLapClip, true, interval * 1000);
				}
				interval = end - _fadeOut;
				if (interval > mediaController.currentTime)
					MasterClock.registerCallback(onEndClip, true, interval * 1000);
				else
					onEndClip();
			}
		}
		
		private function onEndClip():void
		{
			MasterClock.unRegisterCallback(onEndClip);
			stop(_fadeOut);
		}
		
		private function onOverLapClip():void
		{
			MasterClock.unRegisterCallback(onOverLapClip);
			if (_fadeOut)
				stop(_fadeOut)
			else
				MasterClock.callOnce(onOverlapComplete, _overlap);
			
			dispatchEvent(new MediaEvent(MediaEvent.OVERLAP));
		}
		
		private function onOverlapComplete():void
		{
			if (mediaController.isPlaying)
				stop();
		}
				
		private function onPlayDelayed():void
		{
			mediaController.play(_start);
		}
					
		private function onStopComplete():void
		{
			mediaController.stop();
			mediaController.volume = 1;
			cleanUpAfterStop();
		}
		
		private function cleanUpAfterStop():void
		{
			Spinner.hide();
			if (_playerType != MediaProperties.PLAYER_AUDIO)
				mediaController.visible = false;
			
			setPlayPauseButton();							
		}	
		
		private function onPlayComplete(me:MediaEvent):void
		{
			cleanUpAfterStop();
			dispatchEvent(new MediaEvent(MediaEvent.COMPLETE, 1));

			if (_loop || _loop == -1)
			{
				if (_loopDelay) 
				{
					//TODO Looping
					//_loopDelayTimer = new Timer(_loopDelay * 1000);
					//_loopDelayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onLoopDelayComplete);
					//_loopDelayTimer.start();
				}
				else
				{
					mediaController.play(0)
				}
			}
			if (_loop > 0)
				_loop--;
		}
		/*			
		private function onLoopDelayComplete(e:TimerEvent):void 
		{
			_loopDelayTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onLoopDelayComplete);
			_loopDelayTimer = null;
			
			if (url.indexOf(_EMBEDDED) != -1)
				play();
			else
				seek(0);			
		}
		*/
				
		private function onBufferFull(e:MediaEvent):void
		{
			var adjustment:int;
			
			if (_bufferingTime)
			{
				if (MasterClock.isRegistered(onEndClip))
					MasterClock.modifyInterval(onEndClip, _bufferingTime - getTimer());
				if (MasterClock.isRegistered(onOverLapClip))
					MasterClock.modifyInterval(onOverLapClip, _bufferingTime - getTimer());
				_bufferingTime = 0;
			}
			Spinner.hide();
		}

		private function onBufferEmpty(e:MediaEvent):void
		{
			_bufferingTime = getTimer();
			Spinner.show(2);
		}
		
		private function hideMediaPlayerOnPlayComplete(me:MediaEvent):void
		{
			me.target.visible = false;
		}
	}
}
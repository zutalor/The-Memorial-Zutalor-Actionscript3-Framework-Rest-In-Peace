package com.zutalor.components.media.base 
{
	import com.greensock.TweenMax;
	import com.zutalor.components.Component;
	import com.zutalor.components.interfaces.IComponent;
	import com.zutalor.components.media.base.MediaProperties;
	import com.zutalor.events.MediaEvent;
	import com.zutalor.events.MediaLoadProgressEvent;
	import com.zutalor.interfaces.IMediaPlayer;
	import com.zutalor.propertyManagers.PropertyManager;
	import com.zutalor.ui.Spinner;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.ShowError;
	import com.zutalor.view.properties.ViewItemProperties;
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
		private var _url:String;
		private var _playerType:String;
		private var _bufferingTime:int;	
		
		public var startDelay:Number;
		public var viewFadeIn:Number;
		public var audioFadeIn:Number;
		public var fadeOut:Number;
		public var overlap:Number;
		public var start:Number;
		public var end:Number;
		public var endVariance:Number;
		public var loop:int;
		public var loopDelay:Number;
		public var bufferTime:Number;
		public var scaleToFit:Boolean = true;
		
		private static var presets:PropertyManager;
				
		public function MediaPlayer(name:String)
		{
			super(name);
		}
		
		public static function registerPresets(options:Object):void
		{	
			if (!presets)
				presets = new PropertyManager(MediaProperties);
			
			presets.parseXML(options.xml[options.nodeId]);
		}
		
		override public function render(viewItemProperties:ViewItemProperties = null):void
		{
			var mpp:MediaProperties;
			
			super.render(viewItemProperties);
			mpp = presets.getPropsByName(vip.mediaPreset);
			if (!mpp)
				ShowError.fail(MediaPlayer,"No media preset " + vip.url);
						
			load(vip.url, mpp.volume);
			if (mpp.controlsViewId)
				initTransport(mpp.controlsViewId, mpp.controlsContainerName);			
			
			if (vip.url)
			{
				if (mpp.hideOnPlayComplete)
					addEventListener(MediaEvent.COMPLETE, hideMediaPlayerOnPlayComplete, false, 0, true);

				if (mpp.autoPlay)
				{
					viewFadeIn = mpp.mediaFadeIn;
					audioFadeIn = mpp.audioFadeIn;
					fadeOut = mpp.fadeOut;
					startDelay = mpp.startDelay;
					play();
				}
			}
			else
				visible = false;	
		}
		
		// PROTECTED METHODS
				
		protected function onLoadProgress(e:MediaLoadProgressEvent):void { }
		protected function setPlayPauseButton(e:Event = null):void { }	
		
		protected function initialize(_playerType:String, mediaController:MediaController):void
		{
			endVariance = 0;
			_playerType = _playerType;	
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
			if (viewFadeIn)
			{
				mediaController.view.alpha = 0;
				TweenMax.to(mediaController.view, viewFadeIn, { alpha:1 } );
			}
			if (audioFadeIn)
			{
				mediaController.volume = 0;
				TweenMax.to(mediaController, audioFadeIn, { volume:volume } );
			}
			else
				mediaController.volume = volume;
				
			if (mediaController.totalTime)
				onTotalTimeFound()
			else
				MasterClock.registerCallback(onTotalTimeFound, true, 1000);		
				
			setPlayPauseButton();	
		}		
		
		// PUBLIC METHODS
		
		public function load(url:String, defaultVolume:Number = 1):void
		{				
			url = url;
			volume = defaultVolume;
			mediaController.returnToZeroOnStop = true;
		
			mediaController.load(url, scaleToFit, bufferTime);
		}	
		
		public function play():void
		{
			Spinner.show(2);
			
			if (!fadeOut)
				fadeOut = 0;

			mediaController.addEventListener(MediaEvent.PLAY, onPlayStarted);			
			
			if (startDelay) 
				MasterClock.callOnce(onPlayDelayed, startDelay * 1000);
			else	
				mediaController.play(start);
				
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
			return url;
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
			volume = v;
			mediaController.volume = v;
		}
		
		public function get volume():Number
		{
			return volume;
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
				end = mediaController.totalTime - mediaController.currentTime - start - end - endVariance;
	
				if (overlap)
				{
					interval = end - overlap; 
					MasterClock.registerCallback(onOverLapClip, true, interval * 1000);
				}
				interval = end - fadeOut;
				if (interval > mediaController.currentTime)
					MasterClock.registerCallback(onEndClip, true, interval * 1000);
				else
					onEndClip();
			}
		}
		
		private function onEndClip():void
		{
			MasterClock.unRegisterCallback(onEndClip);
			stop(fadeOut);
		}
		
		private function onOverLapClip():void
		{
			MasterClock.unRegisterCallback(onOverLapClip);
			if (fadeOut)
				stop(fadeOut)
			else
				MasterClock.callOnce(onOverlapComplete, overlap);
			
			dispatchEvent(new MediaEvent(MediaEvent.OVERLAP));
		}
		
		private function onOverlapComplete():void
		{
			if (mediaController.isPlaying)
				stop();
		}
				
		private function onPlayDelayed():void
		{
			mediaController.play(start);
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
			setPlayPauseButton();							
		}	
		
		private function onPlayComplete(me:MediaEvent):void
		{
			cleanUpAfterStop();
			dispatchEvent(new MediaEvent(MediaEvent.COMPLETE, 1));

			if (loop || loop == -1)
			{
				if (loopDelay) 
				{
					//TODO Looping
					//loopDelayTimer = new Timer(loopDelay * 1000);
					//loopDelayTimer.addEventListener(TimerEvent.TIMERCOMPLETE, onLoopDelayComplete);
					//loopDelayTimer.start();
				}
				else
				{
					mediaController.play(0)
				}
			}
			if (loop > 0)
				loop--;
		}
		/*			
		private function onLoopDelayComplete(e:TimerEvent):void 
		{
			loopDelayTimer.removeEventListener(TimerEvent.TIMERCOMPLETE, onLoopDelayComplete);
			loopDelayTimer = null;
			
			if (url.indexOf(EMBEDDED) != -1)
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
package com.zutalor.utils
{
	import com.zutalor.components.media.video.VideoController;
	import com.zutalor.events.MediaEvent;
	import com.zutalor.events.MediaLoadProgressEvent;
	import com.zutalor.events.MediaPlayProgressEvent;
	import com.zutalor.audio.VideoController;
	import com.zutalor.properties.ApplicationProperties;
	import flash.display.Sprite;
	import flash.utils.getTimer;
	import net.guttershark.support.preloading.events.PreloadProgressEvent;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class MeasureVideoFrameRate
	{	
		public var updateIntervalMs:int;
		private var _averageFrameRate:Number;
		private var cumulativeFrameRate:Number;
		
		private var progressEvent:PreloadProgressEvent = new PreloadProgressEvent(PreloadProgressEvent.PROGRESS, 0, 0);
		private var videoController:VideoController;
		private var ap:ApplicationProperties;
		private var view:Sprite;
		private var samples:int;
		private var startTime:uint;
		private var endTime:uint;
		private var _onComplete:Function;
		private var _msToPlay:uint;
		
		public function MeasureVideoFrameRate()
		{
			updateIntervalMs = 100;
			ap = ApplicationProperties.gi();
			view = new Sprite;	
			view.visible = false;
			samples = 0;
			cumulativeFrameRate = 0;
			_averageFrameRate = 0;
		}
		
		public function get averageFrameRate():Number
		{
			return _averageFrameRate;
		}
		
		public function dispose():void
		{
			//TODO
		}
		
		public function start(fileLowUrl:String, fileMedUrl:String, fileHighUrl:String, sampleLengthMs:Number, curBandWidth:String="low", onComplete:Function=null):void
		{	
			var frameRateVidUrl:String;
			var measureVideoFrameRate:MeasureVideoFrameRate;			

			_onComplete = onComplete;
			_msToPlay = sampleLengthMs;	
			
			switch (ap.bandwidth)
			{
				case "low" :
					frameRateVidUrl = fileLowUrl;					
					break;
				case "medium" :
					frameRateVidUrl = fileMedUrl;
					break;
				case "high" :
					frameRateVidUrl = fileHighUrl;
					break;
				
			}
			if (frameRateVidUrl)
			{
				measure(frameRateVidUrl);	
			}
			else
			{
				if (onComplete != null)
					onComplete();
			}
		}
		
		private function finishedFrameRateCheck():void
		{
			if (_onComplete != null)
				_onComplete();
		}
		
		private function measure(url:String):void
		{
			videoController = new VideoController();
			videoController.addEventListener(MediaEvent.LOAD_COMPLETE, onLoaded, false, 0, true);
			videoController.addEventListener(MediaLoadProgressEvent.PROGRESS, checkLoadProgress, false, 0, true);
			videoController.load(view, url, 1, 1);
			videoController.play(); // start download
			videoController.stop(); // stop
		}
		
		private function checkLoadProgress(me:MediaLoadProgressEvent):void
		{
			progressEvent.percent = me.percentLoaded * 100;
			progressEvent.message = "Determining Capabilities";
			ap.loadingIndicator.onLoadingProgress(progressEvent);
		}
		
		private function onLoaded(me:MediaEvent):void
		{
			videoController.removeEventListener(MediaEvent.LOAD_COMPLETE, onLoaded);
			videoController.addEventListener(MediaEvent.PLAY_COMPLETE, onPlayComplete, false, 0, true);
			videoController.addEventListener(MediaPlayProgressEvent.PROGRESS, checkPlayProgress, false, 0, true);
			videoController.play();
			startTime = getTimer();
			endTime = startTime + _msToPlay;
			videoController.volume = 0;
		}
		
		private function checkPlayProgress(me:MediaPlayProgressEvent):void
		{
			progressEvent.percent = getTimer() / endTime * 100;
			progressEvent.message = "Determining Capabilities";
			ap.loadingIndicator.onLoadingProgress(progressEvent);
			if (getTimer() > endTime)
				onPlayComplete();
			else
			{
				if (ap.fpsMeter.frameRate)
				{
					samples++;
					cumulativeFrameRate += ap.fpsMeter.frameRate;
				}
			}
		}
		
		private function onPlayComplete(me:MediaEvent = null):void
		{
			videoController.stop();
			videoController.stopTimer();
			videoController.removeEventListener(MediaEvent.PLAY_COMPLETE, onPlayComplete);
			videoController.removeEventListener(MediaPlayProgressEvent.PROGRESS, checkPlayProgress);
			videoController.dispose();
			videoController = null;
			ap.loadingIndicator.visible = false;
			_averageFrameRate = cumulativeFrameRate / samples;
			finishedFrameRateCheck();
		}
	}
}
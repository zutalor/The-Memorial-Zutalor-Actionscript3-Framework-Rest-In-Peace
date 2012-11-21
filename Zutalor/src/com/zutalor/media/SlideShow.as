package com.zutalor.media
{
	import com.greensock.TweenMax;
	import com.gskinner.utils.IDisposable;
	import com.zutalor.containers.ViewContainer;
	import com.zutalor.events.UIEvent;
	import com.zutalor.objectPool.ObjectPool;
	import com.zutalor.utils.DisplayUtils;
	import com.zutalor.utils.Path;
	import com.zutalor.view.rendering.ViewLoader;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	public class SlideShow extends Sprite implements IDisposable
	{
		private const DFLT_CROSS_FADE:Number = 1;
		private const DFLT_SLIDE_DELAY:Number = 5;
		private var currentContainer:Sprite;
		private var intCurrentSlide:int = -1;
		private var intSlideCount:int;
		private var slideTimer:Timer;
		private var sprContainer1:Sprite;
		private var sprContainer2:Sprite;
		private var slideLoader:Loader;
		
		private var xmlSlideshow:XML;
		private var rect:Rectangle;
		private var _fadeTimeSecs:int;
		private var _playing:Boolean;
		private var _buttons:ViewContainer;
		private var _buttonsLoader:ViewLoader;
		private var _path:String;
		private var _buttonsInitialized:Boolean;
		private var _buttonsViewId:String;
		private var _buttonsContainer:String;
		private var _backgroundColor:uint;
		
		private var xmlLoader:URLLoader;
		
		public function SlideShow()
		{
		}
		
		public function initialize(buttonsViewId:String = null, buttonsContainer:String = null):void
		{
			_buttonsViewId = buttonsViewId;
			_buttonsContainer = buttonsContainer;
			
			sprContainer1 = new Sprite();
			sprContainer2 = new Sprite();
			addChild(sprContainer1);
			addChild(sprContainer2);
			currentContainer = sprContainer2;
		}
		
		private function initButtons(buttonsViewId:String):void
		{
			_buttonsLoader = ObjectPool.getViewLoader();
			_buttonsLoader.load(buttonsViewId);
			_buttons = _buttonsLoader.container;
			_buttons.addEventListener(UIEvent.PLAY_TOGGLE, onButtonClick);
			_buttons.addEventListener(UIEvent.NEXT, onButtonClick);
			_buttons.addEventListener(UIEvent.PREVIOUS, onButtonClick);
			_buttons.addEventListener(UIEvent.STOP, onButtonClick);
			addChild(_buttons.viewController.container);
		}
		
		public function load(xmlUrl:String, path:String, width:int, height:int, backgroundColor:uint, slideDelay:int, crossFade:int, autoPlay:Boolean):void
		{
			_path = path;
			if (!crossFade)
				crossFade = DFLT_CROSS_FADE;
			else
				_fadeTimeSecs = crossFade;
			
			if (!slideDelay)
				slideDelay = DFLT_SLIDE_DELAY;
			
			_backgroundColor = backgroundColor;
			if (slideTimer)
				slideTimer.removeEventListener(TimerEvent.TIMER, switchSlide);
			
			slideTimer = new Timer(slideDelay * 1000);
			slideTimer.addEventListener(TimerEvent.TIMER, switchSlide, false, 0, true);
			
			rect = new Rectangle(0, 0, width, height);
			
			xmlLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, onXMLLoadComplete, false, 0, true);
			xmlLoader.load(new URLRequest(xmlUrl));
			_playing = autoPlay;
		}
		
		public function play():void
		{
			switchSlide(null);
			_playing = true;
		}
		
		public function stop():void
		{
			slideTimer.stop();
			_playing = false;
		}
		
		private function onButtonClick(e:UIEvent):void
		{
			switch (e.type)
			{
				/*
				   case UIEvent.PLAY_TOGGLE :
				   if (!mediaController.isPlaying)
				   play();
				   else
				   pause();
				   break;
				   case UIEvent.STOP :
				   stop();
				   break;
				 */
				case UIEvent.NEXT: 
					switchSlide();
					break;
				case UIEvent.PREVIOUS: 
					switchSlide(null, true);
					break;
			}
		}
		
		public function dispose():void
		{
			slideLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, fadeSlideIn);
			slideLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, fadeSlideIn);
			xmlLoader.removeEventListener(Event.COMPLETE, onXMLLoadComplete);
			slideTimer.removeEventListener(TimerEvent.TIMER, switchSlide);
			slideTimer.stop();
			slideTimer = null;
			xmlLoader = null;
		}
		
		private function onXMLLoadComplete(e:Event):void
		{
			xmlSlideshow = new XML(e.target.data);
			intSlideCount = xmlSlideshow..image.length();
			switchSlide();
		}
		
		private function fadeSlideIn(e:Event):void
		{
			var bm:Bitmap;
			var shape:Shape;
			
			shape = new Shape();
			shape.graphics.beginFill(_backgroundColor);
			shape.graphics.drawRect(0, 0, rect.width, rect.height);
			shape.graphics.endFill();
			currentContainer.addChild(shape);
			
			bm = Bitmap(slideLoader.content);
			bm.smoothing = true;
			currentContainer.addChild(bm);
			DisplayUtils.fitIntoRect(bm, rect.width, rect.height);
			if (_buttonsViewId)
				if (!_buttonsInitialized)
				{
					_buttonsInitialized = true;
					initButtons(_buttonsViewId);
				}

			currentContainer.alpha = 0;
			if (slideTimer && _playing)
				TweenMax.to(currentContainer, _fadeTimeSecs, {alpha: 1, onComplete: slideTimer.start});
			else
				TweenMax.to(currentContainer, _fadeTimeSecs, {alpha: 1});
		}
		
		private function switchSlide(e:Event = null, reverse:Boolean = false):void
		{
			if (slideTimer && slideTimer.running)
				slideTimer.stop();
			
			if (!reverse)
			{
				if (intCurrentSlide + 1 < intSlideCount)
					intCurrentSlide++;
				else
					intCurrentSlide = 0;
			}
			else
			{
				if (intCurrentSlide > 0)
					intCurrentSlide--;
				else
					intCurrentSlide = intSlideCount - 1;
			}
			
			if (currentContainer == sprContainer2)
				currentContainer = sprContainer1;
			else
				currentContainer = sprContainer2;
			
			currentContainer.alpha = 0;
			
			swapChildren(sprContainer2, sprContainer1);
			
			slideLoader = new Loader();
			slideLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, fadeSlideIn, false, 0, true);
			slideLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, showProgress, false, 0, true);
			
			slideLoader.load(new URLRequest(Path.getPath(_path) + xmlSlideshow..image[intCurrentSlide].@src));
		
			//mcInfo.lbl_description.text = xmlSlideshow..image[intCurrentSlide].@desc;
			//mcInfo.lbl_count.text = (intCurrentSlide + 1) + " / " + intSlideCount + " Slides";
		}
		
		private function showProgress(e:ProgressEvent):void
		{
			//mcInfo.lbl_loading.text = "Loading..." + Math.ceil(e.bytesLoaded * 100 / e.bytesTotal) + "%";
		}
	}
}
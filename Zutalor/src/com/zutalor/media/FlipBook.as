package com.zutalor.media
{
	import com.greensock.easing.Sine;
	import com.greensock.TweenMax;
	import com.gskinner.utils.IDisposable;
	import com.zutalor.containers.StandardContainer;
	import com.zutalor.events.UIEvent;
	import com.zutalor.sprites.CenterSprite;
	import com.zutalor.utils.ArrayUtils;
	import com.zutalor.utils.DisplayUtils;
	import com.zutalor.utils.gDictionary;
	import com.zutalor.utils.MathG;
	import com.zutalor.view.ViewLoader;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	import flash.utils.Timer;
	
	public class FlipBook extends CenterSprite implements IDisposable
	{
		private var currentContainer:Sprite;
		private var _currentSlide:int = -1;
		private var _slideCount:int;
		private var sprContainer1:Sprite;
		private var sprContainer2:Sprite;
		private var slideLoader:Loader;
	
		private var xmlSlideshow:XML;
		private var rect:Rectangle;
		private var _fadeTimeSecs:Number;
		private var _playing:Boolean;
		private var _path:String;
		private var _urlBase:String;
		private var _urlExtension:String;
		private var _buttonsInitialized:Boolean;
		private var _buttonsViewId:String;
		private var _buttonsContainer:String;
		private var _buttonsLoader:ViewLoader;
		private var _backgroundColor:uint;
		private var _buttons:StandardContainer;
		
		private var _slides:Array;
		private var _slidesLoaded:int;
		
		private var _fps:Number;
		private var _lastMouseX:Number;
		
		private var _nextTrigger:uint;
		private var _nextCheckMouse:uint;
		private var _triggerMs:Number;
		private var _autoPlay:Boolean;
		private var _mouseIsDown:Boolean;

		public function FlipBook()
		{
		}
		
		public function set fps(n:Number):void
		{
			_fps = n;
			
			_triggerMs = 1000 / Math.abs(_fps);
			_nextTrigger = getTimer() + _triggerMs;
			_fadeTimeSecs = _triggerMs / 1000;
			
			if (_autoPlay && !_playing)
				play();
		}
		
		public function get isPlaying():Boolean
		{
			return _playing;
		}
		
		public function get fps():Number
		{
			return _fps;
		}
		
		public function get currentFrame():Number
		{
			return _currentSlide;
		}
		
		public function get totalFrames():Number
		{
			return _slideCount;
		}
		
		public function initialize(buttonsViewId:String = null):void
		{
			_buttonsViewId = buttonsViewId;
			
			sprContainer1 = new Sprite();
			sprContainer2 = new Sprite();
			sprContainer1.cacheAsBitmap = true;
			sprContainer2.cacheAsBitmap = true;
			addChild(sprContainer1);
			addChild(sprContainer2);
			currentContainer = sprContainer2;
			this.cacheAsBitmap = true;
		}
		
		public function play():void
		{
			_slideCount = _slides.length;
			_currentSlide = 0;
			_nextTrigger = getTimer() + _triggerMs;
			addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouse, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouse, false, 0, true);
			
			_playing = true;
			switchSlide();
		}
		
		private function onMouse(e:Event):void
		{
			if (!_mouseIsDown)
				_mouseIsDown = true;
			else
				_mouseIsDown = false;
		}
		
		public function stop():void
		{
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouse);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouse);
			_playing = false;
		}		
		
		public function dispose():void
		{
			stop();
			slideLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, fadeSlideIn);
			slideLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, fadeSlideIn);
			_slides = null;
		}
		
		private function initButtons(buttonsViewId:String):void
		{
			_buttonsLoader = new ViewLoader();
			_buttonsLoader.load(buttonsViewId);
			_buttons = _buttonsLoader.container;
			_buttons.addEventListener(UIEvent.PLAY_TOGGLE, onButtonClick);				
			_buttons.addEventListener(UIEvent.NEXT, onButtonClick);				
			_buttons.addEventListener(UIEvent.PREVIOUS, onButtonClick);				
			_buttons.addEventListener(UIEvent.STOP, onButtonClick);				
			addChild(_buttons.viewController.container);
		}	
		
		public function load(urlBase:String, path:String, width:int, height:int, count:int, urlExtension:String, backgroundColor:uint, fps:Number, autoPlay:Boolean):void
		{	
			this.fps = fps;
			_urlExtension = urlExtension;
			_slidesLoaded = _currentSlide = 0;
			_playing = false;
			_urlBase = urlBase;
			_path = path;
			_slideCount = count;
			_slides = [];
				
			_backgroundColor = backgroundColor;
			
			rect = new Rectangle(0, 0, width, height);
			_playing = _autoPlay = autoPlay;
			loadSlide();
		}
		
		private function loadSlide(slideNum:int=0):void
		{
			var url:String;
			if (!slideNum)
			{
				slideLoader = new Loader();
				slideLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onSlideLoaded, false, 0, true);
				slideLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
				slideLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, showProgress, false, 0, true);
			}
			slideNum += 1;
			url = _path + _urlBase
				
			if (slideNum < 10) 
				url += "0";
			
			url += slideNum + _urlExtension;
			slideLoader.load(new URLRequest(url));
		}
		
		private function onSlideLoaded(e:Event):void
		{
			_slides.push(e.target.loader.content);
			_slidesLoaded++;
			if (_slidesLoaded == _slideCount)
			{
				dispatchEvent(new Event(Event.COMPLETE));
				if (_playing)
					play();
			}
			else
				loadSlide(_slidesLoaded);

		}
		
		private function onIOError(e:IOErrorEvent):void
		{
			e.currentTarget.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			trace("Flipbook IOError: " + e.currentTarget.loader.contentLoaderInfo.url);
			_slidesLoaded++;
			if (_slidesLoaded == _slideCount)
			{
				dispatchEvent(new Event(Event.COMPLETE));
				if (_playing)
					play();
			}
			else
				loadSlide(_slidesLoaded);
			
		}

		private function showProgress(e:ProgressEvent):void
		{
			//mcInfo.lbl_loading.text = "Loading..." + Math.ceil(e.bytesLoaded * 100 / e.bytesTotal) + "%";
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
				case UIEvent.NEXT :
					switchSlide();
					break;
				case UIEvent.PREVIOUS :
					switchSlide();
					break;
			}
		}
		
		
		private function onEnterFrame(e:Event):void
		{
			var t:uint;
			var mid:int;
			var quarter:int;
			var s:Number;
			
			t = getTimer();
			
			if (t > _nextTrigger)
			{
				_nextTrigger = t + _triggerMs;	
				switchSlide();
			}
			
			if (_mouseIsDown && t > _nextCheckMouse)
			{
				_nextCheckMouse = t + 300;
				if (_lastMouseX != stage.mouseX)
				{
					_lastMouseX = stage.mouseX;
					mid = this.stage.stageWidth / 2;
					quarter = this.stage.stageWidth / 4;
					if (stage.mouseX > mid + quarter)
						fps = MathG.linearConversion(stage.mouseX, mid, this.stage.stageWidth, 0, this.stage.frameRate);
					else if (stage.mouseX > mid)
						fps = MathG.linearConversion(stage.mouseX, mid, this.stage.stageWidth, 0, 12);
					else if (stage.mouseX < quarter)
						fps = MathG.linearConversion(stage.mouseX, 0, mid, this.stage.frameRate * -1, 0);
					else	
						fps = MathG.linearConversion(stage.mouseX, 0, mid, 12 * -1, 0);
						
				
				}
			}
		}
		
		private function switchSlide():void
		{				
			if (_fps > 0)
			{
				if(_currentSlide + 1 < _slideCount)
					_currentSlide++;
				else
					_currentSlide = 0;
			}
			else 
			{
				if (_currentSlide > 0)
					_currentSlide--;
				else
					_currentSlide = _slideCount - 1;
			}
			
			if(currentContainer == sprContainer2)
				currentContainer = sprContainer1;
			else
				currentContainer = sprContainer2;

			currentContainer.alpha = 0;
			swapChildren(sprContainer2, sprContainer1);
			fadeSlideIn();
		}		
		
		private function fadeSlideIn():void
		{
			var bm:Bitmap;
			var shape:Shape;
			
			bm = Bitmap(_slides[_currentSlide]);
				
			bm.smoothing = true;
			
			if (currentContainer.numChildren)
				currentContainer.removeChildAt(0);
				
			currentContainer.addChild(bm);
			
			DisplayUtils.fitIntoRect(bm, rect.width, rect.height);
			if (_buttonsViewId)
				if (!_buttonsInitialized)
				{
					_buttonsInitialized = true;
					initButtons(_buttonsViewId);
				}

			if (_fadeTimeSecs > .125)
			{
				currentContainer.alpha = 0;
				TweenMax.to(currentContainer, _fadeTimeSecs, { alpha:1, ease:Sine.easeInOut } );
			}
			else
				currentContainer.alpha = 1;
		}
	}
}
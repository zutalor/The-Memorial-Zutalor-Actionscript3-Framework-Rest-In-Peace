package com.zutalor.sprites 
{
	import com.zutalor.containers.ViewObject;
	import com.zutalor.Transition.FX;
	import com.zutalor.ui.TextOverlay;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.system.Capabilities;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class CameraSprite extends Sprite
	{
		private var _cam:Camera;
		private var _vid:Video;
		private var _textOverlay:TextOverlay;
		
		public function CameraSprite() 
		{

		}
		
		public function show(width:Number,height:Number):void
		{
			
			if (_cam == null)
			{
				if (Camera.names)
				{
					_cam = Camera.getCamera();
					if (_cam != null)
					{
						_vid = new Video();
						_vid.attachCamera(_cam);
						_cam.setMode(width, height, 30, false);
						_cam.setQuality(0,100);
						_vid.width = width;
						_vid.height = height;

						addChild(_vid);
						if (_textOverlay)
							addChild(_textOverlay);
					}
				}
			}
		}
		
		public function showOverlayText(url:String, width:int, height:int, styleSheet:String, fadeTime:Number=.5, backgroundColor:uint = 0xFFFFFF, backroundAlpha:Number=.2):void
		{
			if (!_textOverlay)
			{
				_textOverlay = new TextOverlay();
				_textOverlay.show(url, width, height, styleSheet, fadeTime, backgroundColor, backroundAlpha); 
			}
			else
			{
				_textOverlay.show(url, width, height, styleSheet, fadeTime, backgroundColor, backroundAlpha);
			}
			addChild(_textOverlay);
		}
				
		public function stop():void
		{
			if (_cam) 
			{
				_vid.attachCamera(null);
				_cam = null;
				_vid = null;
		
			}
		}
		
		public function blinkText(numBlinks:int = 10, speed:Number = 1):void
		{
			Transition.blink(_textOverlay.text, numBlinks, speed);
		}
	}
}
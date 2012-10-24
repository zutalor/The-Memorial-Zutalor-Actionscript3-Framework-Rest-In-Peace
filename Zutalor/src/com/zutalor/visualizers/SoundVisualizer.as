package com.zutalor.visualizers 
{
	import com.zutalor.ui.DrawGraphics;
	import com.zutalor.utils.MathG;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.media.SoundMixer;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class SoundVisualizer extends Sprite
	{
		public const SPECTRUM_WIDTH:int = 256;
		
		private var _visualizer:Sprite;
		private var _visualizerMask:Sprite;
		private var _backgroundColor:uint;
		private var _isPlaying:Boolean;
		private var _width:Number;
		private var _height:Number
		
		private var _bitmapData:BitmapData;
		private var _bitmapDisplay:Bitmap;
		
		public function SoundVisualizer(width:Number, height:Number) 
		{
			_width = width;
			_height = height;
			initBitmap();
			_visualizer = new Sprite();
			_visualizerMask = new Sprite();
			addChild(_visualizer);
		}
		
		public function play(backgroundColor:uint = 0x000000):void
		{
			_backgroundColor = backgroundColor;
			if (!_isPlaying)
			{
				DrawGraphics.box(this, width, height, backgroundColor, .5, 25, 25);
				DrawGraphics.box(_visualizerMask, _width, _height, .6, 25, 25);
				_isPlaying = true;
				addEventListener(Event.ENTER_FRAME, createVisualizerEffectB, false, 0, true);
				_visualizer.addChild(_bitmapDisplay);
			}
		}
		
		private function initBitmap():void
		{
			_bitmapData = new BitmapData(_width, _height, true, 0x000000);
			_bitmapDisplay = new Bitmap(_bitmapData);
		}
		
		override public function set height(n:Number):void
		{
			_height = n;
		}
		
		override public function set width(n:Number):void
		{
			_width = n;
		}
		
		override public function get height():Number
		{
			return _height;
		}
		
		override public function get width():Number
		{
			return _width;
		}
		
		public function stop():void
		{
			if (_isPlaying)
			{
				removeEventListener(Event.ENTER_FRAME, createVisualizerEffect);
				_isPlaying = false;
			}
		}
		
		private function createVisualizerEffect(e:Event):void
		{
			createVisualizerEffectB();
		}
		
		
		private function createVisualizerEffectB(e:Event=null):void
		{
			var soundData:ByteArray = new ByteArray();
			SoundMixer.computeSpectrum(soundData);
			_bitmapData.fillRect(_bitmapData.rect, 0xBB000044);
			
			for (var i:int = 0; i < SPECTRUM_WIDTH; i++)
			{
				var amplitude:Number = soundData.readFloat();
				var ampHeight:Number = (_height >> 1) * (amplitude + 1);
				
				var rect:Rectangle = new Rectangle(i * width / SPECTRUM_WIDTH, _height - ampHeight, width / SPECTRUM_WIDTH, ampHeight);
				
				_bitmapData.fillRect(rect, 0xFF0000);
			}
		}
		
		public function dispose():void
		{
			removeEventListener(Event.ENTER_FRAME, createVisualizerEffect);
			_visualizer = null;
			_visualizerMask = null;
		}
	}
}
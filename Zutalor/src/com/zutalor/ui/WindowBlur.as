package com.zutalor.ui
{
 
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
 
	/**
	* Blurs a background (MovieClip or Sprite) behind a transparent window (MovieClip or Sprite).
	* Based on Pixelfumes AS2 class
	*
	* @author Devon O.
	*/
	public class WindowBlur {
 
		private var _background:DisplayObjectContainer;
		private var _window:DisplayObjectContainer;
 
		private var _blurredImageData:BitmapData;
		private var _blurredImage:Bitmap;
		private var _mask:DisplayObjectContainer;
		private var _blurAmount:int;
 
		private var _blur:BlurFilter;
		private var _point:Point = new Point();
 
		/**
		 *
		 * @param	background		MovieClip or Sprite which will be blurred behind window.
		 * @param	window			(Semi) transparent MovieClip or Sprite behind which will be a blurred background.
		 * @param	blurAmount		The amount of blur to apply to background image.
		 *
		 * NOTE: background and window objects *must* be added to display list before instantiating an instance of this class.
		 * TODO: allow multiple window instances with same background.
		 * FLASH BUG: 	If window instance is created programatically, it cannot have filters applied.
		 * 				If window instance is linked to MovieClip in library it CAN have filters applied.
		 */
		public function WindowBlur(background:DisplayObjectContainer, window:DisplayObjectContainer, blurAmount:int = 8 ):void {
			_background = background;
			_window = window;
			_blurAmount = (blurAmount >= 0 && blurAmount <= 255) ? blurAmount : 16;
			_blur = new BlurFilter(_blurAmount, _blurAmount, 3);
 
			initBlur();
			initMask();
		}
 
		private function initBlur():void {
			_blurredImageData = new BitmapData(_background.width, _background.height, false);
			_blurredImageData.draw(_background);
			_blurredImageData.applyFilter(_blurredImageData, _blurredImageData.rect, _point, _blur);
			_blurredImage = new Bitmap(_blurredImageData);
 
			_background.addChild(_blurredImage);
		}
 
		private function initMask():void {
			var MaskClass:Class = Object(_window).constructor;
			_mask = new MaskClass();
			_mask.filters = _window.filters;
			_blurredImage.mask = _mask;
			_mask.visible = false;
 
			_window.addChildAt(_mask, 0);
		}
 
		private function update():void {
			_background.removeChild(_blurredImage);
			_blurredImageData.dispose();
			initBlur();
			_blurredImage.mask = _mask;
		}
 
		public function kill():void {
			_background.removeChild(_blurredImage);
			_window.removeChild(_mask);
 
			_blurredImageData.dispose();
 
			_blurredImage = null;
			_blurredImageData = null;
			_mask = null;
			_blur = null;
		}
 
		public function get blurAmount():int { return _blurAmount; }
 
		public function set blurAmount(value:int):void {
			_blurAmount = value;
			_blur.blurX = _blur.blurY = _blurAmount;
			update();
		}
	}
}
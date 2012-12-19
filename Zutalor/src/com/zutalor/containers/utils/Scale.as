package com.zutalor.utils 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Scale
	{
		private static var _scaleX:Number;
		private static var _scaleY:Number;
		
		private static var _currentScale:Number;
		private static var _currentScaleX:Number;
		private static var _currentScaleY:Number;
		
		public static function calcAppScale(stage:Stage, designWidth:int, designHeight:int):void
		{
			_currentScaleX = stage.stageWidth / designWidth;
			_currentScaleY = stage.stageHeight / designHeight;			
		}

		public static function constrainAppScaleRatio():void
		{
			if (_currentScaleX > _currentScaleY)
				_currentScaleX = _currentScaleY;
				
			if (_currentScaleY > _currentScaleX)
				_currentScaleY = _currentScaleX;
				
			_currentScale = _currentScaleX;	
		}
		
		public static function get curAppScaleX():Number
		{
			return _currentScaleX;
		}
		
		public static function get curAppScaleY():Number
		{
			return _currentScaleY;
		}
		
		public static function get curAppScale():Number
		{
			return _currentScale;
		}
		
		public static function accumulateXScale(c:DisplayObject, currentScale:Number = 1):Number 
		{
			_scaleX = currentScale;
				
			if (c != null)
			{
				_scaleX *= c.scaleX;
				accumulateXScale(c.parent, _scaleX);
				return _scaleX;
			}
			else
			{
				return _scaleX;
			}
			
		}
		public static function accumulateYScale(c:DisplayObject, scale:Number = 1):Number 
		{
			_scaleY = scale;
				
			if (c != null)
			{
				_scaleY *= c.scaleY;
				accumulateYScale(c.parent, _scaleY);		
				return _scaleY;
			}
			else
			{
				return _scaleY;
			}
			
		}
	}
	
}
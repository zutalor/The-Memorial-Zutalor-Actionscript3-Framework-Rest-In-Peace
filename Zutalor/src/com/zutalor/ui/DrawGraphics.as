package com.zutalor.ui 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class DrawGraphics
	{	
		public static function invisibleBox(s:Sprite, width:int, height:int):void
		{
				s.graphics.beginFill(0, 0);
				s.graphics.drawRect(width-1, 0, 1, 1);
				s.graphics.drawRect(0, height - 1, 1, 1);
				s.graphics.endFill();
		}
		
		public static function box(s:*, width:Number=10,height:Number=10, color:uint=0x000000,alpha:Number=1,ellipseWidth:Number = 0, ellipseHeight:Number = 0, x:int = 0, y:int = 0):void
		{		
			s.graphics.clear();
			s.graphics.beginFill(color,alpha)
			s.graphics.drawRoundRect(x, y, width, height, ellipseWidth, ellipseHeight);
			s.graphics.endFill();
		}
		public static function UIWindowFrame(s:Sprite, width:int, height:int, frameColor:uint = 0x0000FF, alpha:Number = 1, rounding:int = 0):void
		{
			s.graphics.clear();
			s.graphics.beginFill(frameColor, alpha);
			s.graphics.drawRoundRect(0, 0, width, height, rounding, rounding);
			s.graphics.endFill();
		}
		
		public static function x(s:Sprite, size:Number, lineStyle:Number, color:uint, backgroundColor:uint, backgroundAlpha:uint):void
		{
			s.graphics.clear();
			s.graphics.beginFill(backgroundColor, backgroundAlpha);
			s.graphics.drawRect( -size, -size, size * 2, size * 2);
			s.graphics.endFill();
			s.graphics.lineStyle( lineStyle , color );
			s.graphics.moveTo( -size , -size );
			s.graphics.lineTo( size , size );
			s.graphics.moveTo( -size , size );
			s.graphics.lineTo( size , -size );
			
		}
		
		public static function resize(s:Sprite, size:Number, lineStyle:Number, color:uint, backgroundColor:uint, backgroundAlpha:uint):void
		{
			s.graphics.clear();
			s.graphics.beginFill(backgroundColor, backgroundAlpha);
			s.graphics.drawRect( -size, -size, size * 2, size * 2);
			s.graphics.endFill();
			s.graphics.lineStyle( lineStyle , color );
			s.graphics.moveTo( -size , -size );
			s.graphics.lineTo( size , size );
		}
		
		public static function leftArrow(s:Sprite, color:uint = 0xFFFFFF, alpha:Number=1):void 
		{
			s.graphics.clear();
			s.graphics.beginFill(color, alpha);
			s.graphics.moveTo(0, 0);
			s.graphics.drawRect(0, 0,5,1);
			s.graphics.drawRect(1, -1,1,1);
			s.graphics.drawRect(2, -2,1,1);
			s.graphics.drawRect(1, 1,1,1);
			s.graphics.drawRect(2, 2, 1, 1);
			s.graphics.endFill();
		}
		
		public static function rightArrow(s:Sprite, color:uint = 0xFFFFFF, alpha:Number = 1):void
		{
			s.graphics.clear();
			s.graphics.beginFill(color, alpha);
			s.graphics.moveTo(0, 0);
			s.graphics.drawRect(0, 0,5,1);
			s.graphics.drawRect(4, -1,1,1);
			s.graphics.drawRect(3, -2,1,1);
			s.graphics.drawRect(4, 1,1,1);
			s.graphics.drawRect(3, 2,1,1);
			s.graphics.endFill();			
		}
		
		public static function circle(s:Sprite, r:int, color:uint = 0xFFFFFF, alpha:Number = 1):void
		{
			//s.graphics.clear()
			s.graphics.beginFill(color, alpha);
			s.graphics.drawCircle(0, 0, r);
			s.graphics.endFill();
		}
	}
}
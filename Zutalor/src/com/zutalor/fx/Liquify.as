package com.zutalor.fx 
{
	import com.greensock.TweenMax;
	import com.gskinner.utils.IDisposable;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.StageRef;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.BlendMode;
	import flash.display.DisplayObjectContainer;
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DisplacementMapFilterMode;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author From the Internet, modified by Geoff
	 */
	public class Liquify implements IDisposable
	{		
		private var originalBitmap:Bitmap;
		
		private var previous:Point;
		private var brush:Sprite;
		private var _originalImage:Sprite;
		private var map:BitmapData;
		
		// options
		
		private var softness:Array = [0,255];			
		private var size:uint = 80;
		
		private var hardness:uint = 2;
		
		private var _source:DisplayObjectContainer;	
		private var _lastUpdate:uint;
		private var _lastActivity:uint;
		private var _bData:BitmapData;
		private var _savedBData:BitmapData;
		private var _savedBitmap:Bitmap;
		
		private const UPDATE_INTERVAL:int = 30;
		private const RESET_INTERVAL:int = 4000;
		private const TRANSITION_TIME:int = 3; //seconds

		
		public function Liquify(source:DisplayObjectContainer) 
		{
			_source = source;
			init();
		}	
		
		public function dispose():void
		{
			StageRef.stage.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			StageRef.stage.removeEventListener( MouseEvent.MOUSE_UP,   onMouseUp );
			StageRef.stage.removeEventListener( MouseEvent.MOUSE_MOVE,   onMouseMove );
			//TODO clean up the stuff.
		}
			
		private function init():void
		{
			
			_bData = new BitmapData(_source.width, _source.height, true);
			_savedBData = new BitmapData(_source.width, _source.height, true);
			
			originalBitmap = new Bitmap(_bData);
			_savedBitmap = new Bitmap(_savedBData);
			
			originalBitmap.smoothing = true;
			_savedBitmap.smoothing = true;
			
			_bData.draw(_source);
			_savedBData.draw(_source);
			
			_originalImage = new Sprite();			
			_originalImage.addChild(_savedBitmap);
			
			_source.addChild(originalBitmap);
			MasterClock.registerCallback(checkActivity, false, RESET_INTERVAL);

			brush = new Sprite();

			createBrush( );
			brush.blendMode = BlendMode.INVERT;	
			_source.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
		}
		
		private function createBrush( ):void
		{
			var matrix:Matrix = new Matrix( );
			matrix.createGradientBox( size, size, 0 );
			brush.graphics.clear();
			brush.graphics.beginGradientFill( GradientType.RADIAL, [0xFF0000, 0x000000], [1, 0], softness, matrix, SpreadMethod.PAD, InterpolationMethod.LINEAR_RGB);
			brush.graphics.drawCircle( size/2, size/2, size/2 );
			brush.graphics.endFill();
			createMap();
		}
		
		private function createMap( ):void
		{
			map = new BitmapData( size, size, false, 128 << 16 || 128 << 8 || 128 );
			map.draw( brush, new Matrix(1, 0, 0, 1, 0, 0), null, BlendMode.HARDLIGHT );
		}
		

		private function drawDisplacement( bmp:BitmapData, current:Point ):void
		{
			var zero:Point = new Point();
			var out:BitmapData = new BitmapData( originalBitmap.bitmapData.rect.width, originalBitmap.bitmapData.rect.height, true, 0 );
			var displFilter:DisplacementMapFilter = new DisplacementMapFilter( 
						bmp, 
						current, 
						BitmapDataChannel.RED, 
						BitmapDataChannel.RED, 
						( previous.x - current.x )*hardness, 
						( previous.y - current.y )*hardness, 
						DisplacementMapFilterMode.WRAP 
						);
			out.applyFilter( originalBitmap.bitmapData, originalBitmap.bitmapData.rect, zero, displFilter );
			originalBitmap.bitmapData.draw( out, null, null, null, new Rectangle( current.x, current.y, bmp.rect.width, bmp.rect.height ) );
		}
		
		private function checkActivity():void
		{
			if (getTimer() > _lastActivity + RESET_INTERVAL)
			{
				_originalImage.visible = true;
				_source.addChild(_originalImage);
				TweenMax.from(_originalImage, TRANSITION_TIME, { alpha:0, onComplete:onTweenComplete } );
				MasterClock.stop(checkActivity);			
			}
		}
		
		private function onTweenComplete():void
		{
			_originalImage.visible = false;
			_bData.draw(_source);			
		}
		
		private function onMouseMove( event:Event ):void
		{
			var current:Point = new Point( _source.mouseX - brush.width/2, _source.mouseY - brush.height/2);
			if (getTimer() > UPDATE_INTERVAL + _lastUpdate)
			{
				_lastActivity = _lastUpdate = getTimer();
			
				if (!previous)
					previous = current.clone();
					
				drawDisplacement( map, current );
				previous = current.clone();
			}
		}
		
		private function onMouseDown( event:MouseEvent ):void
		{
			StageRef.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			StageRef.stage.addEventListener( MouseEvent.MOUSE_UP,   onMouseUp );
		}
		
		private function onMouseUp( event:MouseEvent ):void
		{
			StageRef.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			StageRef.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			MasterClock.start(checkActivity);	
		}
	}
}
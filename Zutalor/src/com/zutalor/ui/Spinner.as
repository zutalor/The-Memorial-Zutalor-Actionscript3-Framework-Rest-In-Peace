package com.zutalor.ui
{
	import com.greensock.TweenMax;
	import com.zutalor.utils.StageRef;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	
	public class Spinner
	{
		private static var _spinGraphic:Graphic;
		private static var _rotIncr:Number;
		private static var _myTween:TweenMax;
		private static var s:Stage;
		private static var canvas:Sprite;

		public function Spinner()
		{
			
		}

		public static function init(spinnerGraphicId:String, rotationCyclesPerSecond:Number = 2):void
		{
			_rotIncr = 360 / StageRef.stage.frameRate * rotationCyclesPerSecond;
			s = StageRef.stage;
			canvas = new Sprite();
			_spinGraphic = new Graphic();
			_spinGraphic.render(spinnerGraphicId);
			canvas.addChild(_spinGraphic);
			_spinGraphic.x -= _spinGraphic.width * .5;
			_spinGraphic.y -= _spinGraphic.height * .5;
			canvas.addChild(_spinGraphic);
		}
		
		public static function show(delay:int=0, x:int=0, y:int=0):void
		{
			
			if (_spinGraphic)
			{
				hide();
					
				s.addChild(canvas);
				
				if (_rotIncr)
					StageRef.stage.addEventListener(Event.ENTER_FRAME, rotate);
				
				if (x)
				{
					canvas.x = x;
					canvas.y = y;
				}
				else
				{	
					canvas.x = (s.stageWidth) * .5 ;
					canvas.y = (s.stageHeight) * .5 ;
				}
				_spinGraphic.visible = true;
				_spinGraphic.alpha = 0;
				_myTween = TweenMax.to(_spinGraphic, 1, { delay:delay, alpha:1 } );
			}
		}
				
		public static function rotate(e:Event):void
		{
			canvas.rotation += _rotIncr;
		}
		
		public static function hide():void
		{
			if (_spinGraphic)
			{
				if (_spinGraphic.visible == true)
				{
					if (_rotIncr)
						StageRef.stage.removeEventListener(Event.ENTER_FRAME, rotate);
				}
				if (_myTween)
					_myTween.kill();
				
				_spinGraphic.visible = false;
			}
		}
	}
}
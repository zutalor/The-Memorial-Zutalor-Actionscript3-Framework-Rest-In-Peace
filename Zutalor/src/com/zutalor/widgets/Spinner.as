package com.zutalor.widgets
{
	import com.greensock.TweenMax;
	import com.zutalor.audio.SamplePlayer;
	import com.zutalor.components.graphic.Graphic;
	import com.zutalor.utils.StageRef;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	public class Spinner
	{
		private static var _spinGraphic:Graphic;
		private static var _rotIncr:Number;
		private static var _myTween:TweenMax;
		private static var s:Stage;
		private static var canvas:Sprite;
		private static var samplePlayer:SamplePlayer;
		private static var _spinnerSoundClass:Class;
		private static var _tweenKilled:Boolean;
		private static var _startTime:int;
		private static var _soundInterval:int;

		public function Spinner()
		{
			
		}

		public static function init(spinnerGraphicId:String, rotationCyclesPerSecond:Number = 2, spinnerSoundClass:Class = null, soundInterval:int = 0):void
		{
			if (spinnerSoundClass)
			{
				_spinnerSoundClass = spinnerSoundClass;
				samplePlayer = new SamplePlayer();
			}
			_rotIncr = 360 / StageRef.stage.frameRate * rotationCyclesPerSecond;
			_soundInterval = soundInterval;
			s = StageRef.stage;
			canvas = new Sprite();
			_spinGraphic = new Graphic("spinner");
			_spinGraphic.vip.presetId = spinnerGraphicId;
			_spinGraphic.render();
			canvas.addChild(_spinGraphic);
			_spinGraphic.x -= _spinGraphic.width * .5;
			_spinGraphic.y -= _spinGraphic.height * .5;
			canvas.addChild(_spinGraphic);
		}
		
		public static function show(delaySecs:Number=0, x:int=0, y:int=0):void
		{
			
			if (_spinGraphic)
			{
				hide();
					
				s.addChild(canvas);
				
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
				_tweenKilled = false;
				if (samplePlayer)
					samplePlayer.volume = 1;
				
				_myTween = TweenMax.to(_spinGraphic, 1, { delay:delaySecs, onComplete:addFrameListener, alpha:1 } );
				
				function addFrameListener():void
				{
					if (_rotIncr)
						StageRef.stage.addEventListener(Event.ENTER_FRAME, rotate);
				}
			}
		}
		
		private static function playAudio():void
		{
			_startTime = getTimer();
			if (!_tweenKilled && _spinnerSoundClass)
				samplePlayer.play(null, _spinnerSoundClass);
		}
				
		private static function rotate(e:Event):void
		{
			canvas.rotation += _rotIncr;
			if (_soundInterval && (getTimer() - _startTime > _soundInterval))
				playAudio();
		}
		
		public static function hide():void
		{
			if (_spinnerSoundClass)
			{
				samplePlayer.volume = 0;
				samplePlayer.stop();
			}
			if (_spinGraphic)
			{
				if (_spinGraphic.visible == true)
				{
					if (_rotIncr)
						StageRef.stage.removeEventListener(Event.ENTER_FRAME, rotate);
				}
				if (_myTween)
				{
					_tweenKilled = true;
					_myTween.kill();
				}
				_spinGraphic.visible = false;
			}
		}
	}
}
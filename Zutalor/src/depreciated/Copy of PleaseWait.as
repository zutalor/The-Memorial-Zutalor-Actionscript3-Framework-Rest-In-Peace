package depreciated
{
	import com.greensock.TweenMax;
	import com.zutalor.utils.StageRef;
	import com.log2e.utils.SpinningPreloader;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import net.nrftw.iphone.components.loaders.SpinningLoader;
	
	public class PleaseWait
	{
		private static var _waitGraphic:Graphic;
		private static var _spinner:SpinningPreloader;
		private static var _rotIncr:Number;
		private static var _myTween:TweenMax;

		public function PleaseWait()
		{
			
		}

		public static function iit(waitingGraphicId:String = null, rotationCyclesPerSecond:Number = 2):void
		{
			_rotIncr = 360 / StageRef.stage.frameRate * rotationCyclesPerSecond;
			if (waitingGraphicId)
			{
				_waitGraphic = new Graphic();
				_waitGraphic.render(waitingGraphicId);
			}
			else
			{
				_spinner = new SpinningPreloader();
			}
		}
		
		public static function show(delay:int=0, x:int=0, y:int=0, parentContainer:DisplayObjectContainer=null, bottomLayer:Boolean=false):void
		{
			var d:DisplayObjectContainer;
			
			hide();
			if (_spinner)
			{
				_spinner.alpha = 0;
				_myTween = TweenMax.to(_spinner, 1, { delay:delay, alpha:1 } );
		
				_spinner.centerX = x;
				_spinner.centerY = y;
					
				if (parentContainer)
					_spinner.start(parentContainer);
				else
					_spinner.start(StageRef.stage);
			}
			
			else if (_waitGraphic)
			{
				if (!parentContainer)
					d = StageRef.stage;
				else
					d = parentContainer;
				
				if (bottomLayer)
					d.addChildAt(_waitGraphic, 0);
				else
					d.addChild(_waitGraphic);
				
				if (_rotIncr)
					StageRef.stage.addEventListener(Event.ENTER_FRAME, rotate);
				
				if (x)
				{
					_waitGraphic.x = x;
					_waitGraphic.y = y;
				}
				else
				{
									
					_waitGraphic.x = (d.width - _waitGraphic.width) * .5 ;
					_waitGraphic.y = (d.height - _waitGraphic.height) * .5 ;
				}
				_waitGraphic.visible = true;
				_waitGraphic.alpha = 0;
				_myTween = TweenMax.to(_waitGraphic, 1, { delay:delay, alpha:1 } );
			}
		}
				
		public static function rotate(e:Event):void
		{
			_waitGraphic.rotation += _rotIncr;
		}
		
		public static function hide():void
		{
			if (_spinner)
				_spinner.cancel();
			else if (_waitGraphic)
			{
				if (_waitGraphic.visible == true)
				{
					if (_rotIncr)
						StageRef.stage.removeEventListener(Event.ENTER_FRAME, rotate);
				}
				if (_myTween)
					_myTween.kill();
				
				_waitGraphic.visible = false;
				trace("hide");
			}
		}
	}
}
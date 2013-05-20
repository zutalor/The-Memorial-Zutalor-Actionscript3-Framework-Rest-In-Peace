package com.zutalor.widgets
{
	import com.zutalor.utils.Scale;
	import com.zutalor.utils.StageRef;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Geoff
	 */
	public class RunTimeTrace
	{
		private static var message:TextField = new TextField();
		private static var background:Sprite = new Sprite();
		private static var timer:Timer = new Timer(2000);
		private static var lastX:int;
		private static var lastY:int;
		
		
		public function RunTimeTrace()
		{
		}
		
		public static function show(s:String, x:int = 0, y:int = 0):void
		{
			if (x)
				lastX = x * Scale.curAppScale;
				
			if (y)
				lastY = y * Scale.curAppScale;
				
			var tf:TextFormat = new TextFormat();
			tf.size = 40;
			tf.font = "_sans";
			message.text = s;
			message.setTextFormat(tf);
			message.type = TextFieldType.INPUT;
			message.maxChars = 600;
			message.width = 600;
			background.graphics.beginFill(0xFFFFFF);
			background.graphics.drawRect(0, 0, message.textWidth * 1.4, message.textHeight * 1.6);
			message.x = message.y = 4;
			background.addChild(message);
			timer.start();
			timer.addEventListener(TimerEvent.TIMER, addToStage);
			addToStage();
			
			
			function addToStage():void
			{
				if (StageRef.stage)
				{
					StageRef.stage.addChild(background);
					background.x = lastX;
					background.y = lastY;
				}
			}
		}
	}
}
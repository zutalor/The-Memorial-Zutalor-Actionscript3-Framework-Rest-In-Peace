package com.zutalor.widgets
{
	import com.zutalor.utils.StageRef;
	import flash.display.Shape;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Geoff
	 */
	public class RunTimeTrace
	{
		public static var message:TextField = new TextField();
		public static var shape:Shape = new Shape();
		
		
		public function RunTimeTrace()
		{
		}
		
		public static function show(s:String):void
		{
			message.text = s;
			shape.graphics.beginFill(0xFFFFFF);
			shape.graphics.drawRect(0, 0, message.textWidth * 1.2, message.textHeight * 1.2);
			message.x = message.y = 4;
			if (StageRef.stage)
			{
				StageRef.stage.addChild(shape);
				StageRef.stage.addChild(message);
			}
		}
	}
}
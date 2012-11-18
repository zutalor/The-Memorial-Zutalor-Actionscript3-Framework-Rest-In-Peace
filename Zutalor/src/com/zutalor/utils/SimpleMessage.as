package com.zutalor.utils 
{
	import flash.display.Shape;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class SimpleMessage 
	{
		private static var text:TextField = new TextField();
		
		public static function show(t:String):void
		{
			var shp:Shape = new Shape();
			text.text = t;
			text.width = StageRef.stage.stageWidth
			text.wordWrap = true;
			shp.graphics.beginFill(0xFFFFFF);
			shp.graphics.drawRect(0, 0, text.textWidth + 11, text.height + 11);
			shp.graphics.endFill();
			StageRef.stage.addChild(shp);
			StageRef.stage.addChild(text);
			text.x = text.y = 5;
		}
		
	}

}
package com.zutalor.utils 
{
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class SimpleMessage 
	{
		private static var text:TextField = new TextField();
		private static var shp:Shape = new Shape();
			
		public static function show(t:String):void
		{
			shp.addEventListener(MouseEvent.CLICK, onClick);
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
		
		private static function onClick(me:MouseEvent):void
		{
			me.stopImmediatePropagation();	
			shp.removeEventListener(MouseEvent.CLICK, onClick);
			StageRef.stage.removeChild(shp);
			StageRef.stage.removeChild(text);
		}
	}
}
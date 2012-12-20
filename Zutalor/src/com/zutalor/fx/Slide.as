package com.zutalor.fx 
{
	import com.zutalor.properties.ApplicationProperties;
	import com.zutalor.utils.StageRef;
	import flash.display.DisplayObject;
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Slide
	{
		private static var _destX:int;
		private static var _destY:int;
		private static var _ap:ApplicationProperties;
				
		public static function tweenParams(dc:DisplayObject, fxType:String, inOut:String):Object
		{
			if (!_ap)
				_ap = ApplicationProperties.gi();

			_destX = dc.x;
			_destY = dc.y;				

			if (inOut == TransitionTypes.IN)
			{
				if (fxType.indexOf(TransitionTypes.SLIDE_RIGHT) != -1)
					dc.x = StageRef.stage.stageWidth;
				else if (fxType.indexOf(TransitionTypes.SLIDE_LEFT) != -1)
					dc.x = dc.width  * -1;
				else if (fxType.indexOf(TransitionTypes.SLIDE_TOP) != -1)
					dc.y = dc.height * -1;
				else if (fxType.indexOf(TransitionTypes.SLIDE_BOTTOM) != -1)
					dc.y = StageRef.stage.stageHeight;
				else	
					dc.y = StageRef.stage.stageHeight;
			}
			else	
			{
				if (fxType.indexOf(TransitionTypes.SLIDE_RIGHT) != -1)
					_destX = StageRef.stage.stageWidth;
				else if (fxType.indexOf(TransitionTypes.SLIDE_LEFT) != -1)
					_destX = dc.width * - 1;
				else if (fxType.indexOf(TransitionTypes.SLIDE_TOP) != -1)
					_destY = dc.height * - 1 ;
				else if (fxType.indexOf(TransitionTypes.SLIDE_BOTTOM) != -1)
					_destY = StageRef.stage.stageHeight;
				else
					_destY = StageRef.stage.stageHeight;
			}
			return { x:_destX, y:_destY };
		}		
	}

}
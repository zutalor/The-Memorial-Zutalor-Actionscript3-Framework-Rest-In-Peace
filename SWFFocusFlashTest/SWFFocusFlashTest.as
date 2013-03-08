package
{
	import com.adobe.swffocus.SWFFocus;
	
	import flash.accessibility.AccessibilityProperties;
	import flash.accessibility.Accessibility;
	import flash.display.Sprite;
	import flash.events.Event;

	public class SWFFocusFlashTest extends Sprite
	{
		public function SWFFocusFlashTest()
		{
			if (stage) 
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(event:Event = null):void
		{
			if (stage)
			{
				if (hasEventListener(Event.ADDED_TO_STAGE))
					removeEventListener(Event.ADDED_TO_STAGE, init);
				SWFFocus.init(stage);
			}
		}
	}
}
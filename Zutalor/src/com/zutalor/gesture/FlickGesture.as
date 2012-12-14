package com.zutalor.gesture
{
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.StageRef;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import org.gestouch.core.GestureState;
	import org.gestouch.core.Touch;
	import org.gestouch.gestures.PanGesture;
	import org.gestouch.gestures.SwipeGesture;
	import org.gestouch.gestures.SwipeGestureDirection;
	/*
	 * 
	 * 
	 * @author Geoff Pepos
	 */
	public class FlickGesture extends SwipeGesture
	{
		private var _touch:Touch;
		
		public function FlickGesture(target:Object = null)
		{
			super(target);
			maxDuration = 100000;
		}
		
		override public function reflect():Class
		{
			return FlickGesture;
		}
		
		override protected function onTouchBegin(touch:Touch):void
		{
			StageRef.stage.addEventListener(MouseEvent.MOUSE_UP, stopTimer, false, 0, true); 
			_touch = touch;
			if (touchesCount > numTouchesRequired)
			{
				failOrIgnoreTouch(touch);
				return;
			}
			if (touchesCount == 1)
				MasterClock.callOnce(beginGesture, 1000);
		}
		
		override public function dispose():void
		{
			StageRef.stage.removeEventListener(MouseEvent.MOUSE_UP, stopTimer);
			super.dispose();
		}
		
		protected function beginGesture():void
		{
			updateLocation();
			_avrgVel.x = _avrgVel.y = 0;
			// cache direction condition for performance
			_noDirection = (SwipeGestureDirection.ORTHOGONAL & direction) == 0;
		}
		
		protected function stopTimer(me:MouseEvent):void
		{
			StageRef.stage.removeEventListener(MouseEvent.MOUSE_UP, stopTimer);
			MasterClock.unRegisterCallback(beginGesture);
		}	
	}
}
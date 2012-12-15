package com.zutalor.fx
{
	import com.zutalor.motion.MotionUtils;
	import com.zutalor.utils.MasterClock;
	import com.zutalor.utils.MathG;
	import com.zutalor.utils.TimerRegistery;
	import flash.events.Event;

	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class ind
	{
		public static const CALM:String = "calm";
		public static const BREEZY:String = "breezy";
		public static const BLUSTERY:String = "blustery";
		public static const STORMY:String = "stormy"
		public static const HURRICANE:String = "hurricane";
		
		private static var _rangeY:Number;
		private static var _rangeX:Number;
		private static var _changeProbability:Number;
		
		private static var mu:MotionUtils;
		private static var init:Boolean;
		
		public static function start(weather:String = CALM):void
		{

			if (!mu)
				mu = MotionUtils.gi();
			
			switch (weather)
			{
				case CALM :
					_rangeY = .1;
					_rangeX = .3;
					_changeProbability = 10;
					MasterClock.registerCallback(onCallback, true, 300);
					break;
				case BREEZY :
					break;
				case BLUSTERY :
					break;
				case STORMY :
					break;
				case HURRICANE :
					break;
			}
		}
		
		private static function onCallback():void
		{
			if (MathG.rand(0, _changeProbability) == int(_changeProbability >> 1) || !init)
			{
				init = true;
				mu.windVx = MathG.randFloat( _rangeX * -1, _rangeX);
				mu.windVy = MathG.randFloat( _rangeY * -1, _rangeY);
			}
		}
		
		public static function stop():void
		{
			MasterClock.unRegisterCallback(onCallback);
		}
	}

}
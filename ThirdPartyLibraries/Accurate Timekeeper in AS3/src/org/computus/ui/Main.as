/*	
	====================================================================================
	2008 | John Dalziel  | The Computus Engine  |  http://www.computus.org

	All source code licenced under The MIT Licence
	====================================================================================  
	
	Accurate Timekeeper in AS3 Example
*/

package org.computus.ui
{
	import org.computus.model.*
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.events.*;
	import flash.utils.getTimer;

	public class Main extends MovieClip
	{

	// --------------------------------------------------------------
	// PROPERTIES		

		public var timekeeper:Timekeeper
		private var lastTick:Number
		private var cumulativeDrift:Number
		
	// --------------------------------------------------------------
	// CONSTRUCTOR & DESTRUCTOR

		public function Main():void
		{
			super()
			init()
		}
		
		protected function init():void
		{
			cumulativeDrift = 0
			lastTick = getTimer()

			// start timekeeper
			timekeeper = new Timekeeper()
			timekeeper.setRealTimeValue()
			timekeeper.setRealTimeTick()
			timekeeper.startTicking()
			timekeeper.addEventListener( TimekeeperEvent.CHANGE, onTick );
		}

	// --------------------------------------------------------------
	// EVENTS
				
		protected function onTick(event:TimekeeperEvent):void
		{
			// FPS
			fps_txt.text = timekeeper.getTickDuration() + "ms per " + timekeeper.getTickFrequency() + "ms"
			
			// TICK
			var newTick = getTimer()
			var expectedTickDuration = 1000 * (timekeeper.getTickDuration() / timekeeper.getTickFrequency())
			var actualTickDuration = newTick - lastTick
			lastTick = newTick
			
			// DRIFT
			var tickDrift = actualTickDuration - expectedTickDuration
			cumulativeDrift += tickDrift
			var cumulativeDriftSeconds = cumulativeDrift / 1000
			var sign
			if ( cumulativeDriftSeconds > 0 ) { sign = "+" } else { sign = "-" }
						
			d1_txt.text = expectedTickDuration.toString() + " milliseconds"
			d2_txt.text = actualTickDuration.toString() + " milliseconds"
			d3_txt.text = sign + " " + cumulativeDriftSeconds.toString() + " seconds"
		}
		
	}
}
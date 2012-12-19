package com.zutalor.widgets
{
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author 
	 */
	public class CountDown extends Sprite
	{
		private var endDate:Date;
		private var countdownTimer:Timer = new Timer(1000);
		private var _txt:TextField;

		public function CountDown(d:Date, txt:TextField) 
		{
			endDate = d;
			_txt = txt;
			countdownTimer.addEventListener(TimerEvent.TIMER, updateTime, false, 0, true);
			countdownTimer.start();
		}

		private function updateTime(e:TimerEvent):void
		{
			var now:Date = new Date();
			var time:String = new String();
			var timeLeft:Number = endDate.getTime() - now.getTime();
			var seconds:Number = Math.floor(timeLeft / 1000);
			var minutes:Number = Math.floor(seconds / 60);
			var hours:Number = Math.floor(minutes / 60);
			var days:Number = Math.floor(timeLeft / 86400);

			seconds %= 60;
			minutes %= 60;
			hours %= 24;

			var sec:String = seconds.toString();
			var min:String = minutes.toString();
			var hrs:String = hours.toString();
			var d:String = days.toString();

			if (sec.length < 2) {
				sec = "0" + sec;
			}

			if (min.length < 2) {
				min = "0" + min;
			}

			if (hrs.length < 2) {
				hrs = "0" + hrs;
			}
			time =  d.toString() + ":" + hrs + ":" + min + ":" + sec;
			_txt.text = time;
		}	
	}	
}
package com.zutalor.media 
{
	import com.zutalor.utils.gDictionary;
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class SoundPlayer 
	{
		
		public static var basicSoundPlayer:BasicSoundPlayer = new BasicSoundPlayer();
		
		public static function loadAndPlay(fileName:String):void
		{
			basicSoundPlayer.load(fileName, 1);
			basicSoundPlayer.play();
		}
				
		public static function set volume(v:Number):void
		{
			basicSoundPlayer.volume = v;
		}
		
		public static function get volume():Number
		{
			return basicSoundPlayer.volume;
		}
		
		private static function play():void
		{
			basicSoundPlayer.play();
		}

		public static function stop():void
		{
			basicSoundPlayer.stop();
		}
		
		public function dispose():void
		{
			basicSoundPlayer.dispose();
		}
	}
}
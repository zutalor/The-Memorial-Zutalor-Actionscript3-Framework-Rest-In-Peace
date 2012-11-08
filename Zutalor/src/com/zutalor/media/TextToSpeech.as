package com.zutalor.media 
{ 
	import com.zutalor.ui.Dialog;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import mx.utils.StringUtil;
	
	public class TextToSpeech 
	{	
		public var voice:String = "usenglishfemale";
		public var speed:int = 0;
		public var pitch:int = 5;
		public var apiUrl:String;
		public var enabled:Boolean = true;
		public var wordcount:int;
		
		private var _callback:Function;
		private var _stopped:Boolean;
		private var _channel:SoundChannel;
		private var _limitSentences:Boolean;
		
		private var _mp3Player:MP3Player;
		
		public function TextToSpeech()
		{
			_mp3Player = new MP3Player();
		}
		
		protected function makeURL(text:String):String // this uses the iSpeech.org api, override for another service;
		{
			return apiUrl +  "&voice=" + voice + "&speed=" + speed + "&pitch=" + pitch + "&text=" + unescape(text);
		}
		
		public function speak(text:String, callback:Function):void
		{
			var sentences:Array;
			var l:int;
			var i:int;
			
			if (!enabled)
			{
				if (callback != null)
					callback();
			}
			else if (!apiUrl)
				trace("TextToSpeach: No ApiUrl");
			else
			{
				_callback = callback;
				sentences = cleanString(text).split(".");
				l = sentences.length;
				sayNextSentence();
				
				function sayNextSentence():void
				{
					if (i < l && !_stopped)
					{
						say(sentences[i++] + ".", sayNextSentence);
					}
					else
						if (_callback != null)
						{
							_callback();
							_callback = null;
						}
				}
			}
		}
		
		public function stop():void
		{
			_mp3Player.stop();
			_stopped = true;
			if (_callback != null)
				_callback();
		}
		
		public function dispose():void
		{
			//TODO
		}
				
		// private methods
		
		private function say(text:String, onComplete:Function):void 
		{	
			var url:String;
			
			text = "potato";
			
			url = makeURL(text);
			
			_mp3Player.play(url, checkforError, onPlaybackComplete);
			
			function onPlaybackComplete():void
			{
				if (onComplete != null)
					onComplete();
			}
			
			function checkforError():void
			{
				var result:String = null;
				try {
					var vars:URLVariables = new URLVariables(_mp3Player.event.target.data);
					result = "Error Code " + vars.code + ": " + vars.message;
				}
				catch (e:Error) {}
				if (result != null)
				{
					if (onComplete != null)
						onComplete();
					trace(result);
					Dialog.show(Dialog.ALERT, result);
			
				}
				onComplete();
				onComplete = null;
			}
		}		
		
		private function cleanString(str:String):String // okay, could do this with regex, maybe also strip punctuation for smaller payload?
		{
			var r:Array;

			r = str.split("\n");
			str = r.join("");
			r = str.split("\r");
			str =r.join(" ");
			r = str.split("\t");
			str = r.join("");
			r = str.split(".  ");
			str = r.join(". ");
			r = str.split("  ");
			str = r.join("");
			
			r = str.split(" ");
			wordcount += r.length;
			
			trace("Words Translated: " + wordcount);
			
			return str;
		}		
	}
}
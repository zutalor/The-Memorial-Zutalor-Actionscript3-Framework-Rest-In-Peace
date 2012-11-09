package com.zutalor.media 
{ 
	import com.zutalor.ui.Dialog;
	import com.zutalor.utils.MathG;
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
		public const country:Array = ["usenglish", "ukenglish", "jpjapanese"];
		public const gender:Array = ["female", "male"];
		
		public var voice:String = "usenglishfemale";
		public var speed:String = "0";
		public var pitch:String = "100"; //0-200
		public var format:String = "mp3";
		public var frequency:String = "44100";
		public var bitrate:String = "128";
		public var bitdepth:String = "16";
		
		public var apiUrl:String;
		public var enabled:Boolean = true;
		public var wordcount:int;
		
		private var _afterSpeaking:Function;
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
			return apiUrl + "&format=" + format + "&frequency=" + frequency + "&bitrate" + bitrate + "&bitdepth" + bitdepth + 
								"&voice=" + voice + "&speed=" + speed + "&pitch=" + pitch + "&text=" + unescape(text);
		}
		
		public function speak(text:String, afterSpeaking:Function):void
		{
			var sentences:Array;
			var l:int;
			var i:int;
		
			voice = country[MathG.rand(0, 2)] + gender[MathG.rand(0, 1)];
			_afterSpeaking = afterSpeaking;
			if (!enabled)
			{
				if (_afterSpeaking != null)
					_afterSpeaking();
			}
			else if (!apiUrl)
				trace("TextToSpeach: No ApiUrl");
			else
			{
				sentences = cleanString(text).split(".");
				l = sentences.length;
				sayNextSentence();
				
				function sayNextSentence():void
				{
					if (i < l && !_stopped)
						say(sentences[i++] + ".", sayNextSentence);
					else
						stop();
				}
			}
		}
		
		public function stop():void
		{
			_mp3Player.stop();
			_stopped = true;
			if (_afterSpeaking != null)
			{
				_afterSpeaking();
				_afterSpeaking = null;
			}
		}
		
		public function dispose():void
		{
			//TODO
		}
				
		// private methods
		
		private function say(text:String, onComplete:Function):void 
		{	
			var url:String;
			
			//text = "CakeIsLie.";
			
			url = makeURL(text);
			
			_mp3Player.play(url, false, checkforError, onPlaybackComplete);
			
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
					{
						onComplete();
						onComplete = null;
					}
					trace(result);
					Dialog.show(Dialog.ALERT, result);
			
				}
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
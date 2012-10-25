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
		
		protected function makeURL(text:String):String // this uses the iSpeech.org api, override for another service;
		{
			return apiUrl + "&voice=" + voice + "&speed=" + speed + "&pitch=" + pitch + "&text=" + unescape(text);
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
					if (i < l && !_stopped && sentences[i])
						say(sentences[i++], sayNextSentence);
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
			_stopped = true;
			if (_channel)
				_channel.stop();

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
			var snd:Sound;
			var urlRequest:URLRequest;
			var urlLoader:URLLoader;
			var url:String;
			
			url = makeURL(text);
			urlRequest = new URLRequest(url);
				
			if (_channel)
			{
				_channel.stop();
				_channel.removeEventListener(Event.SOUND_COMPLETE, onPlaybackComplete);
			}	
			
			snd = new Sound();
			snd.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
			snd.load(urlRequest);
			_channel = snd.play();
			_channel.addEventListener(Event.SOUND_COMPLETE, onPlaybackComplete, false, 0, true);
			
			function onIOError(ie:IOErrorEvent):void
			{
				urlLoader = new URLLoader();
				urlLoader.addEventListener(Event.COMPLETE, getErrorMessage, false, 0, true);
				urlLoader.load(urlRequest);
			}
			
			function onPlaybackComplete(e:Event):void
			{
				_channel.removeEventListener(Event.SOUND_COMPLETE, onPlaybackComplete);
				onComplete();
			}
			
			function getErrorMessage(e:Event):void
			{
				var result:String = null;
				try {
					var vars:URLVariables = new URLVariables(e.target.data);
					result = "Error Code " + vars.code + ": " + vars.message;
				}
				catch (e:Error) {}
				if (result != null)
				{
					if (onComplete != null)
						onComplete();
					trace(result);
				}
				
				onComplete();
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
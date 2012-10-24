package com.zutalor.media 
{ 
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundMixer;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	public class TextToSpeech 
	{	
		public var voice:String = "usenglishfemale";
		public var speed:int = 0;
		public var pitch:int;
		public var snd:Sound;
		public var apiUrl:String;
		public var enabled:Boolean;
		public var wordcount:int;
		
		public function speak(t:String, onComplete:Function):void
		{
			var url:String;

			url = makeURL(cleanString(t));
			if (enabled && url)
			{
				var urlRequest:URLRequest = new URLRequest(url);
				var urlLoader:URLLoader = new URLLoader();
				
				urlLoader.addEventListener(Event.COMPLETE, onLoadComplete);
				urlLoader.load(urlRequest);
				
				SoundMixer.stopAll();
				snd = new Sound();
				snd.load(urlRequest);
				snd.play();
				
				if (onComplete != null)
					snd.addEventListener(Event.COMPLETE, onSoundComplete);
				
				function onSoundComplete(e:Event):void
				{
					snd.removeEventListener(Event.COMPLETE, onSoundComplete);
					onComplete();
				}
			}
			else if (onComplete != null)
				onComplete();
		}
		
		public  function stop():void
		{
			SoundMixer.stopAll();			
		}
		
		private  function onLoadComplete(e:Event):void {
			var result:String = null;
			try {
				var vars:URLVariables = new URLVariables(e.target.data);
				result = "Error Code " + vars.code + ": " + vars.message;
			}
			catch (e:Error) {}
			if (result != null)
				trace(result);
		}
		
		private  function makeURL(t:String):String 
		{
			var str:String;
			if (!apiUrl)
				trace("no textToSpeehApiUrl");
			else
				str = apiUrl + "&voice=" + voice + "&speed=" + speed + "&pitch=" + pitch + "&text=" + unescape(t);
			
			return str;
		}
		
		private function cleanString(str:String):String
		{
			var r:Array;

			r = str.split("\n");
			str =r.join("");
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
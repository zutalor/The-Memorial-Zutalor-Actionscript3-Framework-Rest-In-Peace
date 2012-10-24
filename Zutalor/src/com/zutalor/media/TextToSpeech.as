package com.zutalor.media 
{ 
	import com.zutalor.propertyManagers.Props;
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
		public var text:String;
		public var snd:Sound;
		public var apiUrl:String;
		
		public function speak(t:String, onComplete:Function):void
		{
			var url:String = makeURL();
			
			if (url)
			{
				var urlRequest:URLRequest = new URLRequest(url);
				var urlLoader:URLLoader = new URLLoader();
				
				urlLoader.addEventListener(Event.COMPLETE, onLoadComplete);
				urlLoader.load(urlRequest);
				
				text = t;
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
		
		private  function makeURL():String 
		{
			var str:String;
			if (!apiUrl)
				trace("no textToSpeehApiUrl");
			else
				str = apiUrl + "&voice=" + voice + "&speed=" + speed + "&pitch=" + pitch + "&text=" + unescape(text);
			
			return str;
		}
	}
}
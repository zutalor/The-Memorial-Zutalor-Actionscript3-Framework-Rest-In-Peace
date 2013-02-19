package com.zutalor.audio 
{ 
	import com.zutalor.audio.SamplePlayer;
	import com.zutalor.text.TextUtil;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	public class TextToSpeech 
	{	
		public var enabled:Boolean = true;
		public var enableRandomVoices:Boolean = false;
		public var wordcount:int;
		
		public const country:Array = ["usenglish", "ukenglish"];
		public const gender:Array = ["female", "male"];
		
		public var apiUrl:String;
		public var voice:String;
		public var speed:String;
		public var pitch:String; //0-200
		public var format:String;
		public var frequency:String;
		public var bitrate:String;
		public var bitdepth:String;
		
		private var onComplete:Function;
		private var onCompleteArgs:*;
		private var stopped:Boolean;
		private var samplePlayer:SamplePlayer;
		
		public function TextToSpeech(apiUrl:String, voice:String = "usenglishfemale", speed:String = "2", 
															pitch:String = "100", format:String = "mp3",
															frequency:String = "44100", bitrate:String = "64", 
															bitdepth:String="16")
		{
			this.apiUrl = apiUrl;
			this.voice = voice;
			this.speed = speed; // -10 to 10
			this.pitch = pitch; // 0-200
			this.format = format;
			this.frequency = frequency;
			this.bitrate = bitrate;
			this.bitdepth = bitdepth;
			samplePlayer = new SamplePlayer();
		}
		
		public function sayText(text:String, url:String, onComplete:Function = null, onCompleteArgs:* = null):void
		{	
			if (text && apiUrl)
				speak(text, onComplete, onCompleteArgs);
			else if (url)
				samplePlayer.play(url, onComplete, onCompleteArgs);
		}
		
		protected function makeURL(text:String):String
		{
			return apiUrl 	+ "&format=" + format + "&frequency=" + frequency + "&bitrate"
							+ bitrate + "&bitdepth" + bitdepth
							+ "&voice=" + voice + "&speed=" + speed + "&pitch=" + pitch + "&text=" + unescape(text);
		}
		
		protected function speak(text:String, onComplete:Function=null, onCompleteArgs:* = null):void
		{
			var sentences:Array;
			var l:int;
			var i:int;
			
			this.onComplete = onComplete;
			this.onCompleteArgs = onCompleteArgs;
	
			if (!enabled)
			{
				if (onComplete != null)
				{
					if (onCompleteArgs)
						onComplete(onCompleteArgs);
					else
						onComplete();
				}
			}
			else
			{
				stopped = false;
				if (enableRandomVoices)
					voice = country[rand(0, 1)] + gender[rand(0, 1)];

				sentences = cleanString(text).split(".");
				l = sentences.length;
				sayNextSentence();
				
				function sayNextSentence():void
				{
					if (i < l && !stopped)
						say(sentences[i++], sayNextSentence);
				}
			}
		}
		
		public function stop():void
		{
			stopped = true;
			samplePlayer.stop();
		}
		
		public function dispose():void
		{
			samplePlayer = null;
		}
				
		// PRIVATE METHODS
		
		private function say(text:String, onSayComplete:Function):void 
		{	
			var url:String;
			
			if (!text)
			{
			  onSayComplete();
			  return;
			} 
			
			while (text.charAt(0) == " ")
			{
				text = text.substring(1, text.length);
			}
			
			url = makeURL(text);
			samplePlayer.play(url, checkforError);
			
			function checkforError():void
			{
				var urlLoader:URLLoader;
				
				if (onSayComplete != null)
				{
					onSayComplete();
					onSayComplete = null;
				}
				
				if (!samplePlayer.soundLoaded)
				{
					urlLoader = new URLLoader();
					urlLoader.addEventListener(Event.COMPLETE, getError);
					urlLoader.load(new URLRequest(url));
				}
				
				function getError(e:Event):void
				{
					urlLoader.removeEventListener(Event.COMPLETE, getError);
					var result:String = null;

					try {
						var vars:URLVariables = new URLVariables(e.target.data);
						result = "Error Code " + vars.code + ": " + vars.message;
					}
					catch (e:Error) {}
					if (result != null)
					{
						trace(result);
					}
				}
			}
		}		
		
		private function cleanString(str:String):String // okay, could do this with regex; maybe also strip punctuation for smaller payload?
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
			
			str = TextUtil.stripSurroundedBy(str, "<", ">");
			
			r = str.split(" ");
			wordcount += r.length;
			trace("Words Translated: " + wordcount);
			
			return str;
		}	
		
		private function rand(min:Number,max:Number=NaN):int 
		{
			if (isNaN(max)) 
			{ 
				max = min; 
				min = 0; 
			}
			return Math.floor(Math.random() * (1 + max - min)) + min;
		}
	}
}
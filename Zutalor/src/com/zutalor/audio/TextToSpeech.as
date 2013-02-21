package com.zutalor.audio
{
	import com.zutalor.audio.SamplePlayer;
	import com.zutalor.text.TextUtil;
	import com.zutalor.utils.EmbeddedResources;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
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
		private var overrideDisableSpeech:Boolean;
		private var stopped:Boolean;
		private var samplePlayer:SamplePlayer;
		private var text:String;
		
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
			samplePlayer.addEventListener(IOErrorEvent.IO_ERROR, speakWithTextToSpeech, false, 0, true);
		}
		
		public function sayText(text:String, url:String, onComplete:Function = null, onCompleteArgs:* = null, overrideDisableSpeech:Boolean = false):void
		{
			var soundClass:Class;
			this.onComplete = onComplete;
			this.onCompleteArgs = onCompleteArgs;
			this.overrideDisableSpeech = overrideDisableSpeech;
			this.text = text;
			
			soundClass = EmbeddedResources.getClass(text);
		
			if (url || soundClass)
				samplePlayer.play(url, soundClass, onComplete, onCompleteArgs);
			else if (text && apiUrl)
				speakWithTextToSpeech();
		}
		
		protected function speakWithTextToSpeech(e:IOErrorEvent = null):void
		{
			speak(text, onComplete, onCompleteArgs, overrideDisableSpeech);
		}
		
		
		protected function makeURL(text:String):String
		{
			return apiUrl 	+ "&format=" + format + "&frequency=" + frequency + "&bitrate"
							+ bitrate + "&bitdepth" + bitdepth
							+ "&voice=" + voice + "&speed=" + speed + "&pitch=" + pitch + "&text=" + unescape(text);
		}
		
		protected function speak(text:String, onComplete:Function=null, onCompleteArgs:* = null, overrideDisableSpeech:Boolean = false):void
		{
			var sentences:Array;
			var l:int;
			var i:int;
			
			this.onComplete = onComplete;
			this.onCompleteArgs = onCompleteArgs;
	
			if (true || enabled || overrideDisableSpeech)
			{
				stopped = false;
				if (enableRandomVoices)
					voice = country[rand(0, 1)] + gender[rand(0, 1)];

				sentences = text.split(".");
				l = sentences.length;
				sayNextSentence();
				
				function sayNextSentence():void
				{
					if (i < l && !stopped)
					{
						sentences[i] = cleanString(sentences[i]);
						say(sentences[i++], sayNextSentence);
						//trace(sentences[i++]);
						//sayNextSentence();
						
					}
					else
						callOnComplete();
				}
			}
			else
				callOnComplete();
		}
		
		public function callOnComplete():void
		{
			if (onComplete != null)
			{
				if (onCompleteArgs)
					onComplete(onCompleteArgs);
				else
					onComplete();
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
			samplePlayer.play(url, null, checkforError);
			
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
		
		private function cleanString(str:String):String
		{
			var r:RegExp;
			var s:String
			var sa:Array;
			
			str = TextUtil.stripSurroundedBy(str, "<", ">");
			r = new RegExp(/[^a-zA-Z 0-9]+/g) ;
			sa = str.split("\n");
			str = sa.join("");
			sa = str.split("\t");
			str = sa.join("");
			sa = str.split("\r");
			str = sa.join(" ");
			sa = str.split("   ");
			str = sa.join(" ");
			sa = str.split("  ");
			str = sa.join(" ");
			
			sa = str.split(" ");
			wordcount += sa.length;
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
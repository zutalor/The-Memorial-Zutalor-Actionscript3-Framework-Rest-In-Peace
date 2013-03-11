package Zutalor.src.com.zutalor.textToSpeech
{
	import com.zutalor.audio.SamplePlayer;
	import com.zutalor.text.TextUtil;
	import com.zutalor.utils.Call;
	import com.zutalor.utils.EmbeddedResources;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	public class TextToSpeech
	{
		public var enabled:Boolean;
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
		private var text:String;
		
		public function TextToSpeech(apiUrl:String, voice:String = "usenglishfemale", speed:String = "0",
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
		
		public function set tempo(t:Number):void
		{
			samplePlayer.tempo = t;
		}
		
		public function get tempo():Number
		{
			return samplePlayer.tempo;
		}
		
		public function set volume(v:Number):void
		{
			samplePlayer.volume = v;
		}
		
		public function get volume():Number
		{
			return samplePlayer.volume;
		}
		
		public function preloadText(text:String, url:String, onComplete:Function = null, onCompleteArgs:*= null):void
		{
			samplePlayer.volume = 0;
			sayText(text, url, done);
			
			function done():void
			{
				samplePlayer.volume = 1;
				Call.method(onComplete, onCompleteArgs);
			}
		}
		
		public function sayText(text:String, url:String, onComplete:Function = null, onCompleteArgs:* = null):void
		{
			var soundClass:Class;
			this.onComplete = onComplete;
			this.onCompleteArgs = onCompleteArgs;
			this.text = text;

			if (text)
				soundClass = EmbeddedResources.getClass(text);
		
			if (url || soundClass)
				samplePlayer.play(url, soundClass, onComplete, onCompleteArgs);
			else if (text && apiUrl)
				speakWithTextToSpeech();
		}
		
		protected function speakWithTextToSpeech(e:IOErrorEvent = null):void
		{
			speak(text, onComplete, onCompleteArgs);
		}
		
		
		protected function makeURL(text:String):String
		{
			var str:String
			str = apiUrl + "Hello";
			//str = apiUrl + escape(text);
			return str;
			
			//return apiUrl 	+ "&format=" + format + "&frequency=" + frequency + "&bitrate"
			//				+ bitrate + "&bitdepth" + bitdepth
			//				+ "&voice=" + voice + "&speed=" + speed + "&pitch=" + pitch + "&text=" + unescape(text);
		}
		
		protected function speak(text:String, onComplete:Function=null, onCompleteArgs:* = null):void
		{
			var sentences:Array;
			var l:int;
			var i:int;
			
			this.onComplete = onComplete;
			this.onCompleteArgs = onCompleteArgs;
	
			if (enabled)
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
			Call.method(onComplete, onCompleteArgs);
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
			sa = str.split("\r");
			str = sa.join(" ");
			sa = str.split("   ");
			str = sa.join(" ");
			sa = str.split("  ");
			str = sa.join(" ");
			r = new RegExp(/[^a-zA-Z 0-9]+/g) ;
			str = str.replace(r,"");
			sa = str.split(" ");
			wordcount += sa.length;
			//trace("Words Translated: " + wordcount);
			
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
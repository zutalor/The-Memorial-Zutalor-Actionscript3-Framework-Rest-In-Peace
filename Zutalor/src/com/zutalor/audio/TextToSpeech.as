package com.zutalor.audio 
{ 
	import com.zutalor.utils.MathG;
	import com.zutalor.utils.SimpleMessage;
	import com.zutalor.text.StringUtils;
	import flash.events.Event;
	import flash.media.SoundChannel;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	public class TextToSpeech 
	{	
		public const country:Array = ["usenglish", "ukenglish"];
		public const gender:Array = ["female", "male"];
		
		public var voice:String = "usenglishfemale";
		public var speed:String = "2"; //-10 to 10
		public var pitch:String = "100"; //0-200
		public var format:String = "mp3";
		public var frequency:String = "44100";
		public var bitrate:String = "64";
		public var bitdepth:String = "16";
		
		public var apiUrl:String;
		public var enabled:Boolean = true;
		public var wordcount:int;
		
		private var afterSpeaking:Function;
		private var stopped:Boolean;
		private var channel:SoundChannel;
		private var limitSentences:Boolean;
		
		private var samplePlayer:SamplePlayer;
		
		public function TextToSpeech()
		{
			samplePlayer = new SamplePlayer();
		}
		
		protected function makeURL(text:String):String
		{
			return apiUrl 	+ "&format=" + format + "&frequency=" + frequency + "&bitrate"
							+ bitrate + "&bitdepth" + bitdepth
							+ "&voice=" + voice + "&speed=" + speed + "&pitch=" + pitch + "&text=" + unescape(text);
		}
		
		public function speak(text:String, afterSpeaking:Function=null):void
		{
			var sentences:Array;
			var l:int;
			var i:int;
		
			stopped = false;
			voice = country[MathG.rand(0, 1)] + gender[MathG.rand(0, 1)];
			afterSpeaking = afterSpeaking;
			
			if (!enabled)
			{
				if (afterSpeaking != null)
					afterSpeaking();
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
					if (i < l && !stopped)
						say(sentences[i++], sayNextSentence);
				}
			}
		}
		
		public function stop():void
		{
			stopped = true;
			samplePlayer.stop();

			if (afterSpeaking != null)
			{
				afterSpeaking();
				afterSpeaking = null;
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
			
			text = StringUtils.stripLeadingSpaces(text);
			
			if (!text)
			{
			  onComplete();
			  return;
			} 
			
			url = makeURL(text);
			
			samplePlayer.play(url, false, checkforError);
			
			function checkforError():void
			{
				var urlLoader:URLLoader;
				
				if (onComplete != null)
				{
					onComplete();
					onComplete = null;
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
						SimpleMessage.show(result);
						trace(result);
					}
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
package Zutalor.src.com.zutalor.textToSpeech
{
	import com.zutalor.air.AirStatus;
	import com.zutalor.text.TextUtil;
	/**
	 * ...
	 * @author Geoff
	 */
	public class TextToSpeechUtils
	{
		
		public function TextToSpeechUtils()
		{
			
		}
		
		public function cleanString(str:String):String
		{
			var r:RegExp;
			var sa:Array;
			
			str = TextUtil.stripSurroundedBy(str, "<", ">");
			sa = str.split("\r");
			str = sa.join(" ");
			sa = str.split("   ");
			str = sa.join(" ");
			sa = str.split("  ");
			str = sa.join(" ");
			//r = new RegExp(/[^a-zA-Z 0-9.!?]+/g) ;
			str = str.replace(r,"");
			return str;
		}
		
		public function getTextForSpeech(text:String):String
		{
			if (text)
				return TextUtil.stripSurroundedBy(getTextForDevice(text), "<DISPLAYTEXT>", "</DISPLAYTEXT>");
			else
				return text;
		}
			
		public function getTextForDisplay(text:String):String
		{
			if (text)
				return TextUtil.stripSurroundedBy(getTextForDevice(text), "<PHONETIC>", "</PHONETIC>");
			else
				return text;
		}
		
		public function getTextForDevice(text:String):String
		{
			if (!text)
				return text;
			else if (AirStatus.isMobile)
				return TextUtil.stripSurroundedBy(text, "<PC>", "</PC>");
			else
				return TextUtil.stripSurroundedBy(text, "<MOBILE>", "</MOBILE>");
		}
	}
}
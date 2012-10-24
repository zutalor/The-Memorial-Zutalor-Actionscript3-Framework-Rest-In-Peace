package com.plagro.processors
{
	/**
	 * FindURL simply searches through a given piece of text, checks for obvious URLs, inserts
	 * an HTML <a> tag around the URL and then returns the text
	 * 
	 * @author The Burned Out Hippy
	 * @example http://www.burnedouthippy.com/?p=12
	 * 
	 */ 
	public class FindURL
	{
		private var _wholeThing:String;
		
		/**
		 * Constructor
		 * 
		 * @param	textToProcess	FindURL requires text to be passed to it as a String
		 * 
		 */ 
		public function FindURL(textToProcess:String)
		{
			var regExp1:RegExp = new RegExp("(^|\\s+)((https?|ftp|news|)\\:\\/\\/[^\\s]*[^.,;''>\\s\\)\\]])" , "gi");
			
			if (regExp1.test(textToProcess))
				_wholeThing = textToProcess.replace(regExp1 , "<a href='$2'>$2</a>");
			else
				_wholeThing = textToProcess;
		}
		
		public function Process():String
		{
			return _wholeThing;
		}
		
	}
}
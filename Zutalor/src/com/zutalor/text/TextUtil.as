﻿package com.zutalor.text
{
	import com.zutalor.utils.gDictionary;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 * TODO: error checking.
	 */
	public class TextUtil
	{
		private static var _unique:int;
	
		public static function getUniqueName():String
		{
			_unique += 1;
			return "__" + String(_unique);
		}
		
		public static function getFileExtension(s:String):String
		{
			var nameParts:Array;
			
			nameParts = s.split(".");
			return nameParts[nameParts.length - 1];
		}
		
		public static function stripFileExtenstion(s:String):String
		{
			var nameParts:Array;
			nameParts = s.split(".");
			return nameParts[nameParts.length -2];
		}
		
		public static function formatTime(ms:Number):String
		{
			var time:String;
			var seconds:uint;
			var hours:uint;
			var minutes:uint;
			var days:uint;
			
			var x:Number;
			
			x = ms / 1000;
			seconds = x % 60;
			x /= 60;
			minutes = x % 60;
			x /= 60;
			hours = x % 24;
			x /= 24;
			days = x;
			
			time = "";
			
			if (days == 1)
				time = days + " day ";
			else if (days)
				time = days + " days ";
			
			time += gts(hours) + ":" + gts(minutes) + ":" + gts(seconds);
			
			return time;
			
			function gts(t:uint):String
			{
				var ts:String;
				
				if (t == 0)
					ts = "00";
				else if (t < 10)
					ts = "0" + t;
				else
					ts = t + ""; //hack!

				return ts;	
			}
		}
		
		public static function stripLinks(s:String):String
		{
			var tmp:String;
			
			var linkBegin:int;
			var linkEnd:int;
			
			tmp = s.toLowerCase();
			
			linkBegin = tmp.indexOf("<a href=");
			if (linkBegin != -1)
			{
				linkEnd = tmp.indexOf("</a>");
				if (linkEnd != -1)
				{
					s = s.substr(0, linkBegin) + s.substring(linkEnd + 4);
					s = stripLinks(s);
					return s;
				}
				else
					return s;
			}
			else
				return s;
		}
		
		public static function strip(originalstring:String, whatToStrip:String = " "):String
		{
			if (originalstring)
			{
				var original:Array=originalstring.split(whatToStrip);
				return(original.join(""));
			}
			else
				return null;
		}
		
		public static function stripSurroundedBy(str:String, delimiterBegin:String, delimiterEnd:String):String
		{
			var result:String;
						
			process(str);
			return result;
				
			function process(str:String):void
			{
				var begin:int;
				var end:int;
				
				result = str;
				begin = result.indexOf(delimiterBegin);
			
				if (begin != -1)
				{
					end = result.indexOf(delimiterEnd) + delimiterEnd.length;
					result = str.substr(0, begin) + str.substr(end); 
					process(result);
				}
			}
		}
		
		public static function makeCommaDelimited(... rest):String
		{
			var s:String = "";
			
			for (var i:int = 0; i < rest.length; i++)
			{
				s += String(rest[i]);
				if (i < rest.length - 1)
					s += ",";
				
			}	
			return s;	
		}
	}
}
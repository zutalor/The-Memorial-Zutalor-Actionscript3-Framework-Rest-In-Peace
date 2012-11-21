package com.zutalor.text
{
	import com.adobe.xml.syndication.atom.PersonTag;
	import com.zutalor.loaders.URLLoaderG;
	import com.zutalor.properties.TranslateItemProperties;
	import com.zutalor.propertyManagers.Props;
	import com.zutalor.utils.Logger;
	import com.zutalor.utils.ShowError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Translate
	{
		private static var _language:String;
		private static var _tip:TranslateItemProperties;
		
		public static function set language(l:String):void
		{
			if (Props.translations.getPropsById(l))
				_language = l;
			else
				ShowError.fail(Translate,"Language " + l + " not defined.");
		}
		
		public static function get language():String
		{
			return _language;
		}
		
		public static function getNumItems(id:String):int
		{
			return Props.translations.getNumItems(id);
		}
		
		public static function text(item:String):String
		{
			var text:String = "";

			if (item)
			{
				_tip = Props.translations.getItemPropsByName(_language, item);				
				if (_tip)
				{
					if (_tip.tText)
						text = _tip.tText;
				}
				else
					text = item;
			}
			return text;
		}
		
		public static function getSoundName(item:String):String
		{
			_tip = Props.translations.getItemPropsByName(_language, item);
			if (_tip)
				return _tip.sound;
			else
				return "";
		}
		
		public static function getMetaByName(name:String):String
		{
			_tip = Props.translations.getItemPropsByName(_language, name);
			if (_tip)
				if (_tip.tMeta)
					return _tip.tMeta;
				else
					return "";
			else
				return "";
		}
		
		public static function getMetaByIndex(index:int):String
		{
			var tp:TranslateItemProperties;
			
			tp = Props.translations.getItemPropsByIndex(_language, index);
			if (tp)
				return getMetaByName(tp.name);
			else
				return null;
		}
	}
}
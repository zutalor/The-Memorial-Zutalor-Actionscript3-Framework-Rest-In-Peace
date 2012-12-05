package com.zutalor.text
{
	import com.zutalor.properties.TranslateItemProperties;
	import com.zutalor.properties.TranslateProperties;
	import com.zutalor.propertyManagers.NestedPropsManager;
	import com.zutalor.utils.ShowError;
	
	/**
	 * ...
	 * @author Geoff Pepos
	 */
	public class Translate
	{
		private static var _language:String;
		private static var _tip:TranslateItemProperties;
		
		private static var _presets:NestedPropsManager;
				
		public static function registerPresets(options:Object):void
		{
			if (!_presets)
				_presets = new NestedPropsManager();
			
			_presets.parseXML(TranslateProperties, TranslateItemProperties, options.xml[options.nodeId], options.childNodeId, 
																							options.xml[options.childNodeId]);
		}
		
		public static function get presets():NestedPropsManager
		{
			return _presets;
		}
		
		public static function set language(l:String):void
		{
			if (_presets.getPropsById(l))
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
			return _presets.getNumItems(id);
		}
		
		public static function text(item:String):String
		{
			var text:String = "";

			if (item)
			{
				_tip = _presets.getItemPropsByName(_language, item);				
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
			_tip = _presets.getItemPropsByName(_language, item);
			if (_tip)
				return _tip.sound;
			else
				return "";
		}
		
		public static function getMetaByName(name:String):String
		{
			_tip = _presets.getItemPropsByName(_language, name);
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
			
			tp = _presets.getItemPropsByIndex(_language, index);
			if (tp)
				return getMetaByName(tp.name);
			else
				return null;
		}
	}
}